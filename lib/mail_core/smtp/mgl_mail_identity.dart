import 'dart:io';

import 'package:enough_mail/enough_mail.dart';

/// Protocol + HTML fingerprints that mark mail produced by this client.
///
/// 1. X-Headers (`X-Mailer`, `X-MGL-Editor-Version`)
/// 2. HTML data attributes / class / meta (`data-mgl-mail`, `.mgl-mail-container`)
/// 3. HTML comment (`<!-- mgl-mail:1.0 -->`) — survives many forwards
class MglMailIdentity {
  MglMailIdentity._();

  static const version = '1.0';
  static const productName = 'MGL Mail Client';
  static const headerMailer = 'X-Mailer';
  static const headerEditorVersion = 'X-MGL-Editor-Version';
  static const containerClass = 'mgl-mail-container';
  static const dataAttr = 'data-mgl-mail';

  static String get platformLabel {
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }

  static String get xMailerValue =>
      '$productName $version ($platformLabel)';

  /// Invisible SMTP headers. Ordinary clients hide these from the UI.
  static void applyHeaders(MessageBuilder builder) {
    builder.setHeader(headerMailer, xMailerValue);
    builder.setHeader(headerEditorVersion, version);
  }

  static bool fromMime(MimeMessage mime) {
    final mailer = (mime.getHeaderValue('x-mailer') ?? '').toLowerCase();
    final editor =
        (mime.getHeaderValue('x-mgl-editor-version') ?? '').trim();
    return mailer.contains('mgl mail client') || editor.isNotEmpty;
  }

  static bool fromHtml(String? html) {
    if (html == null || html.isEmpty) return false;
    final s = html.toLowerCase();
    return s.contains('data-mgl-mail') ||
        s.contains(containerClass) ||
        s.contains('<!-- mgl-mail:') ||
        s.contains('name="mgl-mail"') ||
        s.contains("name='mgl-mail'");
  }

  static String wrapHtml(String content) {
    final inner = content.trim().isEmpty ? '<p></p>' : content;
    return '<!-- mgl-mail:$version -->'
        '<div class="$containerClass" $dataAttr="true" data-version="$version">'
        '<meta name="mgl-mail" content="$version">'
        '$inner'
        '</div>';
  }

  /// If X-Headers survived but the HTML marker was stripped, re-stamp HTML
  /// so the reader can still take the native block-editor path.
  static String? stampHtmlIfNative(String? html, MimeMessage mime) {
    if (html == null || html.isEmpty) return html;
    if (fromHtml(html) || !fromMime(mime)) return html;
    return wrapHtml(html);
  }
}
