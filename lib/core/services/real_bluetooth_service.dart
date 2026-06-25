import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';

class RealBluetoothService {

  // 🔹 Permissions — simplified since startup already asked for them.
  // This is a safety net in case the user denied at startup.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final results = await [
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      final allGranted = results.values.every((s) => s.isGranted);

      if (!allGranted) {
        final anyPermanentlyDenied =
        results.values.any((s) => s.isPermanentlyDenied);
        if (anyPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }

      return true;
    } catch (e) {
      print("Permission error: $e");
      return false;
    }
  }

  // 🔹 Get paired devices
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
      await disconnectPrinter();

      final formatted = _formatMacAddress(mac);
      print("Connecting to $formatted");

      final connectResult = await PrintBluetoothThermal.connect(
        macPrinterAddress: formatted,
      );

      // Poll briefly — some devices report "connected" with a slight delay
      for (int i = 0; i < 6; i++) {
        final isConnected = await PrintBluetoothThermal.connectionStatus;
        if (isConnected) return connectResult;
        await Future.delayed(const Duration(milliseconds: 300));
      }

      return connectResult;
    } catch (e) {
      print("Connect error: $e");
      return false;
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
  }

  // 🔹 Ensure connection
  Future<bool> ensureConnected(String mac) async {
    try {
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      print("Connection status: $isConnected");

      if (!isConnected) {
        print("Reconnecting...");
        return await connectPrinter(mac);
      }

      await Future.delayed(const Duration(milliseconds: 600));
      return true;
    } catch (e) {
      print("Ensure error: $e");
      return false;
    }
  }

  // 🔹 Format MAC address
  String _formatMacAddress(String mac) {
    if (mac.contains(':') && mac.length == 17) {
      return mac.toUpperCase();
    }

    String cleaned = mac.replaceAll(RegExp(r'[:\s-]'), '').toUpperCase();

    if (cleaned.length == 12) {
      return cleaned
          .replaceAllMapped(RegExp(r'(.{2})'), (m) => '${m.group(1)}:')
          .substring(0, 17);
    }

    return mac;
  }

  // 🔹 Print receipt
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
      bytes.addAll(utf8.encode("${_formatRow("Cable Bill", "₹$amount")}\n"));
      bytes.addAll(utf8.encode("$line\n"));
      bytes.addAll(utf8.encode("${_formatRow("TOTAL", "₹$amount")}\n"));
      bytes.addAll(utf8.encode("$line\n"));
      bytes.addAll(utf8.encode("\n   Thank You Visit Again!\n\n\n"));

      await Future.delayed(const Duration(milliseconds: 600));
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