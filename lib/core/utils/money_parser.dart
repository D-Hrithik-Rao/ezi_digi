/// Parses amounts like "₹658.0", "₹0", "658" to a double.
double? parseMoneyAmount(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

bool isUnpaidCustomer({
  required String amountPayable,
  String? pendingAmount,
}) {
  final payable = parseMoneyAmount(amountPayable) ?? 0;
  final pending = parseMoneyAmount(pendingAmount) ?? 0;
  return payable > 0 || pending > 0;
}
