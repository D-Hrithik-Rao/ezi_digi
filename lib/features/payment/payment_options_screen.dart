import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/data/customer.dart';
import '../../core/theme/theme_constants.dart';
import '../../core/widgets/premium_dialog.dart';
import 'payment_confirmation_dialog.dart';
import 'payment_controller.dart';
import 'receipt_preview_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PaymentOptionsScreen — backed by PaymentController (ChangeNotifier)
// ─────────────────────────────────────────────────────────────────────────────
class PaymentOptionsScreen extends StatefulWidget {
  final Customer customer;
  const PaymentOptionsScreen({super.key, required this.customer});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen>
    with SingleTickerProviderStateMixin {
  late final PaymentController _ctrl;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = PaymentController(customer: widget.customer);
    _ctrl.loadPendingAmount(); // gpa → prefill the amount with the live due amount
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Pick date ────────────────────────────────────────────────────────────────
  Future<void> _pickInstrumentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _ctrl.setInstrumentDate(picked);
  }

  // ── Pay Now ──────────────────────────────────────────────────────────────────
  Future<void> _handlePay() async {
    final error = _ctrl.validate();
    if (error != null) {
      showPremiumSnackBar(context, error, isError: true);
      return;
    }

    // Premium detailed confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentConfirmationDialog(
        customer: widget.customer,
        amount: _ctrl.parsedAmount,
        paymentMethod: '',
      ),
    ) ?? false;
    
    if (!confirmed || !mounted) return;

    // Show loading
    showPremiumLoading(context, message: 'Processing payment...');

    try {
      final payment = await _ctrl.pay();
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      if (payment == null) {
        showPremiumSnackBar(context, 'Payment could not be saved', isError: true);
        return;
      }

      // Success popup before navigating
      await showPremiumDialog<void>(
        context: context,
        barrierDismissible: false,
        child: PremiumDialogShell(
          onClose: () => Navigator.of(context).pop(),
          child: _PaymentSuccessContent(
            amount: payment.amount,
            customerName: widget.customer.name,
            txnId: payment.transactionId,
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
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      showPremiumSnackBar(context, 'Payment failed: $e', isError: true);
    }
  }

  // ── Pay Later ────────────────────────────────────────────────────────────────
  Future<void> _handlePayLater() async {
    final remarksCtrl    = TextEditingController();
    DateTime scheduleDate = DateTime.now();
    String status        = 'Scheduled';
    String employee      = 'Choose';

    final ok = await showPremiumDialog<bool>(
      context: context,
      child: PremiumDialogShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: StatefulBuilder(
            builder: (ctx, setD) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.clock, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Schedule Collection',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Customer pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.user, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          widget.customer.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status + Date row
                  Row(
                    children: [
                      Expanded(
                        child: _CompactDropdown<String>(
                          hint: 'Status',
                          value: status,
                          items: const ['Scheduled', 'Completed'],
                          onChanged: (v) { if (v != null) setD(() => status = v); },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: scheduleDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) setD(() => scheduleDate = picked);
                          },
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 15, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  '${scheduleDate.day.toString().padLeft(2, '0')}-'
                                  '${scheduleDate.month.toString().padLeft(2, '0')}-'
                                  '${scheduleDate.year}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Employee
                  _CompactDropdown<String>(
                    hint: 'Select Employee',
                    value: employee,
                    items: const ['Choose', 'itp'],
                    onChanged: (v) { if (v != null) setD(() => employee = v); },
                  ),
                  const SizedBox(height: 10),
                  // Remarks
                  TextField(
                    controller: remarksCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Remarks (optional)',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('CANCEL', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('SCHEDULE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (ok != true || !mounted) return;

    // Show loading
    showPremiumLoading(context, message: 'Scheduling collection...');
    try {
      await _ctrl.schedulePayLater(
        scheduleDate: scheduleDate,
        status: status,
        employee: employee,
        remarks: remarksCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading
      showPremiumSnackBar(context, 'Collection scheduled successfully', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showPremiumSnackBar(context, 'Scheduling failed: $e', isError: true);
    } finally {
      remarksCtrl.dispose();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = AppThemeConst.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBg,
      appBar: _buildAppBar(t),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: _CustomerInfoCard(customer: widget.customer, t: t),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: AppSizes.paddingL),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _GlassCard(
                        t: t,
                        child: _buildPaymentForm(t),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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
        'PAYMENT',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: t.appBarFg,
        ),
      ),
    );
  }

  Widget _buildPaymentForm(AppThemeConst t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(label: 'PAYMENT OPTIONS', t: t),
        const SizedBox(height: 10),

        // Payment mode dropdown
        Container(
          decoration: BoxDecoration(
            color: t.inputBg,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: t.inputBorderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _ctrl.paymentMethod,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.cardBodyText),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'bank', child: Text('Bank / Cheque')),
                DropdownMenuItem(value: 'upi',  child: Text('UPI')),
              ],
              onChanged: (v) { if (v != null) _ctrl.setPaymentMethod(v); },
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Discount
        _CompactField(
          controller: _ctrl.discountCtrl,
          hint: 'Discount amount (₹)',
          t: t,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 10),

        // Amount
        _CompactField(
          controller: _ctrl.amountCtrl,
          hint: 'Amount to collect (₹) *',
          t: t,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          highlightColor: _ctrl.paymentMethod == 'bank' ? const Color(0xFFF59E0B) : null,
        ),

        // ── Bank-only fields ─────────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _ctrl.paymentMethod == 'bank'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _CompactField(controller: _ctrl.chequeNoCtrl, hint: 'Cheque / DD number *', t: t),
                    const SizedBox(height: 10),
                    _CompactField(controller: _ctrl.bankNameCtrl, hint: 'Bank name *', t: t),
                    const SizedBox(height: 10),
                    _CompactField(controller: _ctrl.branchCtrl, hint: 'Branch *', t: t),
                    const SizedBox(height: 10),
                    _DatePickerField(
                      date: _ctrl.instrumentDate,
                      t: t,
                      onTap: _pickInstrumentDate,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // ── UPI-only fields ──────────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _ctrl.paymentMethod == 'upi'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _CompactField(controller: _ctrl.upiIdCtrl, hint: 'UPI ID *', t: t),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 10),

        // Remarks & Mobile (hint only — no separate label)
        _CompactField(
          controller: _ctrl.remarksCtrl,
          hint: 'Remarks (optional)',
          t: t,
        ),
        const SizedBox(height: 10),
        _CompactField(
          controller: _ctrl.mobileCtrl,
          hint: widget.customer.primaryMobileNumber.isEmpty
              ? 'Alternate mobile (optional)'
              : 'Alt: ${widget.customer.primaryMobileNumber}',
          t: t,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),

        // SMS toggle
        _SmsToggle(
          value: _ctrl.sendSms,
          onChanged: _ctrl.setSendSms,
        ),
        const SizedBox(height: 16),

        // Buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _ctrl.isStoring ? null : _handlePay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                  ),
                  child: const Text('PAY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _ctrl.isStoring ? null : _handlePayLater,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.backBtnBg,
                    foregroundColor: t.appBarFg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                  ),
                  child: Text('PAY LATER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: t.accent)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Success Content
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentSuccessContent extends StatelessWidget {
  final double amount;
  final String customerName;
  final String txnId;
  final VoidCallback onContinue;

  const _PaymentSuccessContent({
    required this.amount,
    required this.customerName,
    required this.txnId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Colors.green.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          const Text('Payment Successful!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A3C6E))),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0277BD)),
          ),
          const SizedBox(height: 4),
          Text(customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(txnId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('VIEW RECEIPT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Customer Info Card — compact
// ─────────────────────────────────────────────────────────────────────────────
class _CustomerInfoCard extends StatelessWidget {
  final Customer customer;
  final AppThemeConst t;
  const _CustomerInfoCard({required this.customer, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [BoxShadow(color: t.cardShadowColor, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: t.headerGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.user, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: t.cardHeadingText)),
                    Text(customer.lcoCustomerId, style: TextStyle(fontSize: 11, color: t.cardSubtitleText, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.accent.withValues(alpha: 0.25)),
                ),
                child: Text(customer.customerType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: t.accent)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: t.dividerColor),
          const SizedBox(height: 8),
          _infoGrid(customer, t),
        ],
      ),
    );
  }

  Widget _infoGrid(Customer c, AppThemeConst t) {
    final items = [
      ('Mobile', c.primaryMobileNumber),
      ('Total Due', c.totalDue),
      ('Payable (STB)', c.amountPayable),
      ('Last Paid', c.lastPaidDate),
      ('Bill Month', c.billMonth),
      ('Type', c.customerType),
    ];
    return Column(
      children: items
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        e.$1,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t.cardSubtitleText),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        e.$2,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.cardBodyText),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlassCard
// ─────────────────────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final AppThemeConst t;
  const _GlassCard({required this.child, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [BoxShadow(color: t.cardShadowColor, blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final AppThemeConst t;
  const _SectionHeader({required this.label, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: t.headerGradient, begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CompactField — hint-only, no label above
// ─────────────────────────────────────────────────────────────────────────────
class _CompactField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final AppThemeConst t;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? highlightColor;

  const _CompactField({
    required this.controller,
    required this.hint,
    required this.t,
    this.keyboardType,
    this.inputFormatters,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = highlightColor ?? t.accent;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.cardBodyText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: t.inputHintColor, fontWeight: FontWeight.w400, fontSize: 12),
        filled: true,
        fillColor: t.inputBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: t.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: t.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CompactDropdown — simple compact dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _CompactDropdown<T> extends StatelessWidget {
  final String hint;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _CompactDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          items: items.map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(e.toString()),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DatePickerField
// ─────────────────────────────────────────────────────────────────────────────
class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  final AppThemeConst t;
  const _DatePickerField({required this.date, required this.onTap, required this.t});

  @override
  Widget build(BuildContext context) {
    final label = date != null
        ? '${date!.day.toString().padLeft(2, '0')}-'
          '${date!.month.toString().padLeft(2, '0')}-'
          '${date!.year}'
        : 'Instrument Date *';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: t.inputBg,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          border: Border.all(color: t.inputBorderColor),
        ),
        child: Row(
          children: [
            Icon(Iconsax.calendar_1, color: t.accent, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: date != null ? t.cardBodyText : t.inputHintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SmsToggle
// ─────────────────────────────────────────────────────────────────────────────
class _SmsToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SmsToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.textSecondary,
                width: 1.8,
              ),
            ),
            child: value ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
          ),
          const SizedBox(width: 8),
          const Text(
            'Send SMS',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}