import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import 'mgl_mail_identity.dart';

class _InlineImage {
  const _InlineImage({
    required this.path,
    required this.cid,
    required this.filename,
  });

  final String path;
  final String cid;
  final String filename;
}

class _HtmlInlineRewrite {
  const _HtmlInlineRewrite({required this.html, required this.images});

  final String html;
  final List<_InlineImage> images;
}

/// Shared MIME construction for SMTP Outbox and IMAP Draft APPEND.
class OutgoingMime {
  OutgoingMime._();

  static const _uuid = Uuid();

  /// `<img src="...">` / `<img src='...'>`, including attributes around src.
  static final _imgSrcRe = RegExp(
    r'''<img\b[^>]*?\bsrc\s*=\s*(["'])(.*?)\1''',
    caseSensitive: false,
    dotAll: true,
  );

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
    MglMailIdentity.applyHeaders(builder);
    if (messageIdHeader != null && messageIdHeader.isNotEmpty) {
      builder.setHeader(MailConventions.headerMessageId, messageIdHeader);
    }
    if (inReplyTo != null && inReplyTo.isNotEmpty) {
      builder.setHeader(MailConventions.headerInReplyTo, inReplyTo);
    }
    if (references != null && references.isNotEmpty) {
      builder.setHeader(MailConventions.headerReferences, references);
    }

    final rewrite = (htmlText != null && htmlText.isNotEmpty)
        ? _rewriteLocalImages(htmlText)
        : null;
    final html = rewrite?.html ?? htmlText;
    final inlines = rewrite?.images ?? const <_InlineImage>[];
    final plain = plainText ??
        (html != null && html.isNotEmpty
            ? HtmlToPlainTextConverter.convert(html)
            : '');

    final regularAttachments = <Attachment>[];
    for (final att in attachments) {
      final path = att.localPath;
      if (path == null || path.isEmpty) continue;
      if (!await File(path).exists()) continue;
      regularAttachments.add(att);
    }

    final hasInline = inlines.isNotEmpty;
    final hasRegular = regularAttachments.isNotEmpty;

    if (html != null && html.isNotEmpty) {
      final PartBuilder relatedParent;
      if (hasInline && hasRegular) {
        relatedParent =
            builder.addPart(mediaSubtype: MediaSubtype.multipartRelated);
        relatedParent.setContentType(
          MediaSubtype.multipartRelated.mediaType,
          parameters: const {'type': 'multipart/alternative'},
        );
      } else if (hasInline) {
        builder.setContentType(
          MediaSubtype.multipartRelated.mediaType,
          parameters: const {'type': 'multipart/alternative'},
        );
        relatedParent = builder;
      } else {
        relatedParent = builder;
      }

      relatedParent.addMultipartAlternative(
        plainText: plain,
        htmlText: html,
      );
      await _addInlineImages(relatedParent, inlines);
    } else {
      builder.text = plain;
    }

    for (final att in regularAttachments) {
      final file = File(att.localPath!);
      final mediaType = att.mimeType != null && att.mimeType!.isNotEmpty
          ? MediaType.fromText(att.mimeType!)
          : MediaType.guessFromFileName(att.filename);
      await builder.addFile(file, mediaType);
    }

    return builder.buildMimeMessage();
  }

  /// Replace local `<img src>` paths with `cid:` and collect inline files.
  static _HtmlInlineRewrite _rewriteLocalImages(String html) {
    final cidByPath = <String, String>{};
    final images = <_InlineImage>[];
    final rewritten = html.replaceAllMapped(_imgSrcRe, (match) {
      final quote = match.group(1)!;
      final rawSrc = match.group(2)!;
      if (!_isLocalSrc(rawSrc)) return match.group(0)!;
      final path = _normalizePath(rawSrc);
      if (path.isEmpty) return match.group(0)!;
      final cid = cidByPath.putIfAbsent(path, () {
        final id =
            'img_${images.length + 1}_${_uuid.v4().replaceAll('-', '').substring(0, 10)}@mgl.mail';
        images.add(_InlineImage(
          path: path,
          cid: id,
          filename: _basename(path),
        ));
        return id;
      });
      return match.group(0)!.replaceFirst(
        '$quote$rawSrc$quote',
        '${quote}cid:$cid$quote',
      );
    });
    return _HtmlInlineRewrite(html: rewritten, images: images);
  }

  static Future<void> _addInlineImages(
    PartBuilder parent,
    List<_InlineImage> images,
  ) async {
    for (final img in images) {
      final file = File(img.path);
      if (!await file.exists()) continue;
      final mediaType = MediaType.guessFromFileName(img.filename);
      final part = await parent.addFile(
        file,
        mediaType,
        disposition: ContentDispositionHeader.inline(filename: img.filename),
      );
      part.setHeader('Content-ID', '<${img.cid}>');
    }
  }

  static bool _isLocalSrc(String src) {
    final s = src.trim();
    if (s.isEmpty) return false;
    final lower = s.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return false;
    }
    if (lower.startsWith('cid:')) return false;
    if (lower.startsWith('data:')) return false;
    if (lower.startsWith('//')) return false;
    return true;
  }

  static String _normalizePath(String src) {
    var s = src.trim();
    s = s
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    if (s.toLowerCase().startsWith('file:')) {
      try {
        return Uri.parse(s).toFilePath();
      } catch (_) {
        return s;
      }
    }
    return s;
  }

  static String _basename(String path) {
    final segs = Uri.file(path).pathSegments;
    if (segs.isNotEmpty && segs.last.isNotEmpty) return segs.last;
    final slash = path.replaceAll('\\', '/').split('/');
    return slash.isNotEmpty ? slash.last : path;
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
