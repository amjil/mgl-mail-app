import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_html/enough_mail_html.dart';

import '../db/app_database.dart';
import '../smtp/imap_append_service.dart';
import '../smtp/smtp_service.dart';

class OutboxWorker {
  OutboxWorker({
    required this.db,
    required this.account,
    required this.smtp,
    required this.appendService,
    this.runExclusive,
    this.maxRetries = 8,
    this.pollInterval = const Duration(seconds: 3),
  });

  final AppDatabase db;
  final Account account;
  final SmtpService smtp;
  final ImapAppendService appendService;
  final Future<T> Function<T>(Future<T> Function() action)? runExclusive;
  final int maxRetries;
  final Duration pollInterval;

  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;
    unawaited(_loop());
  }

  Future<void> stop() async {
    _running = false;
  }

  Future<void> kick() => _processOnce();

  Future<void> _loop() async {
    while (_running) {
      try {
        await _processOnce();
      } catch (_) {}
      await Future<void>.delayed(pollInterval);
    }
  }

  Future<void> _processOnce() async {
    final pending = await db.outboxDao.pendingDue(accountId: account.id);
    for (final item in pending) {
      if (!_running) return;
      if (item.retryCount >= maxRetries && item.status == 'failed') {
        continue;
      }
      await _sendOne(item);
    }
  }

  Future<void> _sendOne(OutboxData item) async {
    await db.outboxDao.markSending(item.id);
    try {
      final message = await db.messageDao.findById(item.messageId);
      final body = await db.messageBodyDao.find(item.messageId);
      if (message == null) {
        throw StateError('Outbox message ${item.messageId} missing');
      }
      final mime = _buildMime(message, body, item.clientMessageId);
      await smtp.send(mime);
      await db.outboxDao.markSent(item.id);
      await db.messageDao.updateMessage(
        message.id,
        MessagesCompanion(
          state: const Value('sent'),
          updatedAt: Value(DateTime.now()),
        ),
      );
      try {
        final exclusive = runExclusive;
        if (exclusive != null) {
          await exclusive(() => appendService.appendToSent(mime));
        } else {
          await appendService.appendToSent(mime);
        }
      } catch (_) {
        // best-effort
      }
    } catch (e) {
      final nextCount = item.retryCount + 1;
      final backoffSec = min(300, 5 * pow(2, item.retryCount).toInt());
      await db.outboxDao.markFailed(
        id: item.id,
        retryCount: nextCount,
        nextRetryAt: DateTime.now().add(Duration(seconds: backoffSec)),
        error: e.toString(),
      );
      await db.messageDao.updateMessage(
        item.messageId,
        MessagesCompanion(
          state: const Value('failed'),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  MimeMessage _buildMime(
    Message message,
    MessageBody? body,
    String clientMessageId,
  ) {
    final builder = MessageBuilder()
      ..from = [
        MailAddress(account.displayName ?? account.email, account.email),
      ]
      ..to = _parseAddresses(message.toAddr)
      ..cc = _parseAddresses(message.ccAddr ?? '')
      ..subject = message.subject ?? '';

    builder.addHeader('X-Client-Message-Id', clientMessageId);
    if (message.messageId != null) {
      builder.addHeader('Message-ID', message.messageId!);
    }

    final html = body?.htmlText;
    final plain = body?.plainText ??
        (html != null ? HtmlToPlainTextConverter.convert(html) : '');
    if (html != null && html.isNotEmpty) {
      builder.addMultipartAlternative(
        plainText: plain,
        htmlText: html,
      );
    } else {
      builder.text = plain;
    }
    return builder.buildMimeMessage();
  }

  List<MailAddress> _parseAddresses(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => MailAddress(null, e))
        .toList();
  }
}
