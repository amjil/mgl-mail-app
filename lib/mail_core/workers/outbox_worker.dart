import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../smtp/imap_append_service.dart';
import '../smtp/outgoing_mime.dart';
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
      final atts = await db.attachmentDao.listForMessage(item.messageId);
      final mime = await OutgoingMime.build(
        account: account,
        toAddr: message.toAddr,
        ccAddr: message.ccAddr ?? '',
        bccAddr: message.bccAddr ?? '',
        subject: message.subject ?? '',
        plainText: body?.plainText,
        htmlText: body?.htmlText,
        clientMessageId: item.clientMessageId,
        messageIdHeader: message.messageId,
        inReplyTo: message.inReplyTo,
        references: message.referencesHeader,
        attachments: atts,
      );
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
}
