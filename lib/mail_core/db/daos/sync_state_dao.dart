import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'sync_state_dao.g.dart';

@DriftAccessor(tables: [SyncStates])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<SyncState?> find(String accountId, int folderId) {
    return (select(syncStates)
          ..where((s) =>
              s.accountId.equals(accountId) & s.folderId.equals(folderId)))
        .getSingleOrNull();
  }

  Future<void> upsert(SyncStatesCompanion row) =>
      into(syncStates).insertOnConflictUpdate(row);
}
