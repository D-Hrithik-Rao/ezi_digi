import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/notification_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/data/payment.dart';
import '../../core/database/database_helper.dart';
import '../../core/theme/theme_constants.dart';
import '../../core/widgets/premium_dialog.dart';
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
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: _buildAppBar(t),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCustomerInfoCard(t),
            const SizedBox(height: AppSizes.paddingM),
            _buildPaymentInfoCard(t),
            const SizedBox(height: AppSizes.paddingL),
            _buildNextButton(t),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(AppThemeConst t) {
    return AppBar(
      backgroundColor: t.appBarBg,
      foregroundColor: t.appBarFg,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: t.backBtnBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.arrow_back_ios_new, size: 16, color: t.backBtnIcon),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'PAYMENT DETAILS',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: t.appBarFg,
        ),
      ),
      actions: [
        if (_payment != null) ...[
          IconButton(
            icon: const Icon(Iconsax.share, size: 20),
            onPressed: _shareReceipt,
          ),
          IconButton(
            icon: const Icon(Iconsax.printer, size: 20),
            onPressed: _showPrintOptions,
          ),
        ],
      ],
    );
  }

  // ── Customer Info Card ────────────────────────────────────────────────────
  Widget _buildCustomerInfoCard(AppThemeConst t) {
    return _InfoCard(
      t: t,
      title: 'CUSTOMER INFO',
      rows: [
        ('Customer Name',      widget.customer.name),
        ('Mobile Number',      widget.customer.primaryMobileNumber),
        ('Total Due',          widget.customer.totalDue),
        ('Amount Payable(STB)', widget.customer.amountPayable),
        ('Customer Type',      widget.customer.customerType),
        ('Last Paid Date',     widget.customer.lastPaidDate),
        ('Bill Month',         widget.customer.billMonth),
      ],
    );
  }

  // ── Payment Info Card ─────────────────────────────────────────────────────
  Widget _buildPaymentInfoCard(AppThemeConst t) {
    return _InfoCard(
      t: t,
      title: 'PAYMENT INFO',
      rows: [
        ('Amount',         '₹${widget.amount.toStringAsFixed(2)}'),
        ('Method',         widget.paymentMethod.toUpperCase()),
        ('Payment Date',   DateTime.now().toString().split(' ')[0]),
        if (_payment != null)
          ('Transaction ID', _payment!.transactionId),
      ],
    );
  }

  // ── Next / Store Button ───────────────────────────────────────────────────
  Widget _buildNextButton(AppThemeConst t) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isStoring ? null : _storePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
        ),
        child: const Text(
          'CONFIRM & GENERATE RECEIPT',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ── Store Payment ─────────────────────────────────────────────────────────
  Future<void> _storePayment() async {
    // Premium confirmation
    final confirmed = await showPremiumConfirm(
      context: context,
      title: 'Confirm Payment',
      body: 'Save ₹${widget.amount.toStringAsFixed(2)} payment for ${widget.customer.name}?',
      confirmLabel: 'CONFIRM',
    );
    if (!confirmed || !mounted) return;

    // Show loading
    showPremiumLoading(context, message: 'Saving payment...');
    setState(() => _isStoring = true);

    try {
      final transactionId = await _dbHelper.generateTransactionId();

      final id = await _dbHelper.insertPayment(
        Payment(
          customerId:     widget.customer.lcoCustomerId,
          customerName:   widget.customer.name,
          customerMobile: widget.mobileNumber,
          amount:         widget.amount,
          paymentMethod:  widget.paymentMethod,
          paymentDate:    DateTime.now(),
          transactionId:  transactionId,
          status:         'completed',
          smsSent:        widget.sendSms,
          synced:         true,
        ),
      );

      final payment = Payment(
        id:             id,
        customerId:     widget.customer.lcoCustomerId,
        customerName:   widget.customer.name,
        customerMobile: widget.mobileNumber,
        amount:         widget.amount,
        paymentMethod:  widget.paymentMethod,
        paymentDate:    DateTime.now(),
        transactionId:  transactionId,
        status:         'completed',
        smsSent:        widget.sendSms,
        synced:         true,
      );

      if (mounted) setState(() { _payment = payment; _isStoring = false; });

      // Fire notification (non-blocking)
      NotificationService.showPaymentNotification(
        title: 'Payment Successful',
        body: '₹${widget.amount.toStringAsFixed(2)} received from ${widget.customer.name}',
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      // Success popup
      await showPremiumDialog<void>(
        context: context,
        barrierDismissible: false,
        child: PremiumDialogShell(
          onClose: () => Navigator.of(context).pop(),
          child: _SuccessContent(
            amount: widget.amount,
            customerName: widget.customer.name,
            txnId: transactionId,
            onContinue: () => Navigator.of(context).pop(),
          ),
        ),
      );

      if (!mounted) return;
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
      if (mounted) {
        setState(() => _isStoring = false);
        Navigator.of(context).pop(); // dismiss loading
        showPremiumSnackBar(context, 'Payment failed: $e', isError: true);
      }
    }
  }

  // ── Share / Print ─────────────────────────────────────────────────────────
  Future<void> _shareReceipt() async {
    if (_payment == null) return;
    showPremiumLoading(context, message: 'Generating PDF...');
    try {
      final pdf  = await _generatePdfReceipt();
      final file = File('${Directory.systemTemp.path}/receipt.pdf');
      await file.writeAsBytes(pdf);
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showPremiumSnackBar(context, 'Share failed: $e', isError: true);
      }
    }
  }

  Future<void> _showPrintOptions() async {
    if (_payment == null) return;
    showPremiumLoading(context, message: 'Preparing print...');
    try {
      final pdf = await _generatePdfReceipt();
      if (!mounted) return;
      Navigator.of(context).pop();
      await Printing.layoutPdf(onLayout: (format) => pdf);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showPremiumSnackBar(context, 'Print failed: $e', isError: true);
      }
    }
  }

  Future<Uint8List> _generatePdfReceipt() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt'),
            pw.Text('Customer: ${widget.customer.name}'),
            pw.Text('Amount: ₹${_payment!.amount}'),
          ],
        ),
      ),
    );
    return pdf.save();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _InfoCard
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final AppThemeConst t;
  final String title;
  final List<(String, String)> rows;
  const _InfoCard({required this.t, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [BoxShadow(color: t.cardShadowColor, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: t.headerGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusM)),
            ),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: rows.map((r) => _DetailRow(label: r.$1, value: r.$2, t: t)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeConst t;
  const _DetailRow({required this.label, required this.value, required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: t.cardSubtitleText)),
          ),
          Expanded(
            flex: 5,
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.cardBodyText)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SuccessContent
// ─────────────────────────────────────────────────────────────────────────────
class _SuccessContent extends StatelessWidget {
  final double amount;
  final String customerName;
  final String txnId;
  final VoidCallback onContinue;
  const _SuccessContent({required this.amount, required this.customerName, required this.txnId, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          const Text('Payment Saved!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1A3C6E))),
          const SizedBox(height: 4),
          Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0277BD))),
          const SizedBox(height: 2),
          Text(customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(20)),
            child: Text(txnId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('VIEW RECEIPT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
