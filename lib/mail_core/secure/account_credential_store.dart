import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../oauth/oauth_token_store.dart';

/// Credential kinds stored in platform keychain / keystore.
enum AuthType {
  password,
  oauth2;

  static AuthType parse(String? raw) {
    switch (raw) {
      case 'oauth2':
        return AuthType.oauth2;
      default:
        return AuthType.password;
    }
  }

  String get wire => name;
}

/// Where account secrets are persisted.
///
/// - [development]: JSON file under Application Support (no Keychain).
///   Use for unsigned / ad-hoc macOS builds that lack Keychain entitlements.
/// - [production]: platform Keychain / Keystore via [FlutterSecureStorage].
enum CredentialStoreMode {
  development,
  production,
}

/// Stores IMAP/SMTP passwords or OAuth tokens.
class AccountCredentialStore {
  AccountCredentialStore({
    CredentialStoreMode? mode,
    FlutterSecureStorage? storage,
  })  : mode = mode ??
            (kDebugMode
                ? CredentialStoreMode.development
                : CredentialStoreMode.production),
        _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              mOptions: MacOsOptions(usesDataProtectionKeychain: true),
            ) {
    // ignore: avoid_print
    print('AccountCredentialStore mode=${this.mode.name}');
  }

  final CredentialStoreMode mode;
  final FlutterSecureStorage _storage;

  Map<String, String>? _fileCache;

  static String _passwordKey(String accountId) => 'mail_pwd_$accountId';
  static String _oauthKey(String accountId) => 'mail_oauth_$accountId';

  bool get _useFile => mode == CredentialStoreMode.development;

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    final folder = Directory(p.join(dir.path, 'mail_core'));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(p.join(folder.path, 'credentials.dev.json'));
  }

  Future<Map<String, String>> _loadFile() async {
    if (_fileCache != null) return _fileCache!;
    final f = await _file();
    if (!await f.exists()) {
      _fileCache = {};
      return _fileCache!;
    }
    final raw = await f.readAsString();
    if (raw.isEmpty) {
      _fileCache = {};
      return _fileCache!;
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map) {
      _fileCache = decoded.map(
        (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
      );
    } else {
      _fileCache = {};
    }
    return _fileCache!;
  }

  Future<void> _saveFile(Map<String, String> data) async {
    _fileCache = data;
    final f = await _file();
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> _write(String key, String value) async {
    if (_useFile) {
      final data = await _loadFile();
      data[key] = value;
      await _saveFile(data);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> _read(String key) async {
    if (_useFile) {
      final data = await _loadFile();
      return data[key];
    }
    return _storage.read(key: key);
  }

  Future<void> _delete(String key) async {
    if (_useFile) {
      final data = await _loadFile();
      data.remove(key);
      await _saveFile(data);
      return;
    }
    await _storage.delete(key: key);
  }

  Future<void> savePassword(String accountId, String password) =>
      _write(_passwordKey(accountId), password);

  Future<String?> readPassword(String accountId) =>
      _read(_passwordKey(accountId));

  Future<void> saveOAuth(String accountId, OAuthTokenData token) =>
      _write(_oauthKey(accountId), token.encode());

  Future<OAuthTokenData?> readOAuth(String accountId) async {
    final raw = await _read(_oauthKey(accountId));
    if (raw == null || raw.isEmpty) return null;
    return OAuthTokenData.decode(raw);
  }

  Future<void> delete(String accountId) async {
    await _delete(_passwordKey(accountId));
    await _delete(_oauthKey(accountId));
  }
}
