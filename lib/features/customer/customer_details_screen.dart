import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/database/database_helper.dart';
import '../payment/payment_options_screen.dart';
import 'customer_map_screen.dart';
import 'location_preview_screen.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final _db = DatabaseHelper();
  late Customer _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CUSTOMER DETAILS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.primary,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildLocationInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildCustomerOperations(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CUSTOMER INFO'),
          const SizedBox(height: AppSizes.paddingM),
          _detailRow('Customer Name', _customer.name),
          _detailRow('Nick Name', _customer.nickName),
          _detailRow('Mobile Number', _customer.primaryMobileNumber),
          _detailRow('Total Due', _customer.totalDue),
          _detailRow('Amount Payable', _customer.amountPayable),
          _detailRow('Customer Type', _customer.customerType),
          _detailRow('Group Name', _customer.groupName),
          _detailRow('Area Name', _customer.areaName),
          _detailRow('Address', _customer.address),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSectionHeader('LOCATION')),
              IconButton(
                onPressed: _openCustomerMap,
                icon: const Icon(Icons.location_on, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _detailRow('Last Paid Date', _customer.lastPaidDate),
          _detailRow('Bill Month', _customer.billMonth),
          _detailRow('LCO Customer id', _customer.lcoCustomerId),
          _detailRow('Box Number', _customer.boxNumber),
          _detailRow('VC Number', _customer.vcNumber),
          _detailRow(
            'Coordinates',
            _customer.latitude != null && _customer.longitude != null
                ? '${_customer.latitude}, ${_customer.longitude}'
                : 'Not Updated',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerOperations(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('CUSTOMER OPERATIONS'),
          const SizedBox(height: AppSizes.paddingM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            mainAxisSpacing: AppSizes.paddingS,
            crossAxisSpacing: AppSizes.paddingS,
            children: [
              _operationItem(Iconsax.money_send, 'Make Payments', context),
              _operationItem(Iconsax.clock, 'Payment History', context),
              _operationItem(Iconsax.message_question, 'Create Complaints', context),
              _operationItem(Iconsax.location, 'Update Location', context),
              _operationItem(Iconsax.document, 'Invoice History', context),
              _operationItem(Iconsax.message_text, 'Complaint History', context),
              _operationItem(Iconsax.box, 'Package Operations', context),
              _operationItem(Icons.tv, 'Deactivate STB', context),
              _operationItem(Iconsax.chart, 'Act-Deact Report', context),
              _operationItem(Iconsax.money_add, 'One Time Charges', context),
              _operationItem(Iconsax.clock1, 'One Time History', context),
              _operationItem(Iconsax.wallet_money, 'Pay Later', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (label == 'Mobile Number' || label == 'LCO Customer id')
                  const Icon(Iconsax.edit, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _operationItem(IconData icon, String label, BuildContext context) {
    return InkWell(
      onTap: () {
        if (label == 'Make Payments') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentOptionsScreen(customer: _customer),
            ),
          );
        } else if (label == 'Update Location') {
          _showUpdateLocationDialog();
        } else {
          // Handle other operations
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateLocationDialog() async {
    final controller = TextEditingController(text: _customer.areaName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter Your Area Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('YES'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final areaName = controller.text.trim();
    if (areaName.isEmpty) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (!mounted) return;
    final previewAccepted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPreviewScreen(
          customerName: _customer.name,
          areaName: areaName,
          location: LatLng(position.latitude, position.longitude),
        ),
      ),
    );

    if (previewAccepted != true || !mounted) return;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Location'),
        content: const Text(
          'Do you want to save this location for this customer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('YES'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    await _db.updateCustomerLocation(
      lcoCustomerId: _customer.lcoCustomerId,
      areaName: areaName,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (!mounted) return;
    setState(() {
      _customer = _customer.copyWith(
        areaName: areaName,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  Future<void> _openCustomerMap() async {
    if (_customer.latitude == null || _customer.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update customer location first')),
      );
      return;
    }

    final current = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerMapScreen(
          customer: _customer,
          currentLocation: LatLng(current.latitude, current.longitude),
        ),
      ),
    );
  }
}
