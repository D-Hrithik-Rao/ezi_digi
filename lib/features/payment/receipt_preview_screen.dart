import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/real_bluetooth_service.dart';
import '../../core/data/customer.dart';
import '../../core/data/payment.dart';
import '../offline/offline_dialogs.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final Customer customer;
  final Payment payment;
  final bool fromOfflineCollection;

  const ReceiptPreviewScreen({
    super.key,
    required this.customer,
    required this.payment,
    this.fromOfflineCollection = false,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final RealBluetoothService _printerService = RealBluetoothService();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isLoading = false;
  bool _connected = false;

  Future<void> _disconnectPrinterSilently() async {
    try {
      await _printerService.disconnectPrinter();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    _devices = await _printerService.getDevices();
    setState(() => _isLoading = false);
  }

  Future<Uint8List> _buildPdfBytes() async {
    final pdf = pw.Document();
    final p = widget.payment;
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 10),
            pw.Text('Customer: ${widget.customer.name}'),
            pw.Text('Mobile: ${widget.customer.primaryMobileNumber}'),
            pw.Text('Amount: ₹${p.amount.toStringAsFixed(2)}'),
            pw.Text('Method: ${p.paymentMethod}'),
            pw.Text('Txn ID: ${p.transactionId}'),
            if (p.bankName.isNotEmpty) pw.Text('Bank: ${p.bankName}'),
            if (p.chequeNo.isNotEmpty) pw.Text('Cheque/DD: ${p.chequeNo}'),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _openPrinterSheet() async {
    // Start fresh every time user opens the print sheet.
    await _disconnectPrinterSilently();
    setState(() {
      _connected = false;
      _selectedDevice = null;
    });
    await _loadDevices();
    if (!mounted) return;
    if (_devices.isEmpty) {
      await showNoBluetoothPrinterDialog(context);
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Printer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    DropdownButton<BluetoothInfo>(
                      isExpanded: true,
                      hint: const Text('Choose device'),
                      value: _selectedDevice,
                      items: _devices.map((device) {
                        return DropdownMenuItem(
                          value: device,
                          child: Text(device.name),
                        );
                      }).toList(),
                      onChanged: (device) {
                        setModalState(() {
                          _selectedDevice = device;
                        });
                      },
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedDevice == null) return;
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connecting...'),
                          duration: Duration(seconds: 10),
                        ),
                      );
                      final success = await _printerService.connectPrinter(
                        _selectedDevice!.macAdress,
                      );
                      if (success) {
                        // Verify the printer is really ready before enabling print.
                        final ensured =
                            await _printerService.ensureConnected(
                          _selectedDevice!.macAdress,
                        );
                        setModalState(() => _connected = ensured);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Connected Successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✗ Connection Failed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text('CONNECT'),
                  ),
                  if (_connected) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _printReceipt,
                      child: const Text('PRINT RECEIPT'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    // If the user closes/cancels the sheet without printing,
    // do not leave the printer connected for the next customer.
    await _disconnectPrinterSilently();
  }

  Future<void> _printReceipt() async {
    if (_selectedDevice == null) return;
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printing...')),
      );
      await _printerService.printReceipt(
        mac: _selectedDevice!.macAdress,
        customerName: widget.customer.name,
        mobile: widget.customer.primaryMobileNumber,
        amount: widget.payment.amount.toString(),
        date: widget.payment.paymentDate.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Printed Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      await _printerService.disconnectPrinter();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadPdf() async {
    try {
      final bytes = await _buildPdfBytes();
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/receipt_${widget.payment.transactionId}.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved: $path')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  Future<void> _showShareSheet() async {
    try {
      final bytes = await _buildPdfBytes();
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/receipt_${widget.payment.transactionId}.pdf';
      final file = File(path);
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Share receipt',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.red),
                title: const Text('Gmail'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    subject: 'Payment receipt',
                    text: 'Receipt ${widget.payment.transactionId}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('WhatsApp'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Receipt ${widget.payment.transactionId}',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.business, color: Colors.teal),
                title: const Text('WhatsApp Business'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Receipt ${widget.payment.transactionId}',
                  );
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }

  void _finishToNextCustomer() {
    _printerService.disconnectPrinter().whenComplete(() {
      if (!mounted) return;
      if (widget.fromOfflineCollection) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    // Fire-and-forget: leaving this page should not keep printer connected.
    _printerService.disconnectPrinter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.fromOfflineCollection ? 'OFFLINE REPORT' : 'PAYMENT DETAILS';
    final syncText = widget.payment.synced ? 'Synced.' : 'Not Synced.';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.printer, color: Colors.redAccent),
            onPressed: _openPrinterSheet,
          ),
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: _showShareSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Customer: ${widget.customer.name}'),
            Text('Mobile: ${widget.customer.primaryMobileNumber}'),
            const SizedBox(height: 10),
            Text('Amount: ₹${widget.payment.amount}'),
            Text('Method: ${widget.payment.paymentMethod}'),
            Text('Txn ID: ${widget.payment.transactionId}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                syncText,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: widget.payment.synced
                      ? Colors.green
                      : Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: OutlinedButton.icon(
                onPressed: _downloadPdf,
                icon: const Icon(Icons.download),
                label: const Text('DOWNLOAD PDF'),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      _printerService.disconnectPrinter();
                      Navigator.of(context).pop();
                    },
                    child: const Text('PREV'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _finishToNextCustomer();
                    },
                    child: const Text('NEXT'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
