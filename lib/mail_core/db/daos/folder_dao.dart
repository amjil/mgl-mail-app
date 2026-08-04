import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'folder_dao.g.dart';

@DriftAccessor(tables: [Folders])
class FolderDao extends DatabaseAccessor<AppDatabase> with _$FolderDaoMixin {
  FolderDao(super.db);

  Future<Folder?> findByPath(String accountId, String path) {
    return (select(folders)
          ..where((f) => f.accountId.equals(accountId) & f.path.equals(path)))
        .getSingleOrNull();
  }

  Future<Folder?> findByRole(String accountId, String role) {
    return (select(folders)
          ..where(
            (f) =>
                f.accountId.equals(accountId) &
                f.role.equals(role) &
                f.selectable.equals(true),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Folder?> findInbox(String accountId) =>
      findByRole(accountId, 'inbox');

  Future<Folder?> findSent(String accountId) => findByRole(accountId, 'sent');

  Future<Folder?> findById(int id) =>
      (select(folders)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<List<Folder>> listForAccount(String accountId) {
    return (select(folders)..where((f) => f.accountId.equals(accountId)))
        .get();
  }

  Future<List<Folder>> listByRole(String role, {String? accountId}) {
    final q = select(folders)..where((f) => f.role.equals(role));
    if (accountId != null) {
      q.where((f) => f.accountId.equals(accountId));
    }
    return q.get();
  }

  Future<int> upsertFolder(FoldersCompanion row) async {
    final existing = await findByPath(row.accountId.value, row.path.value);
    if (existing != null) {
      await (update(folders)..where((f) => f.id.equals(existing.id))).write(
        FoldersCompanion(
          name: row.name,
          role: row.role,
          selectable: row.selectable,
          unreadCount: row.unreadCount,
        ),
      );
      return existing.id;
    }
    return into(folders).insert(row);
  }
}
