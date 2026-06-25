import 'package:shared_preferences/shared_preferences.dart';

class OfflineModeService {
  OfflineModeService._();
  static final OfflineModeService instance = OfflineModeService._();

  static const _keyOffline = 'is_offline_mode';
  static const _keyDownloadedRecords = 'offline_downloaded_record_count';
  static const _keyLastDownload = 'offline_last_download_iso';

  Future<bool> get isOfflineMode async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyOffline) ?? false;
  }

  Future<void> setOfflineMode(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyOffline, value);
  }

  Future<void> recordDownload({required int totalRecords}) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keyDownloadedRecords, totalRecords);
    await p.setString(_keyLastDownload, DateTime.now().toIso8601String());
  }

  Future<int> get downloadedRecordCount async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_keyDownloadedRecords) ?? 0;
  }
}
