import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/offline_mode_service.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/widgets/premium_dialog.dart';

class DownloadRecordsScreen extends StatefulWidget {
  const DownloadRecordsScreen({super.key});

  @override
  State<DownloadRecordsScreen> createState() => _DownloadRecordsScreenState();
}

class _DownloadRecordsScreenState extends State<DownloadRecordsScreen> {
  final _db = DatabaseHelper();
  int _totalRecords = 0;
  int _paymentsToday = 0;
  int _pendingToSync = 0;
  int _totalSynced = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _db.insertDemoData();
    final count = await _db.getCustomerCount();
    final payToday = await _db.countPaymentsToday();
    final pending = await _db.countUnsyncedPayments();
    final todayList = await _db.getPaymentsTodayList();
    final totalSynced =
        todayList.where((p) => p.synced).length; // synced payments today
    if (mounted) {
      setState(() {
        _totalRecords = count;
        _paymentsToday = payToday;
        _pendingToSync = pending;
        _totalSynced = totalSynced;
        _loading = false;
      });
    }
  }

  Future<void> _download() async {
    await _db.insertDemoData();
    final count = await _db.getCustomerCount();
    await OfflineModeService.instance.recordDownload(totalRecords: count);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded $count records (local DB)')),
    );
    await _refresh();
  }

  Future<void> _sync() async {
    final n = await OfflineSyncService.instance.syncPendingToServer();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(n > 0 ? 'Synced $n record(s)' : 'No pending records to sync'),
      ),
    );
    await _refresh();
  }

  Future<void> _clearData() async {
    final ok = await showPremiumConfirm(
      context: context,
      title: 'Clear All Data',
      body:
          'This will remove all offline customers and payments from this device.\n\nDownload again to continue working offline.',
      confirmLabel: 'Clear',
      cancelLabel: 'Cancel',
      isDanger: true,
    );
    if (ok != true) return;

    await _db.resetDatabase();
    await OfflineModeService.instance.setOfflineMode(true);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('DOWNLOAD RECORDS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'DOWNLOAD RECORDS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _download,
                    child: Column(
                      children: [
                        const Icon(Icons.download, color: Colors.red, size: 56),
                        const Text(
                          'DOWNLOAD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Downloaded Data Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_totalRecords Total Records',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_paymentsToday Payments Made for today',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$_pendingToSync Pending to sync(payments)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$_paymentsToday Total Payments Made / $_totalSynced Total Synced',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: _sync,
                                  icon: const Icon(Icons.sync),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF0F0F0),
                                    foregroundColor: Colors.redAccent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                    ),
                                  ),
                                  label: const Text(
                                    'Sync Data',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: _clearData,
                                  icon: const Icon(Icons.delete_forever),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF0F0F0),
                                    foregroundColor: Colors.redAccent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                    ),
                                  ),
                                  label: const Text(
                                    'Clear Data',
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
