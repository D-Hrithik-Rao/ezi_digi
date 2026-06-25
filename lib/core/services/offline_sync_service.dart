import '../database/database_helper.dart';

/// Placeholder for future server sync. Marks local payments as synced when API is ready.
class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  final DatabaseHelper _db = DatabaseHelper();

  Future<int> pendingSyncCount() => _db.countUnsyncedPayments();

  /// Dummy sync: marks all unsynced payments as synced. Replace with HTTP POST later.
  Future<int> syncPendingToServer() async {
    return _db.markAllPaymentsSynced();
  }

  /// Clears sync flags only (keeps data). For "clear after sync" UX use with confirm.
  Future<void> clearLocalAfterSyncConfirm() async {
    await _db.markAllPaymentsSynced();
  }
}
