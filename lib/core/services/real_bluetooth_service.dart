import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class RealBluetoothService {

  // 🔹 Permissions
  Future<bool> requestPermissions() async {
    try {
      final result = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      return (result[Permission.bluetoothConnect]?.isGranted ?? false) &&
             ((result[Permission.bluetoothScan]?.isGranted ?? false) ||
              (result[Permission.location]?.isGranted ?? false));
    } catch (e) {
      print("Permission error: $e");
      return false;
    }
  }

  // 🔹 Get devices
  Future<List<BluetoothInfo>> getDevices() async {
    try {
      if (!await requestPermissions()) return [];
      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      print("Device error: $e");
      return [];
    }
  }

  // 🔹 Connect
  Future<bool> connectPrinter(String mac) async {
    try {
      if (!await requestPermissions()) return false;

      final formatted = _formatMacAddress(mac);

      print("Connecting to $formatted");

      return await PrintBluetoothThermal.connect(
        macPrinterAddress: formatted,
      );
    } catch (e) {
      print("Connect error: $e");
      return false;
    }
  }

  // 🔹 Ensure connection (IMPORTANT)
  Future<bool> ensureConnected(String mac) async {
    try {
      bool isConnected = await PrintBluetoothThermal.connectionStatus;

      print("Connection status: $isConnected");

      if (!isConnected) {
        print("Reconnecting...");
        return await connectPrinter(mac);
      }

      await Future.delayed(const Duration(milliseconds: 300));
      return true;

    } catch (e) {
      print("Ensure error: $e");
      return false;
    }
  }

  // 🔹 Format MAC
  String _formatMacAddress(String mac) {
    if (mac.contains(':') && mac.length == 17) {
      return mac.toUpperCase();
    }

    String cleaned = mac.replaceAll(RegExp(r'[:\s-]'), '').toUpperCase();

    if (cleaned.length == 12) {
      return cleaned.replaceAllMapped(
        RegExp(r'(.{2})'),
        (m) => '${m.group(1)}:',
      ).substring(0, 17);
    }

    return mac;
  }

  // 🔹 PRINT (FINAL)
  Future<void> printReceipt({
    required String mac,
    required String customerName,
    required String mobile,
    required String amount,
    required String date,
  }) async {
    try {
      bool connected = await ensureConnected(mac);

      if (!connected) {
        throw Exception("Printer not connected");
      }

      List<int> bytes = [];

      const line = "--------------------------------";

      bytes.addAll(utf8.encode("\n"));
      bytes.addAll(utf8.encode("      EZY CABLE DIGI\n"));
      bytes.addAll(utf8.encode("     PAYMENT RECEIPT\n"));
      bytes.addAll(utf8.encode("$line\n"));

      bytes.addAll(utf8.encode("Date : $date\n"));
      bytes.addAll(utf8.encode("$line\n"));

      bytes.addAll(utf8.encode("Customer : $customerName\n"));
      bytes.addAll(utf8.encode("Mobile   : $mobile\n"));
      bytes.addAll(utf8.encode("$line\n"));

      bytes.addAll(utf8.encode("Description        Amount\n"));
      bytes.addAll(utf8.encode("$line\n"));

      String bill = _formatRow("Cable Bill", "₹$amount");
      bytes.addAll(utf8.encode("$bill\n"));

      bytes.addAll(utf8.encode("$line\n"));

      String total = _formatRow("TOTAL", "₹$amount");
      bytes.addAll(utf8.encode("$total\n"));

      bytes.addAll(utf8.encode("$line\n"));

      bytes.addAll(utf8.encode("\n   Thank You Visit Again!\n\n\n"));

      await Future.delayed(const Duration(milliseconds: 300));

      await PrintBluetoothThermal.writeBytes(bytes);

      await Future.delayed(const Duration(milliseconds: 500));

      print("Printed successfully");

    } catch (e) {
      print("Print error: $e");
      rethrow;
    }
  }

  String _formatRow(String left, String right) {
    const width = 32;
    int space = width - (left.length + right.length);
    if (space < 1) space = 1;

    return left + " " * space + right;
  }
}