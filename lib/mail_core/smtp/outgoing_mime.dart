import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

import '../db/app_database.dart';

/// Shared MIME construction for SMTP Outbox and IMAP Draft APPEND.
class OutgoingMime {
  OutgoingMime._();

  static Future<MimeMessage> build({
    required Account account,
    required String toAddr,
    String ccAddr = '',
    String bccAddr = '',
    required String subject,
    String? plainText,
    String? htmlText,
    required String clientMessageId,
    String? messageIdHeader,
    String? inReplyTo,
    String? references,
    List<Attachment> attachments = const [],
  }) async {
    final builder = MessageBuilder()
      ..from = [
        MailAddress(account.displayName ?? account.email, account.email),
      ]
      ..to = parseAddresses(toAddr)
      ..cc = parseAddresses(ccAddr)
      ..bcc = parseAddresses(bccAddr)
      ..subject = subject;

    builder.addHeader('X-Client-Message-Id', clientMessageId);
    if (messageIdHeader != null && messageIdHeader.isNotEmpty) {
      builder.setHeader(MailConventions.headerMessageId, messageIdHeader);
    }
    if (inReplyTo != null && inReplyTo.isNotEmpty) {
      builder.setHeader(MailConventions.headerInReplyTo, inReplyTo);
    }
    if (references != null && references.isNotEmpty) {
      builder.setHeader(MailConventions.headerReferences, references);
    }

    final html = htmlText;
    final plain = plainText ??
        (html != null && html.isNotEmpty
            ? HtmlToPlainTextConverter.convert(html)
            : '');
    if (html != null && html.isNotEmpty) {
      builder.addMultipartAlternative(
        plainText: plain,
        htmlText: html,
      );
    } else {
      builder.text = plain;
    }

    for (final att in attachments) {
      final path = att.localPath;
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!await file.exists()) continue;
      final mediaType = att.mimeType != null && att.mimeType!.isNotEmpty
          ? MediaType.fromText(att.mimeType!)
          : MediaType.guessFromFileName(att.filename);
      await builder.addFile(file, mediaType);
    }

    return builder.buildMimeMessage();
  }

  static List<MailAddress> parseAddresses(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(RegExp(r'[,;\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.contains('@'))
        .map((e) => MailAddress(null, e))
        .toList();
  }

  /// Better HTML → plain than naive tag stripping (for UI display).
  static String htmlToPlain(String html) {
    if (html.trim().isEmpty) return '';
    try {
      return HtmlToPlainTextConverter.convert(html).trim();
    } catch (_) {
      return html
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .trim();
    }
  }
}
