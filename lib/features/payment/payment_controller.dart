import 'package:flutter/material.dart';

import '../../core/data/collection_schedule.dart';
import '../../core/data/customer.dart';
import '../../core/data/payment.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/error_handler_service.dart';
import 'data/pending_amount_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PaymentController — ChangeNotifier for PaymentOptionsScreen
// Owns all mutable state: method, fields, loading flag, date.
// Screens use ListenableBuilder to rebuild when notifyListeners() is called.
// ─────────────────────────────────────────────────────────────────────────────
class PaymentController extends ChangeNotifier {
  final Customer customer;
  final DatabaseHelper _db;

  PaymentController({required this.customer, DatabaseHelper? db})
      : _db = db ?? DatabaseHelper();

  // ── TextEditingControllers ──────────────────────────────────────────────────
  final amountCtrl    = TextEditingController();
  final discountCtrl  = TextEditingController();
  final remarksCtrl   = TextEditingController();
  final mobileCtrl    = TextEditingController();
  final chequeNoCtrl  = TextEditingController();
  final bankNameCtrl  = TextEditingController();
  final branchCtrl    = TextEditingController();
  final upiIdCtrl     = TextEditingController();

  // ── State fields ────────────────────────────────────────────────────────────
  String    _paymentMethod    = 'cash';
  bool      _sendSms          = false;
  DateTime? _instrumentDate;
  bool      _isStoring        = false;

  // gpa — live pending amount fetched when the payment screen opens
  double  pendingAmount  = 0;
  bool    pendingLoading = false;
  String? pendingError;

  String    get paymentMethod   => _paymentMethod;
  bool      get sendSms         => _sendSms;
  DateTime? get instrumentDate  => _instrumentDate;
  bool      get isStoring       => _isStoring;

  void setPaymentMethod(String v) {
    if (_paymentMethod == v) return;
    _paymentMethod = v;
    notifyListeners();
  }

  void setSendSms(bool v) {
    _sendSms = v;
    notifyListeners();
  }

  void setInstrumentDate(DateTime? d) {
    _instrumentDate = d;
    notifyListeners();
  }

  void _setStoring(bool v) {
    _isStoring = v;
    notifyListeners();
  }

  /// gpa: fetch the live pending amount and prefill the amount field.
  /// altCustomerId = the customer's customer_id (stored in lcoCustomerId).
  Future<void> loadPendingAmount() async {
    pendingLoading = true;
    pendingError = null;
    notifyListeners();
    try {
      final id = int.tryParse(customer.lcoCustomerId) ?? 0;
      final result = await PendingAmountRepository.instance.fetch(id);
      debugPrint('[GPA] altCustomerId=$id statusCode=${result.statusCode} '
          'pendingAmount=${result.pendingAmount} msg=${result.statusMessage}'); // TEMP
      if (result.statusCode == 0) {
        pendingAmount = result.pendingAmount;
        amountCtrl.text = pendingAmount.toStringAsFixed(2);
      } else {
        pendingError = result.statusMessage;
      }
    } catch (e, s) {
      pendingError = 'Failed to load pending amount';
      ErrorHandlerService.recordError(e, s,
          reason: 'PaymentController.loadPendingAmount');
    } finally {
      pendingLoading = false;
      notifyListeners();
    }
  }

  // ── Validation ──────────────────────────────────────────────────────────────
  String? validate() {
    if (amountCtrl.text.isEmpty) return 'Please enter amount';
    final amount = double.tryParse(amountCtrl.text);
    if (amount == null || amount <= 0) return 'Please enter a valid amount';

    if (_paymentMethod == 'bank') {
      if (chequeNoCtrl.text.trim().isEmpty) return 'Please enter Cheque / DD number';
      if (bankNameCtrl.text.trim().isEmpty) return 'Please enter bank name';
      if (branchCtrl.text.trim().isEmpty)   return 'Please enter branch';
      if (_instrumentDate == null)           return 'Please select instrument date';
    }
    if (_paymentMethod == 'upi') {
      if (upiIdCtrl.text.trim().isEmpty) return 'Please enter UPI Id';
    }
    return null;
  }

  double get parsedAmount => double.tryParse(amountCtrl.text) ?? 0.0;

  // ── Pay Now ─────────────────────────────────────────────────────────────────
  /// Returns the saved [Payment] on success, null on failure/cancel.
  /// Callers must handle showing dialogs — controller is pure logic.
  Future<Payment?> pay() async {
    _setStoring(true);
    try {
      final txnId  = await _db.generateTransactionId();
      final mobile = mobileCtrl.text.isEmpty
          ? customer.primaryMobileNumber
          : mobileCtrl.text;
      final instrStr = _instrumentDate != null
          ? '${_instrumentDate!.day.toString().padLeft(2, '0')}-'
            '${_instrumentDate!.month.toString().padLeft(2, '0')}-'
            '${_instrumentDate!.year}'
          : '';

      final tempPayment = Payment(
        customerId:     customer.lcoCustomerId,
        customerName:   customer.name,
        customerMobile: mobile,
        amount:         parsedAmount,
        paymentMethod:  _paymentMethod,
        paymentDate:    DateTime.now(),
        transactionId:  txnId,
        status:         'completed',
        smsSent:        _sendSms,
        chequeNo:       chequeNoCtrl.text.trim(),
        bankName:       bankNameCtrl.text.trim(),
        branch:         branchCtrl.text.trim(),
        instrumentDate: instrStr,
        synced:         true,
      );

      final id = await _db.insertPayment(tempPayment);

      final payment = Payment(
        id:             id,
        customerId:     customer.lcoCustomerId,
        customerName:   customer.name,
        customerMobile: mobile,
        amount:         parsedAmount,
        paymentMethod:  _paymentMethod,
        paymentDate:    DateTime.now(),
        transactionId:  txnId,
        status:         'completed',
        smsSent:        _sendSms,
        chequeNo:       chequeNoCtrl.text.trim(),
        bankName:       bankNameCtrl.text.trim(),
        branch:         branchCtrl.text.trim(),
        instrumentDate: instrStr,
        synced:         true,
      );

      // Fire notification (non-blocking)
      NotificationService.showPaymentNotification(
        title: 'Payment Successful',
        body: '₹${parsedAmount.toStringAsFixed(2)} received from ${customer.name}',
      );

      return payment;
    } catch (_) {
      rethrow;
    } finally {
      _setStoring(false);
    }
  }

  // ── Pay Later (collection schedule) ─────────────────────────────────────────
  Future<CollectionSchedule> schedulePayLater({
    required DateTime scheduleDate,
    required String   status,
    required String   employee,
    required String   remarks,
  }) async {
    final schedule = CollectionSchedule(
      customerId:    customer.lcoCustomerId,
      customerName:  customer.name,
      accountNumber: customer.lcoCustomerId,
      employee:      employee == 'Choose' ? '' : employee,
      status:        status,
      scheduleDate:  DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day),
      remarks:       remarks,
      createdAt:     DateTime.now(),
    );
    await _db.insertCollectionSchedule(schedule);
    return schedule;
  }

  // ── Dispose ─────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    for (final c in [
      amountCtrl, discountCtrl, remarksCtrl, mobileCtrl,
      chequeNoCtrl, bankNameCtrl, branchCtrl, upiIdCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
