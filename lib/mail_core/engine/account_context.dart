/// Filters mailbox queries. `null` means all accounts (aggregated).
class AccountContext {
  String? currentAccountId;

  void setAccount(String? accountId) {
    currentAccountId = accountId;
  }
}
