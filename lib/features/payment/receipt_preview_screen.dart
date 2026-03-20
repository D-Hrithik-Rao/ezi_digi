import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/services/real_bluetooth_service.dart';
import '../../core/data/customer.dart';
import '../../core/data/payment.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final Customer customer;
  final Payment payment;
  const ReceiptPreviewScreen({
    super.key,
    required this.customer,
    required this.payment,
  });
  @override
  State<ReceiptPreviewScreen> createState() =>
      _ReceiptPreviewScreenState();
}
class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final RealBluetoothService _printerService = RealBluetoothService();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isLoading = false;
  bool _connected = false;
  // 🔄 Load devices
  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    _devices = await _printerService.getDevices();
    setState(() => _isLoading = false);
  } 
  void _openPrinterSheet() async {
    await _loadDevices();
    showModalBottomSheet(
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
                    "Select Printer",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    DropdownButton<BluetoothInfo>(
                      isExpanded: true,
                      hint: const Text("Choose device"),
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
                  // 🔌 CONNECT BUTTON
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedDevice == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Connecting..."),
                          duration: Duration(seconds: 10),
                        ),
                      );
                      bool success = await _printerService.connectPrinter(
                        _selectedDevice!.macAdress,
                      );
                      if (success) {
                        setModalState(() => _connected = true);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✓ Connected Successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✗ Connection Failed - Check printer"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("CONNECT"),
                  ),
                  if (_connected) ...[
                    const SizedBox(height: 20),
                    // 🧾 PRINT BUTTON
                    ElevatedButton(
                      onPressed: _printReceipt,
                      child: const Text("PRINT RECEIPT"),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
  // 🧾 Print
  Future<void> _printReceipt() async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Printing...")),
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
        content: Text("✓ Printed Successfully"),
        backgroundColor: Colors.green,
      ),
    );

  } catch (e) {
    print("Print error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Print failed: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Preview"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Receipt Details",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Customer: ${widget.customer.name}"),
            Text("Mobile: ${widget.customer.primaryMobileNumber}"),
            const SizedBox(height: 10),
            Text("Amount: ₹${widget.payment.amount}"),
            Text("Method: ${widget.payment.paymentMethod}"),
            Text("Txn ID: ${widget.payment.transactionId}"),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _openPrinterSheet,
                child: const Text("PRINT RECEIPT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}