import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<List<Account>> listAccounts() => select(accounts).get();

  Stream<List<Account>> watchAll() => select(accounts).watch();

  Future<Account?> findById(String id) =>
      (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> upsert(AccountsCompanion row) =>
      into(accounts).insertOnConflictUpdate(row);

  Future<void> deleteById(String id) async {
    await attachedDatabase.purgeAccountData(id);
    await (delete(accounts)..where((a) => a.id.equals(id))).go();
    try {
      await attachedDatabase.mailSearchDao.deleteByAccount(id);
    } catch (_) {}
  }
}
