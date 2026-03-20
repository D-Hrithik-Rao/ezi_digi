import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/customer.dart';
import '../data/payment.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Method to reset database if needed
  Future<void> resetDatabase() async {
    try {
      print('DatabaseHelper: Resetting database...');
      final db = await database;
      await db.delete('payments');
      await db.delete('customers');
      print('DatabaseHelper: Database reset completed');
    } catch (e) {
      print('DatabaseHelper: Error resetting database: $e');
      rethrow;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ezi_cable_digi.db');
    return await openDatabase(
      path,
      version: 2, // Increment version to force table recreation
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('DatabaseHelper: Creating customers table...');
      await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          altCustomerId TEXT NOT NULL,
          name TEXT NOT NULL,
          primaryMobileNumber TEXT,
          lcoCustomerId TEXT,
          crfNumber TEXT,
          serialNumber TEXT,
          vcNumber TEXT,
          nickName TEXT,
          secondaryMobileNumber TEXT,
          pendingAmount TEXT,
          lastPaidDate TEXT,
          customerType TEXT,
          address TEXT,
          groupName TEXT,
          areaName TEXT,
          totalDue TEXT,
          amountPayable TEXT,
          billMonth TEXT,
          boxNumber TEXT
        )
      ''');
      print('DatabaseHelper: Customers table created successfully');

      print('DatabaseHelper: Creating payments table...');
      await db.execute('''
        CREATE TABLE payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId TEXT NOT NULL,
          customerName TEXT NOT NULL,
          customerMobile TEXT,
          amount REAL NOT NULL,
          paymentMethod TEXT NOT NULL,
          paymentDate TEXT NOT NULL,
          transactionId TEXT NOT NULL,
          status TEXT NOT NULL,
          receiptPath TEXT,
          smsSent INTEGER NOT NULL DEFAULT 0
        )
      ''');
      print('DatabaseHelper: Payments table created successfully');
      
      print('DatabaseHelper: All tables created successfully');
    } catch (e) {
      print('DatabaseHelper: Error creating tables: $e');
      print('DatabaseHelper: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DatabaseHelper: Upgrading database from version $oldVersion to $newVersion');
    try {
      if (oldVersion < 2) {
        print('DatabaseHelper: Creating payments table for version 2...');
        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId TEXT NOT NULL,
            customerName TEXT NOT NULL,
            customerMobile TEXT,
            amount REAL NOT NULL,
            paymentMethod TEXT NOT NULL,
            paymentDate TEXT NOT NULL,
            transactionId TEXT NOT NULL,
            status TEXT NOT NULL,
            receiptPath TEXT,
            smsSent INTEGER NOT NULL DEFAULT 0
          )
        ''');
        print('DatabaseHelper: Payments table created in upgrade');
      }
    } catch (e) {
      print('DatabaseHelper: Error upgrading database: $e');
      print('DatabaseHelper: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<List<Customer>> searchCustomers(String criteria, String query) async {
    final db = await database;
    String columnName;
    
    switch (criteria) {
      case 'Alt Customer Id':
        columnName = 'altCustomerId';
        break;
      case 'Name':
        columnName = 'name';
        break;
      case 'Primary Mobile Number':
        columnName = 'primaryMobileNumber';
        break;
      case 'Lco Customer Id':
        columnName = 'lcoCustomerId';
        break;
      case 'CRF Number':
        columnName = 'crfNumber';
        break;
      case 'Serial Number':
        columnName = 'serialNumber';
        break;
      case 'VC Number':
        columnName = 'vcNumber';
        break;
      case 'NickName':
        columnName = 'nickName';
        break;
      case 'Secondary Mobile Number':
        columnName = 'secondaryMobileNumber';
        break;
      default:
        columnName = 'name';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: '$columnName LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertDemoData() async {
    final db = await database;
    
    final List<Customer> demoCustomers = [
      Customer(
        altCustomerId: 'ALT001',
        name: 'Banu',
        primaryMobileNumber: '9876543210',
        lcoCustomerId: 'Banu_21',
        crfNumber: 'CRF001',
        serialNumber: 'SN001',
        vcNumber: 'DR12345705',
        nickName: 'Banu',
        secondaryMobileNumber: '9876543211',
        pendingAmount: '₹0',
        lastPaidDate: '18-02-2026',
        customerType: 'STB',
        address: 'Hyde',
        groupName: 'DEFAULT',
        areaName: 'NA',
        totalDue: '₹24770',
        amountPayable: '₹0',
        billMonth: '01-07-2023',
        boxNumber: 'DR12345705',
      ),
      Customer(
        altCustomerId: 'ALT002',
        name: 'Bharathi',
        primaryMobileNumber: '9876543220',
        lcoCustomerId: 'Bharathi_22',
        crfNumber: 'CRF002',
        serialNumber: 'SN002',
        vcNumber: 'DR12345706',
        nickName: 'Bharu',
        secondaryMobileNumber: '9876543221',
        pendingAmount: '₹500',
        lastPaidDate: '15-02-2026',
        customerType: 'STB',
        address: 'Chennai',
        groupName: 'DEFAULT',
        areaName: 'Area1',
        totalDue: '₹15000',
        amountPayable: '₹500',
        billMonth: '01-07-2023',
        boxNumber: 'DR12345706',
      ),
      Customer(
        altCustomerId: 'ALT003',
        name: 'Chandru',
        primaryMobileNumber: '9876543230',
        lcoCustomerId: 'Chandru_23',
        crfNumber: 'CRF003',
        serialNumber: 'SN003',
        vcNumber: 'DR12345707',
        nickName: 'Chan',
        secondaryMobileNumber: '9876543231',
        pendingAmount: '₹1000',
        lastPaidDate: '10-02-2026',
        customerType: 'STB',
        address: 'Bangalore',
        groupName: 'DEFAULT',
        areaName: 'Area2',
        totalDue: '₹20000',
        amountPayable: '₹1000',
        billMonth: '01-07-2023',
        boxNumber: 'DR12345707',
      ),
      Customer(
        altCustomerId: 'ALT004',
        name: 'Deepak',
        primaryMobileNumber: '9876543240',
        lcoCustomerId: 'Deepak_24',
        crfNumber: 'CRF004',
        serialNumber: 'SN004',
        vcNumber: 'DR12345708',
        nickName: 'Deep',
        secondaryMobileNumber: '9876543241',
        pendingAmount: '₹0',
        lastPaidDate: '20-02-2026',
        customerType: 'STB',
        address: 'Hyderabad',
        groupName: 'DEFAULT',
        areaName: 'Area3',
        totalDue: '₹10000',
        amountPayable: '₹0',
        billMonth: '01-07-2023',
        boxNumber: 'DR12345708',
      ),
      Customer(
        altCustomerId: 'ALT005',
        name: 'Eswar',
        primaryMobileNumber: '9876543250',
        lcoCustomerId: 'Eswar_25',
        crfNumber: 'CRF005',
        serialNumber: 'SN005',
        vcNumber: 'DR12345709',
        nickName: 'Eswar',
        secondaryMobileNumber: '9876543251',
        pendingAmount: '₹750',
        lastPaidDate: '12-02-2026',
        customerType: 'STB',
        address: 'Mumbai',
        groupName: 'DEFAULT',
        areaName: 'Area4',
        totalDue: '₹30000',
        amountPayable: '₹750',
        billMonth: '01-07-2023',
        boxNumber: 'DR12345709',
      ),
    ];

    for (final customer in demoCustomers) {
      await db.insert('customers', customer.toMap());
    }
  }

  Future<int> insertPayment(Payment payment) async {
    try {
      print('DatabaseHelper: Inserting payment...');
      print('DatabaseHelper: Payment data: ${payment.toMap()}');
      
      final db = await database;
      print('DatabaseHelper: Got database instance');
      
      // Check if payments table exists
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='payments'");
      print('DatabaseHelper: Tables found: $tables');
      
      if (tables.isEmpty) {
        print('DatabaseHelper: Payments table does not exist, creating it...');
        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId TEXT NOT NULL,
            customerName TEXT NOT NULL,
            customerMobile TEXT,
            amount REAL NOT NULL,
            paymentMethod TEXT NOT NULL,
            paymentDate TEXT NOT NULL,
            transactionId TEXT NOT NULL,
            status TEXT NOT NULL,
            receiptPath TEXT,
            smsSent INTEGER NOT NULL DEFAULT 0
          )
        ''');
        print('DatabaseHelper: Payments table created manually');
      }
      
      final result = await db.insert('payments', payment.toMap());
      print('DatabaseHelper: Insert result: $result');
      
      if (result <= 0) {
        print('DatabaseHelper: ERROR - Insert failed, result: $result');
        throw Exception('Failed to insert payment - database returned $result');
      }
      
      print('DatabaseHelper: Payment inserted successfully with ID: $result');
      return result;
    } catch (e) {
      print('DatabaseHelper: Error inserting payment: $e');
      print('DatabaseHelper: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Payment>> getPaymentsByCustomerId(String customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<String> generateTransactionId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().second.toString().padLeft(2, '0');
    return 'TXN$timestamp$random';
  }

  Future<int> getCurrentMonthPaymentCount(String customerId) async {
    final db = await database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'customerId = ? AND paymentDate >= ? AND paymentDate <= ?',
      whereArgs: [
        customerId,
        firstDayOfMonth.toIso8601String(),
        lastDayOfMonth.toIso8601String(),
      ],
    );

    return maps.length;
  }
}
