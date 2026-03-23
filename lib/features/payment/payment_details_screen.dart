import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/data/payment.dart';
import '../../core/database/database_helper.dart';
import 'receipt_preview_screen.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final Customer customer;
  final double amount;
  final String paymentMethod;
  final String mobileNumber;
  final bool sendSms;

  const PaymentDetailsScreen({
    super.key,
    required this.customer,
    required this.amount,
    required this.paymentMethod,
    required this.mobileNumber,
    required this.sendSms,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isStoring = false;
  Payment? _payment;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAYMENT DETAILS'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: _shareReceipt,
          ),
          IconButton(
            icon: const Icon(Iconsax.printer),
            onPressed: _showPrintOptions,
          ),
        ],
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
              _buildPaymentInfo(),
              const SizedBox(height: AppSizes.paddingL),
              _buildNextButton(),
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
          _detailRow('Customer Name', widget.customer.name),
          _detailRow('Mobile Number', widget.customer.primaryMobileNumber),
          _detailRow('Total Due', widget.customer.totalDue),
          _detailRow('Amount Payable(STB)', widget.customer.amountPayable),
          _detailRow('Customer Type', widget.customer.customerType),
          _detailRow('Last Paid Date', widget.customer.lastPaidDate),
          _detailRow('Bill Month', widget.customer.billMonth),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PAYMENT INFO'),
          const SizedBox(height: AppSizes.paddingM),
          _detailRow('Amount', '₹${widget.amount.toStringAsFixed(2)}'),
          _detailRow('Payment Method', widget.paymentMethod.toUpperCase()),
          _detailRow('Payment Date',
              DateTime.now().toString().split(' ')[0]),
          if (_payment != null)
            _detailRow('Transaction ID', _payment!.transactionId),
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
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _isStoring ? null : _storePayment,
      child: _isStoring
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('NEXT'),
    );
  }

  Future<void> _storePayment() async {
    setState(() => _isStoring = true);

    try {
      final transactionId = await _dbHelper.generateTransactionId();

      final tempPayment = Payment(
        customerId: widget.customer.lcoCustomerId,
        customerName: widget.customer.name,
        customerMobile: widget.mobileNumber,
        amount: widget.amount,
        paymentMethod: widget.paymentMethod,
        paymentDate: DateTime.now(),
        transactionId: transactionId,
        status: 'completed',
        smsSent: widget.sendSms,
        synced: true,
      );

      final id = await _dbHelper.insertPayment(tempPayment);

      final payment = Payment(
        id: id,
        customerId: widget.customer.lcoCustomerId,
        customerName: widget.customer.name,
        customerMobile: widget.mobileNumber,
        amount: widget.amount,
        paymentMethod: widget.paymentMethod,
        paymentDate: DateTime.now(),
        transactionId: transactionId,
        status: 'completed',
        smsSent: widget.sendSms,
        synced: true,
      );

      setState(() {
        _payment = payment;
        _isStoring = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(
            customer: widget.customer,
            payment: payment,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isStoring = false);
    }
  }

  Future<void> _shareReceipt() async {
    if (_payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store payment first')),
      );
      return;
    }

    final pdf = await _generatePdfReceipt();
    final file = File('${Directory.systemTemp.path}/receipt.pdf');
    await file.writeAsBytes(pdf);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _showPrintOptions() async {
    if (_payment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store payment first')),
      );
      return;
    }

    await _printReceipt();
  }

  Future<void> _printReceipt() async {
    final pdf = await _generatePdfReceipt();

    await Printing.layoutPdf(
      onLayout: (format) => pdf,
    );
  }

  Future<Uint8List> _generatePdfReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt', style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 10),
            pw.Text('Customer: ${widget.customer.name}'),
            pw.Text('Mobile: ${widget.customer.primaryMobileNumber}'),
            pw.Text('Amount: ₹${_payment!.amount.toStringAsFixed(2)}'),
            pw.Text('Method: ${_payment!.paymentMethod}'),
            pw.Text('Txn ID: ${_payment!.transactionId}'),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}