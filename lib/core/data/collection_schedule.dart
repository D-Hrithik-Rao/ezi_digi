class CollectionSchedule {
  final int? id;
  final String customerId;
  final String customerName;
  final String accountNumber;
  final String employee;
  final String status; // Scheduled | Completed
  final DateTime scheduleDate;
  final String remarks;
  final DateTime createdAt;

  const CollectionSchedule({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.accountNumber,
    required this.employee,
    required this.status,
    required this.scheduleDate,
    required this.remarks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'accountNumber': accountNumber,
      'employee': employee,
      'status': status,
      'scheduleDate': _fmtDate(scheduleDate),
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CollectionSchedule fromMap(Map<String, dynamic> map) {
    return CollectionSchedule(
      id: map['id'] as int?,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      employee: map['employee'] as String? ?? '',
      status: map['status'] as String? ?? 'Scheduled',
      scheduleDate: _parseDate(map['scheduleDate'] as String?),
      remarks: map['remarks'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return DateTime.now();
    final dt = DateTime.tryParse(s);
    if (dt != null) return DateTime(dt.year, dt.month, dt.day);
    // fallback if stored as dd-MM-yyyy
    final parts = s.split('-');
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]) ?? 1;
      final b = int.tryParse(parts[1]) ?? 1;
      final c = int.tryParse(parts[2]) ?? 2000;
      // guess format; if first part is year, swap
      if (a > 31) return DateTime(a, b, c);
      return DateTime(c, b, a);
    }
    return DateTime.now();
  }
}

