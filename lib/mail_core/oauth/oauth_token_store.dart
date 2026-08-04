import 'dart:convert';

/// Persisted OAuth2 token payload (JSON in secure storage).
class OAuthTokenData {
  const OAuthTokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.tokenType,
    required this.scope,
    this.idToken,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;
  final String scope;
  final String? idToken;

  bool get isExpired =>
      DateTime.now().toUtc().isAfter(expiresAt.subtract(const Duration(minutes: 2)));

  factory OAuthTokenData.fromTokenResponse(
    Map<String, dynamic> json, {
    String? previousRefreshToken,
  }) {
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final refresh = (json['refresh_token'] as String?) ?? previousRefreshToken;
    if (refresh == null || refresh.isEmpty) {
      throw StateError('OAuth response missing refresh_token');
    }
    return OAuthTokenData(
      accessToken: json['access_token'] as String,
      refreshToken: refresh,
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      scope: (json['scope'] as String?) ?? '',
      idToken: json['id_token'] as String?,
    );
  }

  factory OAuthTokenData.fromJson(Map<String, dynamic> json) {
    return OAuthTokenData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String).toUtc(),
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      scope: (json['scope'] as String?) ?? '',
      idToken: json['id_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toUtc().toIso8601String(),
        'token_type': tokenType,
        'scope': scope,
        if (idToken != null) 'id_token': idToken,
      };

  String encode() => jsonEncode(toJson());

  factory OAuthTokenData.decode(String raw) =>
      OAuthTokenData.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  /// Prefer `preferred_username` / `email` from id_token JWT payload.
  String? get emailFromIdToken {
    final token = idToken;
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized)))
              as Map<String, dynamic>;
      final email = payload['preferred_username'] ??
          payload['email'] ??
          payload['upn'];
      return email is String && email.contains('@') ? email : null;
    } catch (_) {
      return null;
    }
  }
}
