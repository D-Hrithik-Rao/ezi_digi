import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/real_bluetooth_service.dart';

class BluetoothDevicesScreen extends StatefulWidget {
  const BluetoothDevicesScreen({super.key});

  @override
  State<BluetoothDevicesScreen> createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  final RealBluetoothService _service = RealBluetoothService();

  List<BluetoothInfo> _pairedDevices = [];
  List<BluetoothInfo> _otherDevices = [];

  bool _isScanning = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPairedDevices();
  }

  Future<void> _loadPairedDevices() async {
    setState(() => _isLoading = true);

    try {
      final all = await _service.getDevices();

      setState(() {
        _pairedDevices = all.where((d) => d.name.isNotEmpty).toList();
        _otherDevices = [];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _otherDevices = [];
    });

    try {
      final all = await _service.getDevices();
      final pairedMacs = _pairedDevices.map((d) => d.macAdress).toSet();

      setState(() {
        _otherDevices = all
            .where((d) => !pairedMacs.contains(d.macAdress))
            .toList();
        _isScanning = false;
      });
    } catch (_) {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: _buildScanButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text("DEVICES"),
    );
  }

  Widget _buildBody() {
    return ListView(
      children: [
        _SectionHeader(label: 'Paired Devices'),

        if (_pairedDevices.isEmpty)
          const _EmptyHint(text: 'No paired devices found.')
        else
          ..._pairedDevices.map(
            (d) => _DeviceTile(
              device: d,
              service: _service, // ✅ ADDED
            ),
          ),

        if (_isScanning)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_otherDevices.isNotEmpty) ...[
          _SectionHeader(label: 'Other Devices'),
          ..._otherDevices.map(
            (d) => _DeviceTile(
              device: d,
              service: _service, // ✅ ADDED
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScanButton() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: ElevatedButton(
          onPressed: _isScanning ? null : _scanDevices,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
          ),
          child: _isScanning
              ? const Text("Scanning...")
              : const Text("Scan Devices"),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BluetoothInfo device;
  final RealBluetoothService service;

  const _DeviceTile({
    required this.device,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final name = device.name.isEmpty ? 'Unknown Device' : device.name;

    return InkWell(
      onTap: () async {
        final success = await service.connectPrinter(device.macAdress);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? "Connected to $name" : "Connection Failed",
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  size: 20,
                  color: device.name.isNotEmpty
                      ? AppColors.primary
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: device.name.isNotEmpty
                              ? AppColors.textPrimary
                              : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        device.macAdress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 50),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: AppColors.primary,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(text),
    );
  }
}