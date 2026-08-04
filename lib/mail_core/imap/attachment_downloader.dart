import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:path/path.dart' as p;

import '../db/app_database.dart';
import 'imap_sync_service.dart';

class AttachmentDownloader {
  AttachmentDownloader(this.sync);

  final ImapSyncService sync;
  AppDatabase get db => sync.db;

  Future<Attachment?> download(int attachmentId) async {
    final att = await db.attachmentDao.findById(attachmentId);
    if (att == null) return null;
    if (att.isDownloaded && att.localPath != null) {
      if (await File(att.localPath!).exists()) return att;
    }

    final message = await db.messageDao.findById(att.messageId);
    if (message == null || message.uid == null || message.folderId == null) {
      return att;
    }
    final folder = await db.folderDao.findById(message.folderId!);
    if (folder == null) return att;

    await sync.connect();
    if (folder.role == 'inbox') {
      await sync.client.selectInbox();
    } else {
      await sync.client.selectMailboxByPath(folder.path);
    }
    final uid = int.parse(message.uid!);
    final result = await sync.client.uidFetchMessage(uid, 'BODY[]');
    if (result.messages.isEmpty) return att;
    final mime = result.messages.first;

    final bytes = _findAttachmentBytes(mime, att);
    if (bytes == null) return att;

    final dir = await AppDatabase.attachmentDir(
      accountId: message.accountId,
      messageId: message.id,
    );
    final safeName = att.filename.replaceAll(RegExp(r'[\\/]'), '_');
    final filePath = p.join(dir.path, safeName);
    await File(filePath).writeAsBytes(bytes, flush: true);
    await db.attachmentDao.markDownloaded(att.id, filePath);
    return db.attachmentDao.findById(att.id);
  }

  Uint8List? _findAttachmentBytes(MimeMessage mime, Attachment att) {
    ContentInfo? match;
    final infos =
        mime.findContentInfo(disposition: ContentDisposition.attachment);
    for (final info in infos) {
      if (att.partId != null && info.fetchId == att.partId) {
        match = info;
        break;
      }
      if (info.fileName == att.filename) {
        match = info;
        break;
      }
    }
    match ??= infos.isNotEmpty ? infos.first : null;
    if (match == null) return null;
    final part = mime.getPart(match.fetchId);
    return part?.decodeContentBinary();
  }
}
