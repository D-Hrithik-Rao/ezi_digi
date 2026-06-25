import '../../../core/config/app_config.dart';
import '../../../core/data/customer.dart';
import '../../../core/network/server_url_resolver.dart';
import '../../../core/network/soap_client.dart';
import '../../../core/services/session_service.dart';

/// Result of a Customer Search (`sc`) call.
class SearchResult {
  final int statusCode; // 0 = ok · non-zero = no records / error
  final String statusMessage;
  final List<Customer> customers;
  const SearchResult(this.statusCode, this.statusMessage, this.customers);
}

/// Customer Search (config key `sc`).
///
/// Android: `SearchCustomer_Fragment_Newdesign` SOAP `searchCustomer`, wrapper
/// element `custInfo` with `i:type="searchCustomerInfo"`. Response repeats
/// `<searchCustomerList>` items. Field names are confirmed from the first real
/// response via the temporary [SC] logs.
class SearchRepository {
  SearchRepository._();
  static final SearchRepository instance = SearchRepository._();

  static String get _imei => AppConfig.deviceImei;

  Future<SearchResult> search({
    required int searchType,
    required String value,
  }) async {
    final ns = ServerUrlResolver.instance.namespace;

    final xml = await SoapClient.instance.call(
      url: ServerUrlResolver.instance.loginServerUrl,
      namespace: ns,
      soapAction: '$ns/searchCustomer',
      methodName: 'searchCustomer',
      wrapper: 'custInfo',
      wrapperType: 'searchCustomerInfo',
      fields: {
        'authToken': SessionService.instance.authToken,
        'imei': _imei,
        'searchType': searchType,
        'searchValue': value,
        'dealer_id': int.tryParse(SessionService.instance.dealerId) ?? 0,
        'is_list': 0,
      },
    );

    final status =
        int.tryParse(SoapClient.readField(xml, 'statusCode') ?? '') ?? 3;
    final message = SoapClient.readField(xml, 'statusMessage') ?? '';
    if (status != 0) {
      return SearchResult(status, message, const []);
    }

    final blocks = SoapClient.readAll(xml, 'searchCustomerList');
    final customers = blocks.map(_fromBlock).toList();
    return SearchResult(status, message, customers);
  }

  // Field names confirmed from a real searchCustomer response (see API doc).
  Customer _fromBlock(String b) {
    String f(String tag) => SoapClient.readField(b, tag) ?? '';
    final total = f('total_amount');
    return Customer(
      altCustomerId: f('customnumber'),
      name: f('name'),
      primaryMobileNumber: f('mobile_no'),
      lcoCustomerId: f('customer_id'),
      crfNumber: f('crf'),
      serialNumber: '',
      vcNumber: f('vc_numbers'),
      nickName: '',
      secondaryMobileNumber: '',
      pendingAmount: total.isEmpty ? '₹0' : '₹$total',
      lastPaidDate: f('last_paid_date'),
      customerType: f('customer_type'),
      address: f('address'),
      groupName: f('group_name'),
      areaName: '',
      totalDue: total.isEmpty ? '₹0' : '₹$total',
      amountPayable: f('pending'),
      billMonth: f('bill_month'),
      boxNumber: f('box_numbers'),
      latitude: double.tryParse(f('latitude')),
      longitude: double.tryParse(f('longitude')),
    );
  }
}
