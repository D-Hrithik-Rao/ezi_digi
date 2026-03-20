class Customer {
  final int? id;
  final String altCustomerId;
  final String name;
  final String primaryMobileNumber;
  final String lcoCustomerId;
  final String crfNumber;
  final String serialNumber;
  final String vcNumber;
  final String nickName;
  final String secondaryMobileNumber;
  final String pendingAmount;
  final String lastPaidDate;
  final String customerType;
  final String address;
  final String groupName;
  final String areaName;
  final String totalDue;
  final String amountPayable;
  final String billMonth;
  final String boxNumber;

  Customer({
    this.id,
    required this.altCustomerId,
    required this.name,
    required this.primaryMobileNumber,
    required this.lcoCustomerId,
    required this.crfNumber,
    required this.serialNumber,
    required this.vcNumber,
    required this.nickName,
    required this.secondaryMobileNumber,
    required this.pendingAmount,
    required this.lastPaidDate,
    required this.customerType,
    required this.address,
    required this.groupName,
    required this.areaName,
    required this.totalDue,
    required this.amountPayable,
    required this.billMonth,
    required this.boxNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'altCustomerId': altCustomerId,
      'name': name,
      'primaryMobileNumber': primaryMobileNumber,
      'lcoCustomerId': lcoCustomerId,
      'crfNumber': crfNumber,
      'serialNumber': serialNumber,
      'vcNumber': vcNumber,
      'nickName': nickName,
      'secondaryMobileNumber': secondaryMobileNumber,
      'pendingAmount': pendingAmount,
      'lastPaidDate': lastPaidDate,
      'customerType': customerType,
      'address': address,
      'groupName': groupName,
      'areaName': areaName,
      'totalDue': totalDue,
      'amountPayable': amountPayable,
      'billMonth': billMonth,
      'boxNumber': boxNumber,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      altCustomerId: map['altCustomerId'] ?? '',
      name: map['name'] ?? '',
      primaryMobileNumber: map['primaryMobileNumber'] ?? '',
      lcoCustomerId: map['lcoCustomerId'] ?? '',
      crfNumber: map['crfNumber'] ?? '',
      serialNumber: map['serialNumber'] ?? '',
      vcNumber: map['vcNumber'] ?? '',
      nickName: map['nickName'] ?? '',
      secondaryMobileNumber: map['secondaryMobileNumber'] ?? '',
      pendingAmount: map['pendingAmount'] ?? '₹0',
      lastPaidDate: map['lastPaidDate'] ?? '',
      customerType: map['customerType'] ?? '',
      address: map['address'] ?? '',
      groupName: map['groupName'] ?? '',
      areaName: map['areaName'] ?? '',
      totalDue: map['totalDue'] ?? '₹0',
      amountPayable: map['amountPayable'] ?? '₹0',
      billMonth: map['billMonth'] ?? '',
      boxNumber: map['boxNumber'] ?? '',
    );
  }
}
