import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'attachment_dao.g.dart';

@DriftAccessor(tables: [Attachments])
class AttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentDaoMixin {
  AttachmentDao(super.db);

  Future<List<Attachment>> listForMessage(int messageId) {
    return (select(attachments)
          ..where((a) => a.messageId.equals(messageId)))
        .get();
  }

  Future<Attachment?> findById(int id) =>
      (select(attachments)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<int> insert(AttachmentsCompanion row) =>
      into(attachments).insert(row);

  Future<void> upsertMeta(AttachmentsCompanion row) async {
    final existing = await (select(attachments)
          ..where((a) =>
              a.messageId.equals(row.messageId.value) &
              a.filename.equals(row.filename.value)))
        .getSingleOrNull();
    if (existing != null) {
      await (update(attachments)..where((a) => a.id.equals(existing.id)))
          .write(
        AttachmentsCompanion(
          mimeType: row.mimeType,
          size: row.size,
          partId: row.partId,
          contentId: row.contentId,
        ),
      );
      return;
    }
    await into(attachments).insert(row);
  }

  Future<void> markDownloaded(int id, String localPath) {
    return (update(attachments)..where((a) => a.id.equals(id))).write(
      AttachmentsCompanion(
        localPath: Value(localPath),
        isDownloaded: const Value(true),
      ),
    );
  }

  Future<void> deleteForMessage(int messageId) =>
      (delete(attachments)..where((a) => a.messageId.equals(messageId))).go();
}
