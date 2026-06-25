import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/offline_sync_service.dart';

class MinidayReportScreen extends StatefulWidget {
  const MinidayReportScreen({super.key});

  @override
  State<MinidayReportScreen> createState() => _MinidayReportScreenState();
}

class _MinidayReportScreenState extends State<MinidayReportScreen> {
  final _db = DatabaseHelper();
  Map<String, dynamic>? _summary;
  bool _loading = true;
  int _pendingToSync = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _db.getTodayCollectionSummary();
    final todayPayments = await _db.getPaymentsTodayList();
    _pendingToSync = todayPayments.where((p) => !p.synced).length;
    setState(() {
      _summary = s;
      _loading = false;
    });
  }

  Future<Uint8List> _buildPdf() async {
    final s = _summary!;
    final cashC = s['cashCount'] as int;
    final bankC = s['bankCount'] as int;
    final cashA = s['cashAmount'] as double;
    final bankA = s['bankAmount'] as double;
    final total = s['totalAmount'] as double;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('MINI DAY REPORT',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('MODE          COUNT    AMOUNT'),
            pw.SizedBox(height: 8),
            pw.Text(
                'CASH(STB)     $cashC    ₹${cashA.toStringAsFixed(1)}'),
            pw.Text(
                'BANK(STB)     $bankC    ₹${bankA.toStringAsFixed(1)}'),
            pw.Divider(),
            pw.Text('TOTAL COLLECTION    ${total.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
    return doc.save();
  }

  Future<void> _printReport() async {
    if (_summary == null) return;
    final bytes = await _buildPdf();
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Future<void> _sync() async {
    await OfflineSyncService.instance.syncPendingToServer();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('MINI DAY REPORT'),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _printReport,
                          icon: const Icon(Icons.print, color: Colors.red),
                          label: const Text(
                            'PRINT',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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
                      children: [
                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'MODE',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'COUNT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'AMOUNT',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _row(
                          'CASH(STB)',
                          '${_summary!['cashCount']}',
                          '₹${(_summary!['cashAmount'] as double).toStringAsFixed(1)}',
                        ),
                        _row(
                          'BANK(STB)',
                          '${_summary!['bankCount']}',
                          '₹${(_summary!['bankAmount'] as double).toStringAsFixed(1)}',
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'TOTAL COLLECTION',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                (_summary!['totalAmount'] as double)
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _pendingToSync > 0
                      ? SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _sync,
                            icon: const Icon(Icons.sync),
                            label: const Text(
                              'Click to Sync',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: Center(
                            child: Text(
                              'Synced.',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.redAccent.shade700,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  Widget _row(String mode, String count, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(mode)),
          Expanded(child: Text(count)),
          Expanded(child: Text(amount)),
        ],
      ),
    );
  }
}
