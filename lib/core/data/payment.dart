class Payment {
  final int? id;
  final String customerId;
  final String customerName;
  final String customerMobile;
  final double amount;
  final String paymentMethod; // 'cash' or 'bank'
  final DateTime paymentDate;
  final String transactionId;
  final String status; // 'pending', 'completed', 'failed'
  final String receiptPath;
  final bool smsSent;

  Payment({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.customerMobile,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    required this.transactionId,
    this.status = 'pending',
    this.receiptPath = '',
    this.smsSent = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerMobile': customerMobile,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'status': status,
      'receiptPath': receiptPath,
      'smsSent': smsSent ? 1 : 0,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerMobile: map['customerMobile'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      paymentDate: DateTime.parse(map['paymentDate'] ?? DateTime.now().toIso8601String()),
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? 'pending',
      receiptPath: map['receiptPath'] ?? '',
      smsSent: (map['smsSent'] ?? 0) == 1,
    );
  }
}
