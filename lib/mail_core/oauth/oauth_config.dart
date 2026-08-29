/// Microsoft / Outlook OAuth settings.
///
/// Setup (Azure Portal → App registrations):
/// 1. New registration, supported account types: personal + work/school
/// 2. Authentication → Add platform → Mobile and desktop applications
/// 3. Enable redirect URI: [redirectUri] (`http://localhost:8765/`)
/// 4. API permissions (delegated):
///    - `IMAP.AccessAsUser.All` (Office 365 Exchange Online)
///    - `SMTP.Send` (Office 365 Exchange Online)
///    - `openid`, `email`, `offline_access`
/// 5. Pass client id via `--dart-define=MS_CLIENT_ID=...` or set [microsoftClientId].
class OAuthConfig {
  OAuthConfig._();

  /// Override at build/run time:
  /// `flutter run -d macos --dart-define=MS_CLIENT_ID=<your-app-id>`
  static const microsoftClientId = String.fromEnvironment(
    'MS_CLIENT_ID',
    defaultValue: 'b891e5ab-aac3-4dc2-b0de-f02625755ef4',
  );

  /// Personal Microsoft accounts only (`signInAudience: PersonalMicrosoftAccount`).
  /// `/common` requires userAudience All; `/consumers` matches Consumer.
  static const authorizeUrl =
      'https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize';
  static const tokenUrl =
      'https://login.microsoftonline.com/consumers/oauth2/v2.0/token';

  /// Loopback redirect — must match Azure "Mobile and desktop" redirect URI.
  static const redirectUri = 'http://localhost:8765/';
  static const loopbackPort = 8765;

  static const scopes = <String>[
    'openid',
    'email',
    'offline_access',
    'https://outlook.office.com/IMAP.AccessAsUser.All',
    'https://outlook.office.com/SMTP.Send',
  ];

  static const outlookImapHost = 'outlook.office365.com';
  static const outlookImapPort = 993;
  static const outlookSmtpHost = 'smtp.office365.com';
  static const outlookSmtpPort = 587;

  static bool get isConfigured => microsoftClientId.trim().isNotEmpty;
}
