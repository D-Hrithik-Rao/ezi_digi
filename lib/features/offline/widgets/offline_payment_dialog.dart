import 'package:flutter/material.dart';

import '../../../core/data/customer.dart';

class OfflinePaymentResult {
  final double amount;
  final String method;
  final bool sendSms;
  final String chequeNo;
  final String bankName;
  final String branch;
  final String instrumentDate;

  OfflinePaymentResult({
    required this.amount,
    required this.method,
    required this.sendSms,
    required this.chequeNo,
    required this.bankName,
    required this.branch,
    required this.instrumentDate,
  });
}

class OfflinePaymentDialog extends StatefulWidget {
  final Customer customer;
  final String initialAmount;

  const OfflinePaymentDialog({
    super.key,
    required this.customer,
    required this.initialAmount,
  });

  @override
  State<OfflinePaymentDialog> createState() => _OfflinePaymentDialogState();
}

class _OfflinePaymentDialogState extends State<OfflinePaymentDialog> {
  late final TextEditingController _amountCtrl;
  final _chequeCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _branchCtrl = TextEditingController();
  String _method = 'cash';
  bool _sendSms = false;
  DateTime? _instrumentDate;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.initialAmount);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _chequeCtrl.dispose();
    _bankCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _instrumentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _instrumentDate = d);
  }

  void _submit() {
    final amt = double.tryParse(_amountCtrl.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid amount')),
      );
      return;
    }
    if (_method == 'bank') {
      if (_chequeCtrl.text.trim().isEmpty ||
          _bankCtrl.text.trim().isEmpty ||
          _branchCtrl.text.trim().isEmpty ||
          _instrumentDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all bank fields')),
        );
        return;
      }
    }
    Navigator.pop(
      context,
      OfflinePaymentResult(
        amount: amt,
        method: _method,
        sendSms: _sendSms,
        chequeNo: _chequeCtrl.text.trim(),
        bankName: _bankCtrl.text.trim(),
        branch: _branchCtrl.text.trim(),
        instrumentDate: _instrumentDate?.toIso8601String() ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Are you sure?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Please select an option and enter amount below',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('CASH'),
                    value: 'cash',
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v ?? 'cash'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('BANK'),
                    value: 'bank',
                    groupValue: _method,
                    onChanged: (v) => setState(() => _method = v ?? 'bank'),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text('Please enter amount below:'),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
            if (_method == 'bank') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _chequeCtrl,
                decoration: const InputDecoration(
                  labelText: '* Cheque/DD No',
                ),
              ),
              TextField(
                controller: _bankCtrl,
                decoration: const InputDecoration(
                  labelText: '* Bank Name',
                ),
              ),
              TextField(
                controller: _branchCtrl,
                decoration: const InputDecoration(
                  labelText: '* Branch',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('* Instrument Date'),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('SELECT'),
                  ),
                ],
              ),
            ],
            CheckboxListTile(
              value: _sendSms,
              onChanged: (v) => setState(() => _sendSms = v ?? false),
              title: const Text('Send SMS'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: _submit,
                  child: const Text(
                    'DONE AND PAY',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
