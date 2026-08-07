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

  Future<Folder?> findSent(String accountId) => findByRole(accountId, 'sent');

  Future<Folder?> findDraft(String accountId) =>
      findByRole(accountId, 'draft');

  Future<Folder?> findById(int id) =>
      (select(folders)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<List<Folder>> listForAccount(String accountId) {
    return (select(folders)..where((f) => f.accountId.equals(accountId)))
        .get();
  }

  Future<List<Folder>> listSelectable({String? accountId}) {
    final q = select(folders)
      ..orderBy([(f) => OrderingTerm.asc(f.path)]);
    if (accountId != null) {
      q.where(
        (f) => f.selectable.equals(true) & f.accountId.equals(accountId),
      );
    } else {
      q.where((f) => f.selectable.equals(true));
    }
    return q.get();
  }

  Stream<List<Folder>> watchSelectable({String? accountId}) {
    final q = select(folders)
      ..orderBy([(f) => OrderingTerm.asc(f.path)]);
    if (accountId != null) {
      q.where(
        (f) => f.selectable.equals(true) & f.accountId.equals(accountId),
      );
    } else {
      q.where((f) => f.selectable.equals(true));
    }
    return q.watch();
  }

  Future<List<Folder>> listByRole(String role, {String? accountId}) {
    final q = select(folders)..where((f) => f.role.equals(role));
    if (accountId != null) {
      q.where((f) => f.accountId.equals(accountId));
    }
    return q.get();
  }

  Future<void> markSelectable(int id, bool selectable) =>
      (update(folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion(selectable: Value(selectable)),
      );

  Future<void> setUnreadCount(int id, int count) =>
      (update(folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion(unreadCount: Value(count)),
      );

  Future<void> updatePath(int id, String path) =>
      (update(folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion(path: Value(path)),
      );

  Future<void> deleteById(int id) =>
      (delete(folders)..where((f) => f.id.equals(id))).go();

  Future<Folder?> findByName(String accountId, String name) {
    return (select(folders)
          ..where((f) => f.accountId.equals(accountId) & f.name.equals(name))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<Folder>> listByName(String accountId, String name) {
    return (select(folders)
          ..where((f) => f.accountId.equals(accountId) & f.name.equals(name)))
        .get();
  }

  Future<int> upsertFolder(FoldersCompanion row) async {
    final existing = await findByPath(row.accountId.value, row.path.value);
    if (existing != null) {
      await (update(folders)..where((f) => f.id.equals(existing.id))).write(
        FoldersCompanion(
          name: row.name,
          role: row.role,
          selectable: row.selectable,
          // Preserve existing unreadCount unless explicitly provided.
          unreadCount: row.unreadCount,
        ),
      );
      return existing.id;
    }
    // Same display name, different path (e.g. UTF-8 → modified UTF-7 migration).
    final byName = await findByName(row.accountId.value, row.name.value);
    if (byName != null) {
      // Path may already belong to another row — keep that row, drop the name twin.
      final clash = await findByPath(row.accountId.value, row.path.value);
      if (clash != null) {
        await (update(folders)..where((f) => f.id.equals(clash.id))).write(
          FoldersCompanion(
            name: row.name,
            role: row.role,
            selectable: row.selectable,
            unreadCount: row.unreadCount,
          ),
        );
        if (clash.id != byName.id) {
          await markSelectable(byName.id, false);
        }
        return clash.id;
      }
      try {
        await (update(folders)..where((f) => f.id.equals(byName.id))).write(
          FoldersCompanion(
            path: row.path,
            role: row.role,
            selectable: row.selectable,
            unreadCount: row.unreadCount,
          ),
        );
        return byName.id;
      } catch (_) {
        // UNIQUE path race: fall through to insert / re-find.
        final again = await findByPath(row.accountId.value, row.path.value);
        if (again != null) return again.id;
      }
    }
    return into(folders).insert(row);
  }
}
