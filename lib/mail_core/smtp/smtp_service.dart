import 'package:enough_mail/enough_mail.dart';

import '../db/app_database.dart';

class SmtpService {
  SmtpService({
    required this.account,
    required this.getSecret,
    this.useOAuth = false,
  });

  final Account account;
  final Future<String> Function() getSecret;
  final bool useOAuth;

  Future<void> send(MimeMessage message) async {
    final client = SmtpClient(account.email.split('@').last, isLogEnabled: false);
    try {
      await client.connectToServer(
        account.smtpHost,
        account.smtpPort,
        isSecure: account.smtpSsl,
      );
      await client.ehlo();
      // Outlook / Office365: port 587 with STARTTLS (smtpSsl=false).
      if (!account.smtpSsl) {
        final tls = await client.startTls();
        if (!tls.isOkStatus) {
          throw StateError('SMTP STARTTLS failed: ${tls.message}');
        }
      }

      final secret = await getSecret();
      if (useOAuth) {
        await client.authenticate(
          account.username,
          secret,
          AuthMechanism.xoauth2,
        );
      } else if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
        await client.authenticate(
          account.username,
          secret,
          AuthMechanism.plain,
        );
      } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
        await client.authenticate(
          account.username,
          secret,
          AuthMechanism.login,
        );
      } else {
        throw StateError('SMTP server supports no known auth mechanism');
      }
      final response = await client.sendMessage(message);
      if (!response.isOkStatus) {
        throw StateError('SMTP send failed: ${response.message}');
      }
    } finally {
      try {
        await client.quit();
      } catch (_) {}
    }
  }
}
