// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imapHostMeta =
      const VerificationMeta('imapHost');
  @override
  late final GeneratedColumn<String> imapHost = GeneratedColumn<String>(
      'imap_host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imapPortMeta =
      const VerificationMeta('imapPort');
  @override
  late final GeneratedColumn<int> imapPort = GeneratedColumn<int>(
      'imap_port', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(993));
  static const VerificationMeta _imapSslMeta =
      const VerificationMeta('imapSsl');
  @override
  late final GeneratedColumn<bool> imapSsl = GeneratedColumn<bool>(
      'imap_ssl', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("imap_ssl" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _smtpHostMeta =
      const VerificationMeta('smtpHost');
  @override
  late final GeneratedColumn<String> smtpHost = GeneratedColumn<String>(
      'smtp_host', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _smtpPortMeta =
      const VerificationMeta('smtpPort');
  @override
  late final GeneratedColumn<int> smtpPort = GeneratedColumn<int>(
      'smtp_port', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(465));
  static const VerificationMeta _smtpSslMeta =
      const VerificationMeta('smtpSsl');
  @override
  late final GeneratedColumn<bool> smtpSsl = GeneratedColumn<bool>(
      'smtp_ssl', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("smtp_ssl" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authTypeMeta =
      const VerificationMeta('authType');
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
      'auth_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('password'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        displayName,
        imapHost,
        imapPort,
        imapSsl,
        smtpHost,
        smtpPort,
        smtpSsl,
        username,
        authType,
        provider,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(Insertable<Account> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('imap_host')) {
      context.handle(_imapHostMeta,
          imapHost.isAcceptableOrUnknown(data['imap_host']!, _imapHostMeta));
    } else if (isInserting) {
      context.missing(_imapHostMeta);
    }
    if (data.containsKey('imap_port')) {
      context.handle(_imapPortMeta,
          imapPort.isAcceptableOrUnknown(data['imap_port']!, _imapPortMeta));
    }
    if (data.containsKey('imap_ssl')) {
      context.handle(_imapSslMeta,
          imapSsl.isAcceptableOrUnknown(data['imap_ssl']!, _imapSslMeta));
    }
    if (data.containsKey('smtp_host')) {
      context.handle(_smtpHostMeta,
          smtpHost.isAcceptableOrUnknown(data['smtp_host']!, _smtpHostMeta));
    } else if (isInserting) {
      context.missing(_smtpHostMeta);
    }
    if (data.containsKey('smtp_port')) {
      context.handle(_smtpPortMeta,
          smtpPort.isAcceptableOrUnknown(data['smtp_port']!, _smtpPortMeta));
    }
    if (data.containsKey('smtp_ssl')) {
      context.handle(_smtpSslMeta,
          smtpSsl.isAcceptableOrUnknown(data['smtp_ssl']!, _smtpSslMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('auth_type')) {
      context.handle(_authTypeMeta,
          authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      imapHost: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imap_host'])!,
      imapPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}imap_port'])!,
      imapSsl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}imap_ssl'])!,
      smtpHost: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}smtp_host'])!,
      smtpPort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}smtp_port'])!,
      smtpSsl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}smtp_ssl'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      authType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auth_type'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final String id;
  final String email;
  final String? displayName;
  final String imapHost;
  final int imapPort;
  final bool imapSsl;
  final String smtpHost;
  final int smtpPort;
  final bool smtpSsl;
  final String username;

  /// `password` | `oauth2`
  final String authType;

  /// e.g. `outlook`, `generic`
  final String? provider;
  final DateTime createdAt;
  const Account(
      {required this.id,
      required this.email,
      this.displayName,
      required this.imapHost,
      required this.imapPort,
      required this.imapSsl,
      required this.smtpHost,
      required this.smtpPort,
      required this.smtpSsl,
      required this.username,
      required this.authType,
      this.provider,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['imap_host'] = Variable<String>(imapHost);
    map['imap_port'] = Variable<int>(imapPort);
    map['imap_ssl'] = Variable<bool>(imapSsl);
    map['smtp_host'] = Variable<String>(smtpHost);
    map['smtp_port'] = Variable<int>(smtpPort);
    map['smtp_ssl'] = Variable<bool>(smtpSsl);
    map['username'] = Variable<String>(username);
    map['auth_type'] = Variable<String>(authType);
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      imapHost: Value(imapHost),
      imapPort: Value(imapPort),
      imapSsl: Value(imapSsl),
      smtpHost: Value(smtpHost),
      smtpPort: Value(smtpPort),
      smtpSsl: Value(smtpSsl),
      username: Value(username),
      authType: Value(authType),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      imapHost: serializer.fromJson<String>(json['imapHost']),
      imapPort: serializer.fromJson<int>(json['imapPort']),
      imapSsl: serializer.fromJson<bool>(json['imapSsl']),
      smtpHost: serializer.fromJson<String>(json['smtpHost']),
      smtpPort: serializer.fromJson<int>(json['smtpPort']),
      smtpSsl: serializer.fromJson<bool>(json['smtpSsl']),
      username: serializer.fromJson<String>(json['username']),
      authType: serializer.fromJson<String>(json['authType']),
      provider: serializer.fromJson<String?>(json['provider']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'imapHost': serializer.toJson<String>(imapHost),
      'imapPort': serializer.toJson<int>(imapPort),
      'imapSsl': serializer.toJson<bool>(imapSsl),
      'smtpHost': serializer.toJson<String>(smtpHost),
      'smtpPort': serializer.toJson<int>(smtpPort),
      'smtpSsl': serializer.toJson<bool>(smtpSsl),
      'username': serializer.toJson<String>(username),
      'authType': serializer.toJson<String>(authType),
      'provider': serializer.toJson<String?>(provider),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith(
          {String? id,
          String? email,
          Value<String?> displayName = const Value.absent(),
          String? imapHost,
          int? imapPort,
          bool? imapSsl,
          String? smtpHost,
          int? smtpPort,
          bool? smtpSsl,
          String? username,
          String? authType,
          Value<String?> provider = const Value.absent(),
          DateTime? createdAt}) =>
      Account(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName.present ? displayName.value : this.displayName,
        imapHost: imapHost ?? this.imapHost,
        imapPort: imapPort ?? this.imapPort,
        imapSsl: imapSsl ?? this.imapSsl,
        smtpHost: smtpHost ?? this.smtpHost,
        smtpPort: smtpPort ?? this.smtpPort,
        smtpSsl: smtpSsl ?? this.smtpSsl,
        username: username ?? this.username,
        authType: authType ?? this.authType,
        provider: provider.present ? provider.value : this.provider,
        createdAt: createdAt ?? this.createdAt,
      );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      imapHost: data.imapHost.present ? data.imapHost.value : this.imapHost,
      imapPort: data.imapPort.present ? data.imapPort.value : this.imapPort,
      imapSsl: data.imapSsl.present ? data.imapSsl.value : this.imapSsl,
      smtpHost: data.smtpHost.present ? data.smtpHost.value : this.smtpHost,
      smtpPort: data.smtpPort.present ? data.smtpPort.value : this.smtpPort,
      smtpSsl: data.smtpSsl.present ? data.smtpSsl.value : this.smtpSsl,
      username: data.username.present ? data.username.value : this.username,
      authType: data.authType.present ? data.authType.value : this.authType,
      provider: data.provider.present ? data.provider.value : this.provider,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('imapHost: $imapHost, ')
          ..write('imapPort: $imapPort, ')
          ..write('imapSsl: $imapSsl, ')
          ..write('smtpHost: $smtpHost, ')
          ..write('smtpPort: $smtpPort, ')
          ..write('smtpSsl: $smtpSsl, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      email,
      displayName,
      imapHost,
      imapPort,
      imapSsl,
      smtpHost,
      smtpPort,
      smtpSsl,
      username,
      authType,
      provider,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.imapHost == this.imapHost &&
          other.imapPort == this.imapPort &&
          other.imapSsl == this.imapSsl &&
          other.smtpHost == this.smtpHost &&
          other.smtpPort == this.smtpPort &&
          other.smtpSsl == this.smtpSsl &&
          other.username == this.username &&
          other.authType == this.authType &&
          other.provider == this.provider &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<String> imapHost;
  final Value<int> imapPort;
  final Value<bool> imapSsl;
  final Value<String> smtpHost;
  final Value<int> smtpPort;
  final Value<bool> smtpSsl;
  final Value<String> username;
  final Value<String> authType;
  final Value<String?> provider;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.imapHost = const Value.absent(),
    this.imapPort = const Value.absent(),
    this.imapSsl = const Value.absent(),
    this.smtpHost = const Value.absent(),
    this.smtpPort = const Value.absent(),
    this.smtpSsl = const Value.absent(),
    this.username = const Value.absent(),
    this.authType = const Value.absent(),
    this.provider = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    required String imapHost,
    this.imapPort = const Value.absent(),
    this.imapSsl = const Value.absent(),
    required String smtpHost,
    this.smtpPort = const Value.absent(),
    this.smtpSsl = const Value.absent(),
    required String username,
    this.authType = const Value.absent(),
    this.provider = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        imapHost = Value(imapHost),
        smtpHost = Value(smtpHost),
        username = Value(username);
  static Insertable<Account> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? imapHost,
    Expression<int>? imapPort,
    Expression<bool>? imapSsl,
    Expression<String>? smtpHost,
    Expression<int>? smtpPort,
    Expression<bool>? smtpSsl,
    Expression<String>? username,
    Expression<String>? authType,
    Expression<String>? provider,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (imapHost != null) 'imap_host': imapHost,
      if (imapPort != null) 'imap_port': imapPort,
      if (imapSsl != null) 'imap_ssl': imapSsl,
      if (smtpHost != null) 'smtp_host': smtpHost,
      if (smtpPort != null) 'smtp_port': smtpPort,
      if (smtpSsl != null) 'smtp_ssl': smtpSsl,
      if (username != null) 'username': username,
      if (authType != null) 'auth_type': authType,
      if (provider != null) 'provider': provider,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String?>? displayName,
      Value<String>? imapHost,
      Value<int>? imapPort,
      Value<bool>? imapSsl,
      Value<String>? smtpHost,
      Value<int>? smtpPort,
      Value<bool>? smtpSsl,
      Value<String>? username,
      Value<String>? authType,
      Value<String?>? provider,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AccountsCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapSsl: imapSsl ?? this.imapSsl,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpSsl: smtpSsl ?? this.smtpSsl,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (imapHost.present) {
      map['imap_host'] = Variable<String>(imapHost.value);
    }
    if (imapPort.present) {
      map['imap_port'] = Variable<int>(imapPort.value);
    }
    if (imapSsl.present) {
      map['imap_ssl'] = Variable<bool>(imapSsl.value);
    }
    if (smtpHost.present) {
      map['smtp_host'] = Variable<String>(smtpHost.value);
    }
    if (smtpPort.present) {
      map['smtp_port'] = Variable<int>(smtpPort.value);
    }
    if (smtpSsl.present) {
      map['smtp_ssl'] = Variable<bool>(smtpSsl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('imapHost: $imapHost, ')
          ..write('imapPort: $imapPort, ')
          ..write('imapSsl: $imapSsl, ')
          ..write('smtpHost: $smtpHost, ')
          ..write('smtpPort: $smtpPort, ')
          ..write('smtpSsl: $smtpSsl, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('provider: $provider, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unreadCountMeta =
      const VerificationMeta('unreadCount');
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
      'unread_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _selectableMeta =
      const VerificationMeta('selectable');
  @override
  late final GeneratedColumn<bool> selectable = GeneratedColumn<bool>(
      'selectable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("selectable" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, accountId, name, path, role, unreadCount, selectable];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(Insertable<Folder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
          _unreadCountMeta,
          unreadCount.isAcceptableOrUnknown(
              data['unread_count']!, _unreadCountMeta));
    }
    if (data.containsKey('selectable')) {
      context.handle(
          _selectableMeta,
          selectable.isAcceptableOrUnknown(
              data['selectable']!, _selectableMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      unreadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unread_count'])!,
      selectable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}selectable'])!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String accountId;
  final String name;
  final String path;

  /// inbox / sent / trash / junk / draft / archive / custom
  final String role;
  final int unreadCount;
  final bool selectable;
  const Folder(
      {required this.id,
      required this.accountId,
      required this.name,
      required this.path,
      required this.role,
      required this.unreadCount,
      required this.selectable});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['role'] = Variable<String>(role);
    map['unread_count'] = Variable<int>(unreadCount);
    map['selectable'] = Variable<bool>(selectable);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      accountId: Value(accountId),
      name: Value(name),
      path: Value(path),
      role: Value(role),
      unreadCount: Value(unreadCount),
      selectable: Value(selectable),
    );
  }

  factory Folder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      role: serializer.fromJson<String>(json['role']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      selectable: serializer.fromJson<bool>(json['selectable']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'role': serializer.toJson<String>(role),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'selectable': serializer.toJson<bool>(selectable),
    };
  }

  Folder copyWith(
          {int? id,
          String? accountId,
          String? name,
          String? path,
          String? role,
          int? unreadCount,
          bool? selectable}) =>
      Folder(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        path: path ?? this.path,
        role: role ?? this.role,
        unreadCount: unreadCount ?? this.unreadCount,
        selectable: selectable ?? this.selectable,
      );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      role: data.role.present ? data.role.value : this.role,
      unreadCount:
          data.unreadCount.present ? data.unreadCount.value : this.unreadCount,
      selectable:
          data.selectable.present ? data.selectable.value : this.selectable,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('role: $role, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('selectable: $selectable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, name, path, role, unreadCount, selectable);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.name == this.name &&
          other.path == this.path &&
          other.role == this.role &&
          other.unreadCount == this.unreadCount &&
          other.selectable == this.selectable);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<String> name;
  final Value<String> path;
  final Value<String> role;
  final Value<int> unreadCount;
  final Value<bool> selectable;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.role = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.selectable = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required String name,
    required String path,
    required String role,
    this.unreadCount = const Value.absent(),
    this.selectable = const Value.absent(),
  })  : accountId = Value(accountId),
        name = Value(name),
        path = Value(path),
        role = Value(role);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? role,
    Expression<int>? unreadCount,
    Expression<bool>? selectable,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (role != null) 'role': role,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (selectable != null) 'selectable': selectable,
    });
  }

  FoldersCompanion copyWith(
      {Value<int>? id,
      Value<String>? accountId,
      Value<String>? name,
      Value<String>? path,
      Value<String>? role,
      Value<int>? unreadCount,
      Value<bool>? selectable}) {
    return FoldersCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      path: path ?? this.path,
      role: role ?? this.role,
      unreadCount: unreadCount ?? this.unreadCount,
      selectable: selectable ?? this.selectable,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (selectable.present) {
      map['selectable'] = Variable<bool>(selectable.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('role: $role, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('selectable: $selectable')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientMessageIdMeta =
      const VerificationMeta('clientMessageId');
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
      'client_message_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fromAddrMeta =
      const VerificationMeta('fromAddr');
  @override
  late final GeneratedColumn<String> fromAddr = GeneratedColumn<String>(
      'from_addr', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _fromNameMeta =
      const VerificationMeta('fromName');
  @override
  late final GeneratedColumn<String> fromName = GeneratedColumn<String>(
      'from_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _toAddrMeta = const VerificationMeta('toAddr');
  @override
  late final GeneratedColumn<String> toAddr = GeneratedColumn<String>(
      'to_addr', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _ccAddrMeta = const VerificationMeta('ccAddr');
  @override
  late final GeneratedColumn<String> ccAddr = GeneratedColumn<String>(
      'cc_addr', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bccAddrMeta =
      const VerificationMeta('bccAddr');
  @override
  late final GeneratedColumn<String> bccAddr = GeneratedColumn<String>(
      'bcc_addr', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inReplyToMeta =
      const VerificationMeta('inReplyTo');
  @override
  late final GeneratedColumn<String> inReplyTo = GeneratedColumn<String>(
      'in_reply_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referencesHeaderMeta =
      const VerificationMeta('referencesHeader');
  @override
  late final GeneratedColumn<String> referencesHeader = GeneratedColumn<String>(
      'references_header', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _threadIdMeta =
      const VerificationMeta('threadId');
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
      'thread_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('inbox'));
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isStarredMeta =
      const VerificationMeta('isStarred');
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
      'is_starred', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_starred" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _hasAttachmentMeta =
      const VerificationMeta('hasAttachment');
  @override
  late final GeneratedColumn<bool> hasAttachment = GeneratedColumn<bool>(
      'has_attachment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_attachment" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        folderId,
        uid,
        messageId,
        clientMessageId,
        fromAddr,
        fromName,
        toAddr,
        ccAddr,
        bccAddr,
        subject,
        inReplyTo,
        referencesHeader,
        threadId,
        date,
        state,
        isRead,
        isStarred,
        hasAttachment,
        size,
        deleted,
        syncedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
          _clientMessageIdMeta,
          clientMessageId.isAcceptableOrUnknown(
              data['client_message_id']!, _clientMessageIdMeta));
    }
    if (data.containsKey('from_addr')) {
      context.handle(_fromAddrMeta,
          fromAddr.isAcceptableOrUnknown(data['from_addr']!, _fromAddrMeta));
    }
    if (data.containsKey('from_name')) {
      context.handle(_fromNameMeta,
          fromName.isAcceptableOrUnknown(data['from_name']!, _fromNameMeta));
    }
    if (data.containsKey('to_addr')) {
      context.handle(_toAddrMeta,
          toAddr.isAcceptableOrUnknown(data['to_addr']!, _toAddrMeta));
    }
    if (data.containsKey('cc_addr')) {
      context.handle(_ccAddrMeta,
          ccAddr.isAcceptableOrUnknown(data['cc_addr']!, _ccAddrMeta));
    }
    if (data.containsKey('bcc_addr')) {
      context.handle(_bccAddrMeta,
          bccAddr.isAcceptableOrUnknown(data['bcc_addr']!, _bccAddrMeta));
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('in_reply_to')) {
      context.handle(
          _inReplyToMeta,
          inReplyTo.isAcceptableOrUnknown(
              data['in_reply_to']!, _inReplyToMeta));
    }
    if (data.containsKey('references_header')) {
      context.handle(
          _referencesHeaderMeta,
          referencesHeader.isAcceptableOrUnknown(
              data['references_header']!, _referencesHeaderMeta));
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('is_starred')) {
      context.handle(_isStarredMeta,
          isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta));
    }
    if (data.containsKey('has_attachment')) {
      context.handle(
          _hasAttachmentMeta,
          hasAttachment.isAcceptableOrUnknown(
              data['has_attachment']!, _hasAttachmentMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id']),
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid']),
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id']),
      clientMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_message_id']),
      fromAddr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_addr'])!,
      fromName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_name']),
      toAddr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_addr'])!,
      ccAddr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cc_addr']),
      bccAddr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bcc_addr']),
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject']),
      inReplyTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}in_reply_to']),
      referencesHeader: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}references_header']),
      threadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thread_id']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      isStarred: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_starred'])!,
      hasAttachment: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_attachment'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;
  final String accountId;
  final int? folderId;
  final String? uid;
  final String? messageId;
  final String? clientMessageId;
  final String fromAddr;
  final String? fromName;
  final String toAddr;
  final String? ccAddr;
  final String? bccAddr;
  final String? subject;

  /// RFC Message-ID of the message being replied to (In-Reply-To).
  final String? inReplyTo;

  /// Space-separated References chain for threading.
  final String? referencesHeader;

  /// Stable conversation id (usually root Message-ID, JWZ-style).
  final String? threadId;
  final DateTime date;

  /// inbox | sent | draft | outbox | failed
  final String state;
  final bool isRead;
  final bool isStarred;
  final bool hasAttachment;
  final int? size;
  final bool deleted;
  final DateTime syncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Message(
      {required this.id,
      required this.accountId,
      this.folderId,
      this.uid,
      this.messageId,
      this.clientMessageId,
      required this.fromAddr,
      this.fromName,
      required this.toAddr,
      this.ccAddr,
      this.bccAddr,
      this.subject,
      this.inReplyTo,
      this.referencesHeader,
      this.threadId,
      required this.date,
      required this.state,
      required this.isRead,
      required this.isStarred,
      required this.hasAttachment,
      this.size,
      required this.deleted,
      required this.syncedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || clientMessageId != null) {
      map['client_message_id'] = Variable<String>(clientMessageId);
    }
    map['from_addr'] = Variable<String>(fromAddr);
    if (!nullToAbsent || fromName != null) {
      map['from_name'] = Variable<String>(fromName);
    }
    map['to_addr'] = Variable<String>(toAddr);
    if (!nullToAbsent || ccAddr != null) {
      map['cc_addr'] = Variable<String>(ccAddr);
    }
    if (!nullToAbsent || bccAddr != null) {
      map['bcc_addr'] = Variable<String>(bccAddr);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || inReplyTo != null) {
      map['in_reply_to'] = Variable<String>(inReplyTo);
    }
    if (!nullToAbsent || referencesHeader != null) {
      map['references_header'] = Variable<String>(referencesHeader);
    }
    if (!nullToAbsent || threadId != null) {
      map['thread_id'] = Variable<String>(threadId);
    }
    map['date'] = Variable<DateTime>(date);
    map['state'] = Variable<String>(state);
    map['is_read'] = Variable<bool>(isRead);
    map['is_starred'] = Variable<bool>(isStarred);
    map['has_attachment'] = Variable<bool>(hasAttachment);
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      clientMessageId: clientMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientMessageId),
      fromAddr: Value(fromAddr),
      fromName: fromName == null && nullToAbsent
          ? const Value.absent()
          : Value(fromName),
      toAddr: Value(toAddr),
      ccAddr:
          ccAddr == null && nullToAbsent ? const Value.absent() : Value(ccAddr),
      bccAddr: bccAddr == null && nullToAbsent
          ? const Value.absent()
          : Value(bccAddr),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      inReplyTo: inReplyTo == null && nullToAbsent
          ? const Value.absent()
          : Value(inReplyTo),
      referencesHeader: referencesHeader == null && nullToAbsent
          ? const Value.absent()
          : Value(referencesHeader),
      threadId: threadId == null && nullToAbsent
          ? const Value.absent()
          : Value(threadId),
      date: Value(date),
      state: Value(state),
      isRead: Value(isRead),
      isStarred: Value(isStarred),
      hasAttachment: Value(hasAttachment),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      deleted: Value(deleted),
      syncedAt: Value(syncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      uid: serializer.fromJson<String?>(json['uid']),
      messageId: serializer.fromJson<String?>(json['messageId']),
      clientMessageId: serializer.fromJson<String?>(json['clientMessageId']),
      fromAddr: serializer.fromJson<String>(json['fromAddr']),
      fromName: serializer.fromJson<String?>(json['fromName']),
      toAddr: serializer.fromJson<String>(json['toAddr']),
      ccAddr: serializer.fromJson<String?>(json['ccAddr']),
      bccAddr: serializer.fromJson<String?>(json['bccAddr']),
      subject: serializer.fromJson<String?>(json['subject']),
      inReplyTo: serializer.fromJson<String?>(json['inReplyTo']),
      referencesHeader: serializer.fromJson<String?>(json['referencesHeader']),
      threadId: serializer.fromJson<String?>(json['threadId']),
      date: serializer.fromJson<DateTime>(json['date']),
      state: serializer.fromJson<String>(json['state']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      hasAttachment: serializer.fromJson<bool>(json['hasAttachment']),
      size: serializer.fromJson<int?>(json['size']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'folderId': serializer.toJson<int?>(folderId),
      'uid': serializer.toJson<String?>(uid),
      'messageId': serializer.toJson<String?>(messageId),
      'clientMessageId': serializer.toJson<String?>(clientMessageId),
      'fromAddr': serializer.toJson<String>(fromAddr),
      'fromName': serializer.toJson<String?>(fromName),
      'toAddr': serializer.toJson<String>(toAddr),
      'ccAddr': serializer.toJson<String?>(ccAddr),
      'bccAddr': serializer.toJson<String?>(bccAddr),
      'subject': serializer.toJson<String?>(subject),
      'inReplyTo': serializer.toJson<String?>(inReplyTo),
      'referencesHeader': serializer.toJson<String?>(referencesHeader),
      'threadId': serializer.toJson<String?>(threadId),
      'date': serializer.toJson<DateTime>(date),
      'state': serializer.toJson<String>(state),
      'isRead': serializer.toJson<bool>(isRead),
      'isStarred': serializer.toJson<bool>(isStarred),
      'hasAttachment': serializer.toJson<bool>(hasAttachment),
      'size': serializer.toJson<int?>(size),
      'deleted': serializer.toJson<bool>(deleted),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Message copyWith(
          {int? id,
          String? accountId,
          Value<int?> folderId = const Value.absent(),
          Value<String?> uid = const Value.absent(),
          Value<String?> messageId = const Value.absent(),
          Value<String?> clientMessageId = const Value.absent(),
          String? fromAddr,
          Value<String?> fromName = const Value.absent(),
          String? toAddr,
          Value<String?> ccAddr = const Value.absent(),
          Value<String?> bccAddr = const Value.absent(),
          Value<String?> subject = const Value.absent(),
          Value<String?> inReplyTo = const Value.absent(),
          Value<String?> referencesHeader = const Value.absent(),
          Value<String?> threadId = const Value.absent(),
          DateTime? date,
          String? state,
          bool? isRead,
          bool? isStarred,
          bool? hasAttachment,
          Value<int?> size = const Value.absent(),
          bool? deleted,
          DateTime? syncedAt,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Message(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        folderId: folderId.present ? folderId.value : this.folderId,
        uid: uid.present ? uid.value : this.uid,
        messageId: messageId.present ? messageId.value : this.messageId,
        clientMessageId: clientMessageId.present
            ? clientMessageId.value
            : this.clientMessageId,
        fromAddr: fromAddr ?? this.fromAddr,
        fromName: fromName.present ? fromName.value : this.fromName,
        toAddr: toAddr ?? this.toAddr,
        ccAddr: ccAddr.present ? ccAddr.value : this.ccAddr,
        bccAddr: bccAddr.present ? bccAddr.value : this.bccAddr,
        subject: subject.present ? subject.value : this.subject,
        inReplyTo: inReplyTo.present ? inReplyTo.value : this.inReplyTo,
        referencesHeader: referencesHeader.present
            ? referencesHeader.value
            : this.referencesHeader,
        threadId: threadId.present ? threadId.value : this.threadId,
        date: date ?? this.date,
        state: state ?? this.state,
        isRead: isRead ?? this.isRead,
        isStarred: isStarred ?? this.isStarred,
        hasAttachment: hasAttachment ?? this.hasAttachment,
        size: size.present ? size.value : this.size,
        deleted: deleted ?? this.deleted,
        syncedAt: syncedAt ?? this.syncedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      uid: data.uid.present ? data.uid.value : this.uid,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      fromAddr: data.fromAddr.present ? data.fromAddr.value : this.fromAddr,
      fromName: data.fromName.present ? data.fromName.value : this.fromName,
      toAddr: data.toAddr.present ? data.toAddr.value : this.toAddr,
      ccAddr: data.ccAddr.present ? data.ccAddr.value : this.ccAddr,
      bccAddr: data.bccAddr.present ? data.bccAddr.value : this.bccAddr,
      subject: data.subject.present ? data.subject.value : this.subject,
      inReplyTo: data.inReplyTo.present ? data.inReplyTo.value : this.inReplyTo,
      referencesHeader: data.referencesHeader.present
          ? data.referencesHeader.value
          : this.referencesHeader,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      date: data.date.present ? data.date.value : this.date,
      state: data.state.present ? data.state.value : this.state,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      hasAttachment: data.hasAttachment.present
          ? data.hasAttachment.value
          : this.hasAttachment,
      size: data.size.present ? data.size.value : this.size,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('uid: $uid, ')
          ..write('messageId: $messageId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('fromAddr: $fromAddr, ')
          ..write('fromName: $fromName, ')
          ..write('toAddr: $toAddr, ')
          ..write('ccAddr: $ccAddr, ')
          ..write('bccAddr: $bccAddr, ')
          ..write('subject: $subject, ')
          ..write('inReplyTo: $inReplyTo, ')
          ..write('referencesHeader: $referencesHeader, ')
          ..write('threadId: $threadId, ')
          ..write('date: $date, ')
          ..write('state: $state, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('hasAttachment: $hasAttachment, ')
          ..write('size: $size, ')
          ..write('deleted: $deleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        accountId,
        folderId,
        uid,
        messageId,
        clientMessageId,
        fromAddr,
        fromName,
        toAddr,
        ccAddr,
        bccAddr,
        subject,
        inReplyTo,
        referencesHeader,
        threadId,
        date,
        state,
        isRead,
        isStarred,
        hasAttachment,
        size,
        deleted,
        syncedAt,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderId == this.folderId &&
          other.uid == this.uid &&
          other.messageId == this.messageId &&
          other.clientMessageId == this.clientMessageId &&
          other.fromAddr == this.fromAddr &&
          other.fromName == this.fromName &&
          other.toAddr == this.toAddr &&
          other.ccAddr == this.ccAddr &&
          other.bccAddr == this.bccAddr &&
          other.subject == this.subject &&
          other.inReplyTo == this.inReplyTo &&
          other.referencesHeader == this.referencesHeader &&
          other.threadId == this.threadId &&
          other.date == this.date &&
          other.state == this.state &&
          other.isRead == this.isRead &&
          other.isStarred == this.isStarred &&
          other.hasAttachment == this.hasAttachment &&
          other.size == this.size &&
          other.deleted == this.deleted &&
          other.syncedAt == this.syncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<int?> folderId;
  final Value<String?> uid;
  final Value<String?> messageId;
  final Value<String?> clientMessageId;
  final Value<String> fromAddr;
  final Value<String?> fromName;
  final Value<String> toAddr;
  final Value<String?> ccAddr;
  final Value<String?> bccAddr;
  final Value<String?> subject;
  final Value<String?> inReplyTo;
  final Value<String?> referencesHeader;
  final Value<String?> threadId;
  final Value<DateTime> date;
  final Value<String> state;
  final Value<bool> isRead;
  final Value<bool> isStarred;
  final Value<bool> hasAttachment;
  final Value<int?> size;
  final Value<bool> deleted;
  final Value<DateTime> syncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.uid = const Value.absent(),
    this.messageId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.fromAddr = const Value.absent(),
    this.fromName = const Value.absent(),
    this.toAddr = const Value.absent(),
    this.ccAddr = const Value.absent(),
    this.bccAddr = const Value.absent(),
    this.subject = const Value.absent(),
    this.inReplyTo = const Value.absent(),
    this.referencesHeader = const Value.absent(),
    this.threadId = const Value.absent(),
    this.date = const Value.absent(),
    this.state = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.hasAttachment = const Value.absent(),
    this.size = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    this.folderId = const Value.absent(),
    this.uid = const Value.absent(),
    this.messageId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.fromAddr = const Value.absent(),
    this.fromName = const Value.absent(),
    this.toAddr = const Value.absent(),
    this.ccAddr = const Value.absent(),
    this.bccAddr = const Value.absent(),
    this.subject = const Value.absent(),
    this.inReplyTo = const Value.absent(),
    this.referencesHeader = const Value.absent(),
    this.threadId = const Value.absent(),
    required DateTime date,
    this.state = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.hasAttachment = const Value.absent(),
    this.size = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : accountId = Value(accountId),
        date = Value(date);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<int>? folderId,
    Expression<String>? uid,
    Expression<String>? messageId,
    Expression<String>? clientMessageId,
    Expression<String>? fromAddr,
    Expression<String>? fromName,
    Expression<String>? toAddr,
    Expression<String>? ccAddr,
    Expression<String>? bccAddr,
    Expression<String>? subject,
    Expression<String>? inReplyTo,
    Expression<String>? referencesHeader,
    Expression<String>? threadId,
    Expression<DateTime>? date,
    Expression<String>? state,
    Expression<bool>? isRead,
    Expression<bool>? isStarred,
    Expression<bool>? hasAttachment,
    Expression<int>? size,
    Expression<bool>? deleted,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderId != null) 'folder_id': folderId,
      if (uid != null) 'uid': uid,
      if (messageId != null) 'message_id': messageId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (fromAddr != null) 'from_addr': fromAddr,
      if (fromName != null) 'from_name': fromName,
      if (toAddr != null) 'to_addr': toAddr,
      if (ccAddr != null) 'cc_addr': ccAddr,
      if (bccAddr != null) 'bcc_addr': bccAddr,
      if (subject != null) 'subject': subject,
      if (inReplyTo != null) 'in_reply_to': inReplyTo,
      if (referencesHeader != null) 'references_header': referencesHeader,
      if (threadId != null) 'thread_id': threadId,
      if (date != null) 'date': date,
      if (state != null) 'state': state,
      if (isRead != null) 'is_read': isRead,
      if (isStarred != null) 'is_starred': isStarred,
      if (hasAttachment != null) 'has_attachment': hasAttachment,
      if (size != null) 'size': size,
      if (deleted != null) 'deleted': deleted,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? accountId,
      Value<int?>? folderId,
      Value<String?>? uid,
      Value<String?>? messageId,
      Value<String?>? clientMessageId,
      Value<String>? fromAddr,
      Value<String?>? fromName,
      Value<String>? toAddr,
      Value<String?>? ccAddr,
      Value<String?>? bccAddr,
      Value<String?>? subject,
      Value<String?>? inReplyTo,
      Value<String?>? referencesHeader,
      Value<String?>? threadId,
      Value<DateTime>? date,
      Value<String>? state,
      Value<bool>? isRead,
      Value<bool>? isStarred,
      Value<bool>? hasAttachment,
      Value<int?>? size,
      Value<bool>? deleted,
      Value<DateTime>? syncedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MessagesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderId: folderId ?? this.folderId,
      uid: uid ?? this.uid,
      messageId: messageId ?? this.messageId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      fromAddr: fromAddr ?? this.fromAddr,
      fromName: fromName ?? this.fromName,
      toAddr: toAddr ?? this.toAddr,
      ccAddr: ccAddr ?? this.ccAddr,
      bccAddr: bccAddr ?? this.bccAddr,
      subject: subject ?? this.subject,
      inReplyTo: inReplyTo ?? this.inReplyTo,
      referencesHeader: referencesHeader ?? this.referencesHeader,
      threadId: threadId ?? this.threadId,
      date: date ?? this.date,
      state: state ?? this.state,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      size: size ?? this.size,
      deleted: deleted ?? this.deleted,
      syncedAt: syncedAt ?? this.syncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (fromAddr.present) {
      map['from_addr'] = Variable<String>(fromAddr.value);
    }
    if (fromName.present) {
      map['from_name'] = Variable<String>(fromName.value);
    }
    if (toAddr.present) {
      map['to_addr'] = Variable<String>(toAddr.value);
    }
    if (ccAddr.present) {
      map['cc_addr'] = Variable<String>(ccAddr.value);
    }
    if (bccAddr.present) {
      map['bcc_addr'] = Variable<String>(bccAddr.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (inReplyTo.present) {
      map['in_reply_to'] = Variable<String>(inReplyTo.value);
    }
    if (referencesHeader.present) {
      map['references_header'] = Variable<String>(referencesHeader.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (hasAttachment.present) {
      map['has_attachment'] = Variable<bool>(hasAttachment.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('uid: $uid, ')
          ..write('messageId: $messageId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('fromAddr: $fromAddr, ')
          ..write('fromName: $fromName, ')
          ..write('toAddr: $toAddr, ')
          ..write('ccAddr: $ccAddr, ')
          ..write('bccAddr: $bccAddr, ')
          ..write('subject: $subject, ')
          ..write('inReplyTo: $inReplyTo, ')
          ..write('referencesHeader: $referencesHeader, ')
          ..write('threadId: $threadId, ')
          ..write('date: $date, ')
          ..write('state: $state, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('hasAttachment: $hasAttachment, ')
          ..write('size: $size, ')
          ..write('deleted: $deleted, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MessageBodiesTable extends MessageBodies
    with TableInfo<$MessageBodiesTable, MessageBody> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageBodiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
      'message_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _plainTextMeta =
      const VerificationMeta('plainText');
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
      'plain_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _htmlTextMeta =
      const VerificationMeta('htmlText');
  @override
  late final GeneratedColumn<String> htmlText = GeneratedColumn<String>(
      'html_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDownloadedMeta =
      const VerificationMeta('isDownloaded');
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
      'is_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_downloaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [messageId, plainText, htmlText, isDownloaded, downloadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_bodies';
  @override
  VerificationContext validateIntegrity(Insertable<MessageBody> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    }
    if (data.containsKey('plain_text')) {
      context.handle(_plainTextMeta,
          plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta));
    }
    if (data.containsKey('html_text')) {
      context.handle(_htmlTextMeta,
          htmlText.isAcceptableOrUnknown(data['html_text']!, _htmlTextMeta));
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
          _isDownloadedMeta,
          isDownloaded.isAcceptableOrUnknown(
              data['is_downloaded']!, _isDownloadedMeta));
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  MessageBody map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageBody(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_id'])!,
      plainText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plain_text']),
      htmlText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}html_text']),
      isDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_downloaded'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at']),
    );
  }

  @override
  $MessageBodiesTable createAlias(String alias) {
    return $MessageBodiesTable(attachedDatabase, alias);
  }
}

class MessageBody extends DataClass implements Insertable<MessageBody> {
  final int messageId;
  final String? plainText;
  final String? htmlText;
  final bool isDownloaded;
  final DateTime? downloadedAt;
  const MessageBody(
      {required this.messageId,
      this.plainText,
      this.htmlText,
      required this.isDownloaded,
      this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || plainText != null) {
      map['plain_text'] = Variable<String>(plainText);
    }
    if (!nullToAbsent || htmlText != null) {
      map['html_text'] = Variable<String>(htmlText);
    }
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    return map;
  }

  MessageBodiesCompanion toCompanion(bool nullToAbsent) {
    return MessageBodiesCompanion(
      messageId: Value(messageId),
      plainText: plainText == null && nullToAbsent
          ? const Value.absent()
          : Value(plainText),
      htmlText: htmlText == null && nullToAbsent
          ? const Value.absent()
          : Value(htmlText),
      isDownloaded: Value(isDownloaded),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
    );
  }

  factory MessageBody.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageBody(
      messageId: serializer.fromJson<int>(json['messageId']),
      plainText: serializer.fromJson<String?>(json['plainText']),
      htmlText: serializer.fromJson<String?>(json['htmlText']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'plainText': serializer.toJson<String?>(plainText),
      'htmlText': serializer.toJson<String?>(htmlText),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
    };
  }

  MessageBody copyWith(
          {int? messageId,
          Value<String?> plainText = const Value.absent(),
          Value<String?> htmlText = const Value.absent(),
          bool? isDownloaded,
          Value<DateTime?> downloadedAt = const Value.absent()}) =>
      MessageBody(
        messageId: messageId ?? this.messageId,
        plainText: plainText.present ? plainText.value : this.plainText,
        htmlText: htmlText.present ? htmlText.value : this.htmlText,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        downloadedAt:
            downloadedAt.present ? downloadedAt.value : this.downloadedAt,
      );
  MessageBody copyWithCompanion(MessageBodiesCompanion data) {
    return MessageBody(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      htmlText: data.htmlText.present ? data.htmlText.value : this.htmlText,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageBody(')
          ..write('messageId: $messageId, ')
          ..write('plainText: $plainText, ')
          ..write('htmlText: $htmlText, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(messageId, plainText, htmlText, isDownloaded, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageBody &&
          other.messageId == this.messageId &&
          other.plainText == this.plainText &&
          other.htmlText == this.htmlText &&
          other.isDownloaded == this.isDownloaded &&
          other.downloadedAt == this.downloadedAt);
}

class MessageBodiesCompanion extends UpdateCompanion<MessageBody> {
  final Value<int> messageId;
  final Value<String?> plainText;
  final Value<String?> htmlText;
  final Value<bool> isDownloaded;
  final Value<DateTime?> downloadedAt;
  const MessageBodiesCompanion({
    this.messageId = const Value.absent(),
    this.plainText = const Value.absent(),
    this.htmlText = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  MessageBodiesCompanion.insert({
    this.messageId = const Value.absent(),
    this.plainText = const Value.absent(),
    this.htmlText = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  static Insertable<MessageBody> custom({
    Expression<int>? messageId,
    Expression<String>? plainText,
    Expression<String>? htmlText,
    Expression<bool>? isDownloaded,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (plainText != null) 'plain_text': plainText,
      if (htmlText != null) 'html_text': htmlText,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  MessageBodiesCompanion copyWith(
      {Value<int>? messageId,
      Value<String?>? plainText,
      Value<String?>? htmlText,
      Value<bool>? isDownloaded,
      Value<DateTime?>? downloadedAt}) {
    return MessageBodiesCompanion(
      messageId: messageId ?? this.messageId,
      plainText: plainText ?? this.plainText,
      htmlText: htmlText ?? this.htmlText,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (htmlText.present) {
      map['html_text'] = Variable<String>(htmlText.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageBodiesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('plainText: $plainText, ')
          ..write('htmlText: $htmlText, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
      'message_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _filenameMeta =
      const VerificationMeta('filename');
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
      'filename', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _partIdMeta = const VerificationMeta('partId');
  @override
  late final GeneratedColumn<String> partId = GeneratedColumn<String>(
      'part_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentIdMeta =
      const VerificationMeta('contentId');
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
      'content_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDownloadedMeta =
      const VerificationMeta('isDownloaded');
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
      'is_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_downloaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        messageId,
        filename,
        mimeType,
        size,
        partId,
        contentId,
        localPath,
        isDownloaded
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta));
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('part_id')) {
      context.handle(_partIdMeta,
          partId.isAcceptableOrUnknown(data['part_id']!, _partIdMeta));
    }
    if (data.containsKey('content_id')) {
      context.handle(_contentIdMeta,
          contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
          _isDownloadedMeta,
          isDownloaded.isAcceptableOrUnknown(
              data['is_downloaded']!, _isDownloadedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_id'])!,
      filename: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filename'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size']),
      partId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}part_id']),
      contentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_id']),
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      isDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_downloaded'])!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final int id;
  final int messageId;
  final String filename;
  final String? mimeType;
  final int? size;
  final String? partId;
  final String? contentId;
  final String? localPath;
  final bool isDownloaded;
  const Attachment(
      {required this.id,
      required this.messageId,
      required this.filename,
      this.mimeType,
      this.size,
      this.partId,
      this.contentId,
      this.localPath,
      required this.isDownloaded});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<int>(messageId);
    map['filename'] = Variable<String>(filename);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || partId != null) {
      map['part_id'] = Variable<String>(partId);
    }
    if (!nullToAbsent || contentId != null) {
      map['content_id'] = Variable<String>(contentId);
    }
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      filename: Value(filename),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      partId:
          partId == null && nullToAbsent ? const Value.absent() : Value(partId),
      contentId: contentId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentId),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      isDownloaded: Value(isDownloaded),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<int>(json['messageId']),
      filename: serializer.fromJson<String>(json['filename']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      size: serializer.fromJson<int?>(json['size']),
      partId: serializer.fromJson<String?>(json['partId']),
      contentId: serializer.fromJson<String?>(json['contentId']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<int>(messageId),
      'filename': serializer.toJson<String>(filename),
      'mimeType': serializer.toJson<String?>(mimeType),
      'size': serializer.toJson<int?>(size),
      'partId': serializer.toJson<String?>(partId),
      'contentId': serializer.toJson<String?>(contentId),
      'localPath': serializer.toJson<String?>(localPath),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
    };
  }

  Attachment copyWith(
          {int? id,
          int? messageId,
          String? filename,
          Value<String?> mimeType = const Value.absent(),
          Value<int?> size = const Value.absent(),
          Value<String?> partId = const Value.absent(),
          Value<String?> contentId = const Value.absent(),
          Value<String?> localPath = const Value.absent(),
          bool? isDownloaded}) =>
      Attachment(
        id: id ?? this.id,
        messageId: messageId ?? this.messageId,
        filename: filename ?? this.filename,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        size: size.present ? size.value : this.size,
        partId: partId.present ? partId.value : this.partId,
        contentId: contentId.present ? contentId.value : this.contentId,
        localPath: localPath.present ? localPath.value : this.localPath,
        isDownloaded: isDownloaded ?? this.isDownloaded,
      );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      filename: data.filename.present ? data.filename.value : this.filename,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      size: data.size.present ? data.size.value : this.size,
      partId: data.partId.present ? data.partId.value : this.partId,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('filename: $filename, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('partId: $partId, ')
          ..write('contentId: $contentId, ')
          ..write('localPath: $localPath, ')
          ..write('isDownloaded: $isDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, filename, mimeType, size,
      partId, contentId, localPath, isDownloaded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.filename == this.filename &&
          other.mimeType == this.mimeType &&
          other.size == this.size &&
          other.partId == this.partId &&
          other.contentId == this.contentId &&
          other.localPath == this.localPath &&
          other.isDownloaded == this.isDownloaded);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<int> id;
  final Value<int> messageId;
  final Value<String> filename;
  final Value<String?> mimeType;
  final Value<int?> size;
  final Value<String?> partId;
  final Value<String?> contentId;
  final Value<String?> localPath;
  final Value<bool> isDownloaded;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.filename = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.partId = const Value.absent(),
    this.contentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int messageId,
    required String filename,
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.partId = const Value.absent(),
    this.contentId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.isDownloaded = const Value.absent(),
  })  : messageId = Value(messageId),
        filename = Value(filename);
  static Insertable<Attachment> custom({
    Expression<int>? id,
    Expression<int>? messageId,
    Expression<String>? filename,
    Expression<String>? mimeType,
    Expression<int>? size,
    Expression<String>? partId,
    Expression<String>? contentId,
    Expression<String>? localPath,
    Expression<bool>? isDownloaded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (filename != null) 'filename': filename,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (partId != null) 'part_id': partId,
      if (contentId != null) 'content_id': contentId,
      if (localPath != null) 'local_path': localPath,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
    });
  }

  AttachmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? messageId,
      Value<String>? filename,
      Value<String?>? mimeType,
      Value<int?>? size,
      Value<String?>? partId,
      Value<String?>? contentId,
      Value<String?>? localPath,
      Value<bool>? isDownloaded}) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      partId: partId ?? this.partId,
      contentId: contentId ?? this.contentId,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (partId.present) {
      map['part_id'] = Variable<String>(partId.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('filename: $filename, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('partId: $partId, ')
          ..write('contentId: $contentId, ')
          ..write('localPath: $localPath, ')
          ..write('isDownloaded: $isDownloaded')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
      'message_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _clientMessageIdMeta =
      const VerificationMeta('clientMessageId');
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
      'client_message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextRetryAtMeta =
      const VerificationMeta('nextRetryAt');
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
      'next_retry_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        messageId,
        clientMessageId,
        status,
        retryCount,
        nextRetryAt,
        lastError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
          _clientMessageIdMeta,
          clientMessageId.isAcceptableOrUnknown(
              data['client_message_id']!, _clientMessageIdMeta));
    } else if (isInserting) {
      context.missing(_clientMessageIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
          _nextRetryAtMeta,
          nextRetryAt.isAcceptableOrUnknown(
              data['next_retry_at']!, _nextRetryAtMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_id'])!,
      clientMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_message_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      nextRetryAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_retry_at']),
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String accountId;
  final int messageId;
  final String clientMessageId;

  /// pending | sending | sent | failed
  final String status;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final DateTime createdAt;
  const OutboxData(
      {required this.id,
      required this.accountId,
      required this.messageId,
      required this.clientMessageId,
      required this.status,
      required this.retryCount,
      this.nextRetryAt,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    map['message_id'] = Variable<int>(messageId);
    map['client_message_id'] = Variable<String>(clientMessageId);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      accountId: Value(accountId),
      messageId: Value(messageId),
      clientMessageId: Value(clientMessageId),
      status: Value(status),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      messageId: serializer.fromJson<int>(json['messageId']),
      clientMessageId: serializer.fromJson<String>(json['clientMessageId']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'messageId': serializer.toJson<int>(messageId),
      'clientMessageId': serializer.toJson<String>(clientMessageId),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxData copyWith(
          {int? id,
          String? accountId,
          int? messageId,
          String? clientMessageId,
          String? status,
          int? retryCount,
          Value<DateTime?> nextRetryAt = const Value.absent(),
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt}) =>
      OutboxData(
        id: id ?? this.id,
        accountId: accountId ?? this.accountId,
        messageId: messageId ?? this.messageId,
        clientMessageId: clientMessageId ?? this.clientMessageId,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      nextRetryAt:
          data.nextRetryAt.present ? data.nextRetryAt.value : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('messageId: $messageId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountId, messageId, clientMessageId,
      status, retryCount, nextRetryAt, lastError, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.messageId == this.messageId &&
          other.clientMessageId == this.clientMessageId &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<int> messageId;
  final Value<String> clientMessageId;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required int messageId,
    required String clientMessageId,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : accountId = Value(accountId),
        messageId = Value(messageId),
        clientMessageId = Value(clientMessageId);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<int>? messageId,
    Expression<String>? clientMessageId,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (messageId != null) 'message_id': messageId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith(
      {Value<int>? id,
      Value<String>? accountId,
      Value<int>? messageId,
      Value<String>? clientMessageId,
      Value<String>? status,
      Value<int>? retryCount,
      Value<DateTime?>? nextRetryAt,
      Value<String?>? lastError,
      Value<DateTime>? createdAt}) {
    return OutboxCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      messageId: messageId ?? this.messageId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('messageId: $messageId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
      'folder_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastUidMeta =
      const VerificationMeta('lastUid');
  @override
  late final GeneratedColumn<int> lastUid = GeneratedColumn<int>(
      'last_uid', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _uidValidityMeta =
      const VerificationMeta('uidValidity');
  @override
  late final GeneratedColumn<int> uidValidity = GeneratedColumn<int>(
      'uid_validity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncAtMeta =
      const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
      'last_sync_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [accountId, folderId, lastUid, uidValidity, lastSyncAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(Insertable<SyncState> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('last_uid')) {
      context.handle(_lastUidMeta,
          lastUid.isAcceptableOrUnknown(data['last_uid']!, _lastUidMeta));
    }
    if (data.containsKey('uid_validity')) {
      context.handle(
          _uidValidityMeta,
          uidValidity.isAcceptableOrUnknown(
              data['uid_validity']!, _uidValidityMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
          _lastSyncAtMeta,
          lastSyncAt.isAcceptableOrUnknown(
              data['last_sync_at']!, _lastSyncAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, folderId};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}folder_id'])!,
      lastUid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_uid'])!,
      uidValidity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uid_validity']),
      lastSyncAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync_at'])!,
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String accountId;
  final int folderId;
  final int lastUid;
  final int? uidValidity;
  final DateTime lastSyncAt;
  const SyncState(
      {required this.accountId,
      required this.folderId,
      required this.lastUid,
      this.uidValidity,
      required this.lastSyncAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<String>(accountId);
    map['folder_id'] = Variable<int>(folderId);
    map['last_uid'] = Variable<int>(lastUid);
    if (!nullToAbsent || uidValidity != null) {
      map['uid_validity'] = Variable<int>(uidValidity);
    }
    map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      accountId: Value(accountId),
      folderId: Value(folderId),
      lastUid: Value(lastUid),
      uidValidity: uidValidity == null && nullToAbsent
          ? const Value.absent()
          : Value(uidValidity),
      lastSyncAt: Value(lastSyncAt),
    );
  }

  factory SyncState.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      accountId: serializer.fromJson<String>(json['accountId']),
      folderId: serializer.fromJson<int>(json['folderId']),
      lastUid: serializer.fromJson<int>(json['lastUid']),
      uidValidity: serializer.fromJson<int?>(json['uidValidity']),
      lastSyncAt: serializer.fromJson<DateTime>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<String>(accountId),
      'folderId': serializer.toJson<int>(folderId),
      'lastUid': serializer.toJson<int>(lastUid),
      'uidValidity': serializer.toJson<int?>(uidValidity),
      'lastSyncAt': serializer.toJson<DateTime>(lastSyncAt),
    };
  }

  SyncState copyWith(
          {String? accountId,
          int? folderId,
          int? lastUid,
          Value<int?> uidValidity = const Value.absent(),
          DateTime? lastSyncAt}) =>
      SyncState(
        accountId: accountId ?? this.accountId,
        folderId: folderId ?? this.folderId,
        lastUid: lastUid ?? this.lastUid,
        uidValidity: uidValidity.present ? uidValidity.value : this.uidValidity,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      lastUid: data.lastUid.present ? data.lastUid.value : this.lastUid,
      uidValidity:
          data.uidValidity.present ? data.uidValidity.value : this.uidValidity,
      lastSyncAt:
          data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('lastUid: $lastUid, ')
          ..write('uidValidity: $uidValidity, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(accountId, folderId, lastUid, uidValidity, lastSyncAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.accountId == this.accountId &&
          other.folderId == this.folderId &&
          other.lastUid == this.lastUid &&
          other.uidValidity == this.uidValidity &&
          other.lastSyncAt == this.lastSyncAt);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> accountId;
  final Value<int> folderId;
  final Value<int> lastUid;
  final Value<int?> uidValidity;
  final Value<DateTime> lastSyncAt;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.accountId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.lastUid = const Value.absent(),
    this.uidValidity = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String accountId,
    required int folderId,
    this.lastUid = const Value.absent(),
    this.uidValidity = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountId = Value(accountId),
        folderId = Value(folderId);
  static Insertable<SyncState> custom({
    Expression<String>? accountId,
    Expression<int>? folderId,
    Expression<int>? lastUid,
    Expression<int>? uidValidity,
    Expression<DateTime>? lastSyncAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (folderId != null) 'folder_id': folderId,
      if (lastUid != null) 'last_uid': lastUid,
      if (uidValidity != null) 'uid_validity': uidValidity,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith(
      {Value<String>? accountId,
      Value<int>? folderId,
      Value<int>? lastUid,
      Value<int?>? uidValidity,
      Value<DateTime>? lastSyncAt,
      Value<int>? rowid}) {
    return SyncStatesCompanion(
      accountId: accountId ?? this.accountId,
      folderId: folderId ?? this.folderId,
      lastUid: lastUid ?? this.lastUid,
      uidValidity: uidValidity ?? this.uidValidity,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (lastUid.present) {
      map['last_uid'] = Variable<int>(lastUid.value);
    }
    if (uidValidity.present) {
      map['uid_validity'] = Variable<int>(uidValidity.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('lastUid: $lastUid, ')
          ..write('uidValidity: $uidValidity, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MessageBodiesTable messageBodies = $MessageBodiesTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final AccountDao accountDao = AccountDao(this as AppDatabase);
  late final FolderDao folderDao = FolderDao(this as AppDatabase);
  late final MessageDao messageDao = MessageDao(this as AppDatabase);
  late final MessageBodyDao messageBodyDao =
      MessageBodyDao(this as AppDatabase);
  late final AttachmentDao attachmentDao = AttachmentDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final MailSearchDao mailSearchDao = MailSearchDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        accounts,
        folders,
        messages,
        messageBodies,
        attachments,
        outbox,
        syncStates
      ];
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  required String id,
  required String email,
  Value<String?> displayName,
  required String imapHost,
  Value<int> imapPort,
  Value<bool> imapSsl,
  required String smtpHost,
  Value<int> smtpPort,
  Value<bool> smtpSsl,
  required String username,
  Value<String> authType,
  Value<String?> provider,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String?> displayName,
  Value<String> imapHost,
  Value<int> imapPort,
  Value<bool> imapSsl,
  Value<String> smtpHost,
  Value<int> smtpPort,
  Value<bool> smtpSsl,
  Value<String> username,
  Value<String> authType,
  Value<String?> provider,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imapHost => $composableBuilder(
      column: $table.imapHost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get imapPort => $composableBuilder(
      column: $table.imapPort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get imapSsl => $composableBuilder(
      column: $table.imapSsl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get smtpHost => $composableBuilder(
      column: $table.smtpHost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get smtpPort => $composableBuilder(
      column: $table.smtpPort, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get smtpSsl => $composableBuilder(
      column: $table.smtpSsl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authType => $composableBuilder(
      column: $table.authType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imapHost => $composableBuilder(
      column: $table.imapHost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get imapPort => $composableBuilder(
      column: $table.imapPort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get imapSsl => $composableBuilder(
      column: $table.imapSsl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get smtpHost => $composableBuilder(
      column: $table.smtpHost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get smtpPort => $composableBuilder(
      column: $table.smtpPort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get smtpSsl => $composableBuilder(
      column: $table.smtpSsl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authType => $composableBuilder(
      column: $table.authType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get imapHost =>
      $composableBuilder(column: $table.imapHost, builder: (column) => column);

  GeneratedColumn<int> get imapPort =>
      $composableBuilder(column: $table.imapPort, builder: (column) => column);

  GeneratedColumn<bool> get imapSsl =>
      $composableBuilder(column: $table.imapSsl, builder: (column) => column);

  GeneratedColumn<String> get smtpHost =>
      $composableBuilder(column: $table.smtpHost, builder: (column) => column);

  GeneratedColumn<int> get smtpPort =>
      $composableBuilder(column: $table.smtpPort, builder: (column) => column);

  GeneratedColumn<bool> get smtpSsl =>
      $composableBuilder(column: $table.smtpSsl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()> {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String> imapHost = const Value.absent(),
            Value<int> imapPort = const Value.absent(),
            Value<bool> imapSsl = const Value.absent(),
            Value<String> smtpHost = const Value.absent(),
            Value<int> smtpPort = const Value.absent(),
            Value<bool> smtpSsl = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> authType = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion(
            id: id,
            email: email,
            displayName: displayName,
            imapHost: imapHost,
            imapPort: imapPort,
            imapSsl: imapSsl,
            smtpHost: smtpHost,
            smtpPort: smtpPort,
            smtpSsl: smtpSsl,
            username: username,
            authType: authType,
            provider: provider,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            Value<String?> displayName = const Value.absent(),
            required String imapHost,
            Value<int> imapPort = const Value.absent(),
            Value<bool> imapSsl = const Value.absent(),
            required String smtpHost,
            Value<int> smtpPort = const Value.absent(),
            Value<bool> smtpSsl = const Value.absent(),
            required String username,
            Value<String> authType = const Value.absent(),
            Value<String?> provider = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsCompanion.insert(
            id: id,
            email: email,
            displayName: displayName,
            imapHost: imapHost,
            imapPort: imapPort,
            imapSsl: imapSsl,
            smtpHost: smtpHost,
            smtpPort: smtpPort,
            smtpSsl: smtpSsl,
            username: username,
            authType: authType,
            provider: provider,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTable,
    Account,
    $$AccountsTableFilterComposer,
    $$AccountsTableOrderingComposer,
    $$AccountsTableAnnotationComposer,
    $$AccountsTableCreateCompanionBuilder,
    $$AccountsTableUpdateCompanionBuilder,
    (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
    Account,
    PrefetchHooks Function()>;
typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  required String accountId,
  required String name,
  required String path,
  required String role,
  Value<int> unreadCount,
  Value<bool> selectable,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  Value<String> accountId,
  Value<String> name,
  Value<String> path,
  Value<String> role,
  Value<int> unreadCount,
  Value<bool> selectable,
});

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get selectable => $composableBuilder(
      column: $table.selectable, builder: (column) => ColumnFilters(column));
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get selectable => $composableBuilder(
      column: $table.selectable, builder: (column) => ColumnOrderings(column));
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
      column: $table.unreadCount, builder: (column) => column);

  GeneratedColumn<bool> get selectable => $composableBuilder(
      column: $table.selectable, builder: (column) => column);
}

class $$FoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
    Folder,
    PrefetchHooks Function()> {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int> unreadCount = const Value.absent(),
            Value<bool> selectable = const Value.absent(),
          }) =>
              FoldersCompanion(
            id: id,
            accountId: accountId,
            name: name,
            path: path,
            role: role,
            unreadCount: unreadCount,
            selectable: selectable,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String accountId,
            required String name,
            required String path,
            required String role,
            Value<int> unreadCount = const Value.absent(),
            Value<bool> selectable = const Value.absent(),
          }) =>
              FoldersCompanion.insert(
            id: id,
            accountId: accountId,
            name: name,
            path: path,
            role: role,
            unreadCount: unreadCount,
            selectable: selectable,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FoldersTable,
    Folder,
    $$FoldersTableFilterComposer,
    $$FoldersTableOrderingComposer,
    $$FoldersTableAnnotationComposer,
    $$FoldersTableCreateCompanionBuilder,
    $$FoldersTableUpdateCompanionBuilder,
    (Folder, BaseReferences<_$AppDatabase, $FoldersTable, Folder>),
    Folder,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  required String accountId,
  Value<int?> folderId,
  Value<String?> uid,
  Value<String?> messageId,
  Value<String?> clientMessageId,
  Value<String> fromAddr,
  Value<String?> fromName,
  Value<String> toAddr,
  Value<String?> ccAddr,
  Value<String?> bccAddr,
  Value<String?> subject,
  Value<String?> inReplyTo,
  Value<String?> referencesHeader,
  Value<String?> threadId,
  required DateTime date,
  Value<String> state,
  Value<bool> isRead,
  Value<bool> isStarred,
  Value<bool> hasAttachment,
  Value<int?> size,
  Value<bool> deleted,
  Value<DateTime> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> id,
  Value<String> accountId,
  Value<int?> folderId,
  Value<String?> uid,
  Value<String?> messageId,
  Value<String?> clientMessageId,
  Value<String> fromAddr,
  Value<String?> fromName,
  Value<String> toAddr,
  Value<String?> ccAddr,
  Value<String?> bccAddr,
  Value<String?> subject,
  Value<String?> inReplyTo,
  Value<String?> referencesHeader,
  Value<String?> threadId,
  Value<DateTime> date,
  Value<String> state,
  Value<bool> isRead,
  Value<bool> isStarred,
  Value<bool> hasAttachment,
  Value<int?> size,
  Value<bool> deleted,
  Value<DateTime> syncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromAddr => $composableBuilder(
      column: $table.fromAddr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromName => $composableBuilder(
      column: $table.fromName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toAddr => $composableBuilder(
      column: $table.toAddr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ccAddr => $composableBuilder(
      column: $table.ccAddr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bccAddr => $composableBuilder(
      column: $table.bccAddr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inReplyTo => $composableBuilder(
      column: $table.inReplyTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referencesHeader => $composableBuilder(
      column: $table.referencesHeader,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStarred => $composableBuilder(
      column: $table.isStarred, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasAttachment => $composableBuilder(
      column: $table.hasAttachment, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromAddr => $composableBuilder(
      column: $table.fromAddr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromName => $composableBuilder(
      column: $table.fromName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toAddr => $composableBuilder(
      column: $table.toAddr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ccAddr => $composableBuilder(
      column: $table.ccAddr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bccAddr => $composableBuilder(
      column: $table.bccAddr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inReplyTo => $composableBuilder(
      column: $table.inReplyTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referencesHeader => $composableBuilder(
      column: $table.referencesHeader,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStarred => $composableBuilder(
      column: $table.isStarred, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasAttachment => $composableBuilder(
      column: $table.hasAttachment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId, builder: (column) => column);

  GeneratedColumn<String> get fromAddr =>
      $composableBuilder(column: $table.fromAddr, builder: (column) => column);

  GeneratedColumn<String> get fromName =>
      $composableBuilder(column: $table.fromName, builder: (column) => column);

  GeneratedColumn<String> get toAddr =>
      $composableBuilder(column: $table.toAddr, builder: (column) => column);

  GeneratedColumn<String> get ccAddr =>
      $composableBuilder(column: $table.ccAddr, builder: (column) => column);

  GeneratedColumn<String> get bccAddr =>
      $composableBuilder(column: $table.bccAddr, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get inReplyTo =>
      $composableBuilder(column: $table.inReplyTo, builder: (column) => column);

  GeneratedColumn<String> get referencesHeader => $composableBuilder(
      column: $table.referencesHeader, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get hasAttachment => $composableBuilder(
      column: $table.hasAttachment, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int?> folderId = const Value.absent(),
            Value<String?> uid = const Value.absent(),
            Value<String?> messageId = const Value.absent(),
            Value<String?> clientMessageId = const Value.absent(),
            Value<String> fromAddr = const Value.absent(),
            Value<String?> fromName = const Value.absent(),
            Value<String> toAddr = const Value.absent(),
            Value<String?> ccAddr = const Value.absent(),
            Value<String?> bccAddr = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> inReplyTo = const Value.absent(),
            Value<String?> referencesHeader = const Value.absent(),
            Value<String?> threadId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isStarred = const Value.absent(),
            Value<bool> hasAttachment = const Value.absent(),
            Value<int?> size = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            accountId: accountId,
            folderId: folderId,
            uid: uid,
            messageId: messageId,
            clientMessageId: clientMessageId,
            fromAddr: fromAddr,
            fromName: fromName,
            toAddr: toAddr,
            ccAddr: ccAddr,
            bccAddr: bccAddr,
            subject: subject,
            inReplyTo: inReplyTo,
            referencesHeader: referencesHeader,
            threadId: threadId,
            date: date,
            state: state,
            isRead: isRead,
            isStarred: isStarred,
            hasAttachment: hasAttachment,
            size: size,
            deleted: deleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String accountId,
            Value<int?> folderId = const Value.absent(),
            Value<String?> uid = const Value.absent(),
            Value<String?> messageId = const Value.absent(),
            Value<String?> clientMessageId = const Value.absent(),
            Value<String> fromAddr = const Value.absent(),
            Value<String?> fromName = const Value.absent(),
            Value<String> toAddr = const Value.absent(),
            Value<String?> ccAddr = const Value.absent(),
            Value<String?> bccAddr = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> inReplyTo = const Value.absent(),
            Value<String?> referencesHeader = const Value.absent(),
            Value<String?> threadId = const Value.absent(),
            required DateTime date,
            Value<String> state = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<bool> isStarred = const Value.absent(),
            Value<bool> hasAttachment = const Value.absent(),
            Value<int?> size = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<DateTime> syncedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            accountId: accountId,
            folderId: folderId,
            uid: uid,
            messageId: messageId,
            clientMessageId: clientMessageId,
            fromAddr: fromAddr,
            fromName: fromName,
            toAddr: toAddr,
            ccAddr: ccAddr,
            bccAddr: bccAddr,
            subject: subject,
            inReplyTo: inReplyTo,
            referencesHeader: referencesHeader,
            threadId: threadId,
            date: date,
            state: state,
            isRead: isRead,
            isStarred: isStarred,
            hasAttachment: hasAttachment,
            size: size,
            deleted: deleted,
            syncedAt: syncedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$MessageBodiesTableCreateCompanionBuilder = MessageBodiesCompanion
    Function({
  Value<int> messageId,
  Value<String?> plainText,
  Value<String?> htmlText,
  Value<bool> isDownloaded,
  Value<DateTime?> downloadedAt,
});
typedef $$MessageBodiesTableUpdateCompanionBuilder = MessageBodiesCompanion
    Function({
  Value<int> messageId,
  Value<String?> plainText,
  Value<String?> htmlText,
  Value<bool> isDownloaded,
  Value<DateTime?> downloadedAt,
});

class $$MessageBodiesTableFilterComposer
    extends Composer<_$AppDatabase, $MessageBodiesTable> {
  $$MessageBodiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plainText => $composableBuilder(
      column: $table.plainText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get htmlText => $composableBuilder(
      column: $table.htmlText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$MessageBodiesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageBodiesTable> {
  $$MessageBodiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plainText => $composableBuilder(
      column: $table.plainText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get htmlText => $composableBuilder(
      column: $table.htmlText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$MessageBodiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageBodiesTable> {
  $$MessageBodiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get htmlText =>
      $composableBuilder(column: $table.htmlText, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$MessageBodiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessageBodiesTable,
    MessageBody,
    $$MessageBodiesTableFilterComposer,
    $$MessageBodiesTableOrderingComposer,
    $$MessageBodiesTableAnnotationComposer,
    $$MessageBodiesTableCreateCompanionBuilder,
    $$MessageBodiesTableUpdateCompanionBuilder,
    (
      MessageBody,
      BaseReferences<_$AppDatabase, $MessageBodiesTable, MessageBody>
    ),
    MessageBody,
    PrefetchHooks Function()> {
  $$MessageBodiesTableTableManager(_$AppDatabase db, $MessageBodiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageBodiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageBodiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageBodiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> messageId = const Value.absent(),
            Value<String?> plainText = const Value.absent(),
            Value<String?> htmlText = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
          }) =>
              MessageBodiesCompanion(
            messageId: messageId,
            plainText: plainText,
            htmlText: htmlText,
            isDownloaded: isDownloaded,
            downloadedAt: downloadedAt,
          ),
          createCompanionCallback: ({
            Value<int> messageId = const Value.absent(),
            Value<String?> plainText = const Value.absent(),
            Value<String?> htmlText = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<DateTime?> downloadedAt = const Value.absent(),
          }) =>
              MessageBodiesCompanion.insert(
            messageId: messageId,
            plainText: plainText,
            htmlText: htmlText,
            isDownloaded: isDownloaded,
            downloadedAt: downloadedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessageBodiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessageBodiesTable,
    MessageBody,
    $$MessageBodiesTableFilterComposer,
    $$MessageBodiesTableOrderingComposer,
    $$MessageBodiesTableAnnotationComposer,
    $$MessageBodiesTableCreateCompanionBuilder,
    $$MessageBodiesTableUpdateCompanionBuilder,
    (
      MessageBody,
      BaseReferences<_$AppDatabase, $MessageBodiesTable, MessageBody>
    ),
    MessageBody,
    PrefetchHooks Function()>;
typedef $$AttachmentsTableCreateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<int> id,
  required int messageId,
  required String filename,
  Value<String?> mimeType,
  Value<int?> size,
  Value<String?> partId,
  Value<String?> contentId,
  Value<String?> localPath,
  Value<bool> isDownloaded,
});
typedef $$AttachmentsTableUpdateCompanionBuilder = AttachmentsCompanion
    Function({
  Value<int> id,
  Value<int> messageId,
  Value<String> filename,
  Value<String?> mimeType,
  Value<int?> size,
  Value<String?> partId,
  Value<String?> contentId,
  Value<String?> localPath,
  Value<bool> isDownloaded,
});

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentId => $composableBuilder(
      column: $table.contentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => ColumnFilters(column));
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filename => $composableBuilder(
      column: $table.filename, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partId => $composableBuilder(
      column: $table.partId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentId => $composableBuilder(
      column: $table.contentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded,
      builder: (column) => ColumnOrderings(column));
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get partId =>
      $composableBuilder(column: $table.partId, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => column);
}

class $$AttachmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>),
    Attachment,
    PrefetchHooks Function()> {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> messageId = const Value.absent(),
            Value<String> filename = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<int?> size = const Value.absent(),
            Value<String?> partId = const Value.absent(),
            Value<String?> contentId = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
          }) =>
              AttachmentsCompanion(
            id: id,
            messageId: messageId,
            filename: filename,
            mimeType: mimeType,
            size: size,
            partId: partId,
            contentId: contentId,
            localPath: localPath,
            isDownloaded: isDownloaded,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int messageId,
            required String filename,
            Value<String?> mimeType = const Value.absent(),
            Value<int?> size = const Value.absent(),
            Value<String?> partId = const Value.absent(),
            Value<String?> contentId = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
          }) =>
              AttachmentsCompanion.insert(
            id: id,
            messageId: messageId,
            filename: filename,
            mimeType: mimeType,
            size: size,
            partId: partId,
            contentId: contentId,
            localPath: localPath,
            isDownloaded: isDownloaded,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttachmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentsTable,
    Attachment,
    $$AttachmentsTableFilterComposer,
    $$AttachmentsTableOrderingComposer,
    $$AttachmentsTableAnnotationComposer,
    $$AttachmentsTableCreateCompanionBuilder,
    $$AttachmentsTableUpdateCompanionBuilder,
    (Attachment, BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>),
    Attachment,
    PrefetchHooks Function()>;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String accountId,
  required int messageId,
  required String clientMessageId,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> accountId,
  Value<int> messageId,
  Value<String> clientMessageId,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> nextRetryAt,
  Value<String?> lastError,
  Value<DateTime> createdAt,
});

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
      column: $table.clientMessageId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
      column: $table.nextRetryAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()> {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<int> messageId = const Value.absent(),
            Value<String> clientMessageId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion(
            id: id,
            accountId: accountId,
            messageId: messageId,
            clientMessageId: clientMessageId,
            status: status,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String accountId,
            required int messageId,
            required String clientMessageId,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime?> nextRetryAt = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OutboxCompanion.insert(
            id: id,
            accountId: accountId,
            messageId: messageId,
            clientMessageId: clientMessageId,
            status: status,
            retryCount: retryCount,
            nextRetryAt: nextRetryAt,
            lastError: lastError,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTable,
    OutboxData,
    $$OutboxTableFilterComposer,
    $$OutboxTableOrderingComposer,
    $$OutboxTableAnnotationComposer,
    $$OutboxTableCreateCompanionBuilder,
    $$OutboxTableUpdateCompanionBuilder,
    (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
    OutboxData,
    PrefetchHooks Function()>;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String accountId,
  required int folderId,
  Value<int> lastUid,
  Value<int?> uidValidity,
  Value<DateTime> lastSyncAt,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> accountId,
  Value<int> folderId,
  Value<int> lastUid,
  Value<int?> uidValidity,
  Value<DateTime> lastSyncAt,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastUid => $composableBuilder(
      column: $table.lastUid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uidValidity => $composableBuilder(
      column: $table.uidValidity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get folderId => $composableBuilder(
      column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastUid => $composableBuilder(
      column: $table.lastUid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uidValidity => $composableBuilder(
      column: $table.uidValidity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<int> get lastUid =>
      $composableBuilder(column: $table.lastUid, builder: (column) => column);

  GeneratedColumn<int> get uidValidity => $composableBuilder(
      column: $table.uidValidity, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
      column: $table.lastSyncAt, builder: (column) => column);
}

class $$SyncStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStatesTable,
    SyncState,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
    SyncState,
    PrefetchHooks Function()> {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountId = const Value.absent(),
            Value<int> folderId = const Value.absent(),
            Value<int> lastUid = const Value.absent(),
            Value<int?> uidValidity = const Value.absent(),
            Value<DateTime> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion(
            accountId: accountId,
            folderId: folderId,
            lastUid: lastUid,
            uidValidity: uidValidity,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountId,
            required int folderId,
            Value<int> lastUid = const Value.absent(),
            Value<int?> uidValidity = const Value.absent(),
            Value<DateTime> lastSyncAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion.insert(
            accountId: accountId,
            folderId: folderId,
            lastUid: lastUid,
            uidValidity: uidValidity,
            lastSyncAt: lastSyncAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStatesTable,
    SyncState,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
    SyncState,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MessageBodiesTableTableManager get messageBodies =>
      $$MessageBodiesTableTableManager(_db, _db.messageBodies);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
