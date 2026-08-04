import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'oauth_config.dart';
import 'oauth_token_store.dart';

class OutlookOAuthResult {
  const OutlookOAuthResult({
    required this.email,
    required this.token,
  });

  final String email;
  final OAuthTokenData token;
}

/// Desktop Outlook OAuth2 (authorization code + PKCE + localhost redirect).
class OutlookOAuth {
  OutlookOAuth({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Opens the system browser, captures the auth code on localhost, exchanges tokens.
  Future<OutlookOAuthResult> signIn() async {
    if (!OAuthConfig.isConfigured) {
      throw StateError(
        'MS_CLIENT_ID not set. Run with '
        '--dart-define=MS_CLIENT_ID=<azure-app-client-id>',
      );
    }

    final verifier = _pkceVerifier();
    final challenge = _pkceChallenge(verifier);
    final state = _randomUrlSafe(24);

    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      OAuthConfig.loopbackPort,
    );

    try {
      final authUri = Uri.parse(OAuthConfig.authorizeUrl).replace(
        queryParameters: {
          'client_id': OAuthConfig.microsoftClientId,
          'response_type': 'code',
          'redirect_uri': OAuthConfig.redirectUri,
          'response_mode': 'query',
          'scope': OAuthConfig.scopes.join(' '),
          'state': state,
          'code_challenge': challenge,
          'code_challenge_method': 'S256',
          'prompt': 'select_account',
        },
      );

      final codeFuture = _waitForCode(server, expectedState: state);
      final launched = await launchUrl(
        authUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError('Could not open browser for Microsoft login');
      }

      final code = await codeFuture.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('Microsoft login timed out'),
      );

      final token = await _exchangeCode(code: code, verifier: verifier);
      final email = token.emailFromIdToken;
      if (email == null || email.isEmpty) {
        throw StateError(
          'Could not read email from Microsoft id_token. '
          'Ensure openid + email scopes are granted.',
        );
      }
      return OutlookOAuthResult(email: email, token: token);
    } finally {
      await server.close(force: true);
    }
  }

  Future<OAuthTokenData> refresh(OAuthTokenData current) async {
    if (!OAuthConfig.isConfigured) {
      throw StateError('MS_CLIENT_ID not set');
    }
    final response = await _http.post(
      Uri.parse(OAuthConfig.tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': OAuthConfig.microsoftClientId,
        'grant_type': 'refresh_token',
        'refresh_token': current.refreshToken,
        'scope': OAuthConfig.scopes.join(' '),
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Token refresh failed (${response.statusCode}): ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenData.fromTokenResponse(
      json,
      previousRefreshToken: current.refreshToken,
    );
  }

  Future<OAuthTokenData> _exchangeCode({
    required String code,
    required String verifier,
  }) async {
    final response = await _http.post(
      Uri.parse(OAuthConfig.tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'client_id': OAuthConfig.microsoftClientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': OAuthConfig.redirectUri,
        'code_verifier': verifier,
        'scope': OAuthConfig.scopes.join(' '),
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Token exchange failed (${response.statusCode}): ${response.body}',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return OAuthTokenData.fromTokenResponse(json);
  }

  Future<String> _waitForCode(
    HttpServer server, {
    required String expectedState,
  }) {
    final completer = Completer<String>();
    server.listen((request) async {
      try {
        final params = request.uri.queryParameters;
        if (params.containsKey('error')) {
          final desc = params['error_description'] ?? params['error'];
          if (!completer.isCompleted) {
            completer.completeError(StateError('Microsoft login error: $desc'));
          }
          await _writeHtml(
            request,
            title: 'Login failed',
            body: 'You can close this window and return to the app.',
          );
          return;
        }
        final code = params['code'];
        final state = params['state'];
        if (code == null || code.isEmpty) {
          await _writeHtml(
            request,
            title: 'Missing code',
            body: 'No authorization code received.',
          );
          return;
        }
        if (state != expectedState) {
          if (!completer.isCompleted) {
            completer.completeError(StateError('OAuth state mismatch'));
          }
          await _writeHtml(
            request,
            title: 'Invalid state',
            body: 'Please try again from the app.',
          );
          return;
        }
        await _writeHtml(
          request,
          title: 'Signed in',
          body: 'Microsoft account connected. You can close this window.',
        );
        if (!completer.isCompleted) {
          completer.complete(code);
        }
      } catch (e, st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      }
    });
    return completer.future;
  }

  Future<void> _writeHtml(
    HttpRequest request, {
    required String title,
    required String body,
  }) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(
        '<!DOCTYPE html><html><head><meta charset="utf-8">'
        '<title>$title</title></head>'
        '<body style="font-family:sans-serif;padding:2rem">'
        '<h2>$title</h2><p>$body</p></body></html>',
      );
    await request.response.close();
  }

  static String _pkceVerifier() => _randomUrlSafe(64);

  static String _pkceChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  static String _randomUrlSafe(int length) {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rnd = Random.secure();
    return List.generate(length, (_) => alphabet[rnd.nextInt(alphabet.length)])
        .join();
  }
}
