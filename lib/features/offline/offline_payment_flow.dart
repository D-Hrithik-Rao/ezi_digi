import 'package:flutter/material.dart';

import '../../core/data/customer.dart';
import '../../core/data/payment.dart';
import '../../core/database/database_helper.dart';
import '../payment/receipt_preview_screen.dart';
import 'widgets/offline_payment_dialog.dart';

Future<void> openOfflinePaymentFlow(
  BuildContext context,
  Customer customer,
) async {
  final db = DatabaseHelper();
  final initial =
      customer.amountPayable.replaceAll(RegExp(r'[^0-9.]'), '');
  final result = await showDialog<OfflinePaymentResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => OfflinePaymentDialog(
      customer: customer,
      initialAmount: initial.isEmpty ? '0' : initial,
    ),
  );
  if (result == null || !context.mounted) return;

  final tid = await db.generateTransactionId();
  final payment = Payment(
    customerId: customer.lcoCustomerId,
    customerName: customer.name,
    customerMobile: customer.primaryMobileNumber,
    amount: result.amount,
    paymentMethod: result.method,
    paymentDate: DateTime.now(),
    transactionId: tid,
    status: 'completed',
    smsSent: result.sendSms,
    chequeNo: result.chequeNo,
    bankName: result.bankName,
    branch: result.branch,
    instrumentDate: result.instrumentDate,
    synced: false,
  );

  final id = await db.insertPayment(payment);
  final saved = Payment(
    id: id,
    customerId: payment.customerId,
    customerName: payment.customerName,
    customerMobile: payment.customerMobile,
    amount: payment.amount,
    paymentMethod: payment.paymentMethod,
    paymentDate: payment.paymentDate,
    transactionId: payment.transactionId,
    status: payment.status,
    smsSent: payment.smsSent,
    chequeNo: payment.chequeNo,
    bankName: payment.bankName,
    branch: payment.branch,
    instrumentDate: payment.instrumentDate,
    synced: false,
  );

  if (!context.mounted) return;
  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => ReceiptPreviewScreen(
        customer: customer,
        payment: saved,
        fromOfflineCollection: true,
      ),
    ),
  );
}
