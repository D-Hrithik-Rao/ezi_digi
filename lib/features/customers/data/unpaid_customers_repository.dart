import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/data/customer.dart';
import '../../../core/network/server_url_resolver.dart';
import '../../../core/network/soap_client.dart';
import '../../../core/services/session_service.dart';

/// Result of a Customer List (`uc`) call.
class UnpaidResult {
  final int statusCode; // 0 = ok · 1 = no records · 3/other = failed
  final String statusMessage;
  final List<Customer> customers;
  const UnpaidResult(this.statusCode, this.statusMessage, this.customers);
}

/// Customer List / Unpaid Customers (config key `uc`).
///
/// Android: `Unpaid_Fragment` SOAP `unpaidCustomers`, wrapper element
/// `outstandinginfo` with `i:type="n0:unpaidCustomers"`. Returns the FULL list
/// (no pagination). Response: `statusCode`, `statusMessage`, and `unpaidcustomers`
/// — a JSON-string array (same double-encoding as `group_details`).
class UnpaidCustomersRepository {
  UnpaidCustomersRepository._();
  static final UnpaidCustomersRepository instance = UnpaidCustomersRepository._();

  static String get _imei => AppConfig.deviceImei;

  Future<UnpaidResult> fetch({
    required int customerStatus,
    required int stbStatus,
    required int unpaidListType,
    required int groupId,
    required String billMonth,
  }) async {
    final ns = ServerUrlResolver.instance.namespace;

    final xml = await SoapClient.instance.call(
      url: ServerUrlResolver.instance.loginServerUrl,
      namespace: ns,
      soapAction: '$ns/unpaidCustomers',
      methodName: 'unpaidCustomers',
      wrapper: 'outstandinginfo',
      wrapperType: 'unpaidCustomers',
      fields: {
        'authToken': SessionService.instance.authToken,
        'imei': _imei,
        'billmonth': billMonth,
        'customerstatus': customerStatus,
        'stbstatus': stbStatus,
        'unpaidlist_type': unpaidListType,
        'group_id': groupId,
        'from_dashboard': '0',
      },
    );

    final status =
        int.tryParse(SoapClient.readField(xml, 'statusCode') ?? '') ?? 3;
    final message = SoapClient.readField(xml, 'statusMessage') ?? '';
    debugPrint('[UC] statusCode=$status statusMessage=$message'); // TEMP
    if (status != 0) {
      return UnpaidResult(status, message, const []);
    }

    // unpaidcustomers is a JSON string holding the array (Android double-encodes).
    final raw = SoapClient.readField(xml, 'unpaidcustomers') ?? '[]';
    final decoded = jsonDecode(raw);
    final customers = <Customer>[];
    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map) {
          customers.add(Customer.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    debugPrint('[UC] parsed ${customers.length} customers: '
        '${customers.map((c) => c.name).toList()}'); // TEMP
    return UnpaidResult(status, message, customers);
  }
}
