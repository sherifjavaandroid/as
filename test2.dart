// sensitive_data_manager.dart - مثال على تسريب البيانات الحساسة
import 'dart:io';
import 'dart:convert';
import 'dart:math';

class SensitiveDataManager {
  // مشكلة أمنية: تخزين بيانات حساسة في النص الخام
  static const String API_KEY = "sk-1234567890abcdef1234567890abcdef";
  static const String DATABASE_PASSWORD = "MySecretPassword123!";
  static const String JWT_SECRET = "super_secret_jwt_key_2024";
  static const String ENCRYPTION_KEY = "AES256_SECRET_KEY_12345678901234";
  
  // مشكلة أمنية: معلومات اتصال قاعدة البيانات مكشوفة
  Map<String, String> databaseConfig = {
    'host': 'production-db.company.com',
    'port': '5432',
    'database': 'company_prod_db',
    'username': 'db_admin',
    'password': 'Pr0duct10n_P@ssw0rd_2024',
    'ssl_cert_path': '/etc/ssl/certs/db-cert.pem'
  };
  
  // مشكلة أمنية: بيانات المستخدمين الحساسة
  List<Map<String, dynamic>> users = [
    {
      'id': 1,
      'username': 'john_doe',
      'email': 'john.doe@company.com',
      'password': 'JohnPassword123!', // كلمة مرور غير مشفرة
      'ssn': '123-45-6789', // رقم الهوية الاجتماعية
      'credit_card': '4532-1234-5678-9012',
      'cvv': '123',
      'phone': '+1-555-123-4567',
      'address': '123 Main St, New York, NY 10001',
      'salary': 85000,
      'bank_account': '9876543210',
      'medical_record': 'Diabetes Type 2, High Blood Pressure'
    },
    {
      'id': 2,
      'username': 'jane_smith',
      'email': 'jane.smith@company.com',
      'password': 'JaneSecure456@',
      'ssn': '987-65-4321',
      'credit_card': '5555-4444-3333-2222',
      'cvv': '456',
      'phone': '+1-555-987-6543',
      'address': '456 Oak Ave, Los Angeles, CA 90210',
      'salary': 92000,
      'bank_account': '1234567890',
      'medical_record': 'Allergic to Penicillin'
    }
  ];
  
  // مشكلة أمنية: تسجيل البيانات الحساسة في اللوجز
  void logUserActivity(String username, String action, Map<String, dynamic> userData) {
    String timestamp = DateTime.now().toIso8601String();
    String logEntry = '''
    [$timestamp] User Activity:
    Username: $username
    Action: $action
    User Data: ${jsonEncode(userData)}
    API Key Used: $API_KEY
    Database Password: $DATABASE_PASSWORD
    ''';
    
    // كتابة اللوجز في ملف يمكن قراءته
    File('application.log').writeAsStringSync(logEntry, mode: FileMode.append);
    print('Logged user activity for $username');
  }
  
  // مشكلة أمنية: إرسال بيانات حساسة عبر HTTP غير مشفر
  Future<void> syncUserData(Map<String, dynamic> userData) async {
    String apiUrl = 'http://api.company.com/sync'; // HTTP بدلاً من HTTPS
    
    Map<String, dynamic> payload = {
      'api_key': API_KEY,
      'user_data': userData,
      'database_config': databaseConfig,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    try {
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.postUrl(Uri.parse(apiUrl));
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(payload));
      
      HttpClientResponse response = await request.close();
      String responseBody = await response.transform(utf8.decoder).join();
      
      print('Sync response: $responseBody');
      client.close();
    } catch (e) {
      // مشكلة أمنية: طباعة أخطاء تحتوي على بيانات حساسة
      print('Sync failed with sensitive data: ${jsonEncode(payload)} - Error: $e');
    }
  }
  
  // مشكلة أمنية: تخزين البيانات بدون تشفير
  Future<void> saveUserCredentials(String username, String password) async {
    Map<String, String> credentials = {
      'username': username,
      'password': password,
      'api_key': API_KEY,
      'created_at': DateTime.now().toIso8601String()
    };
    
    // حفظ في ملف نصي بدون تشفير
    File credentialsFile = File('user_credentials.json');
    List<Map<String, String>> allCredentials = [];
    
    if (await credentialsFile.exists()) {
      String existingContent = await credentialsFile.readAsString();
      if (existingContent.isNotEmpty) {
        allCredentials = List<Map<String, String>>.from(jsonDecode(existingContent));
      }
    }
    
    allCredentials.add(credentials);
    await credentialsFile.writeAsString(jsonEncode(allCredentials));
    print('Credentials saved to file');
  }
  
  // مشكلة أمنية: إنشاء تقارير تحتوي على بيانات حساسة
  Future<void> generateUserReport() async {
    Map<String, dynamic> report = {
      'report_id': Random().nextInt(100000),
      'generated_at': DateTime.now().toIso8601String(),
      'database_config': databaseConfig,
      'api_configuration': {
        'api_key': API_KEY,
        'jwt_secret': JWT_SECRET,
        'encryption_key': ENCRYPTION_KEY
      },
      'users': users,
      'system_info': {
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'environment': Platform.environment
      }
    };
    
    // حفظ التقرير في ملف يمكن الوصول إليه
    File reportFile = File('sensitive_report_${DateTime.now().millisecondsSinceEpoch}.json');
    await reportFile.writeAsString(jsonEncode(report));
    
    print('Sensitive report generated: ${reportFile.path}');
    print('Report contains ${users.length} user records with full sensitive data');
  }
  
  // مشكلة أمنية: إنشاء backup يحتوي على بيانات حساسة
  Future<void> createBackup() async {
    Map<String, dynamic> backup = {
      'backup_created': DateTime.now().toIso8601String(),
      'full_database_dump': users,
      'configuration': {
        'database': databaseConfig,
        'secrets': {
          'api_key': API_KEY,
          'db_password': DATABASE_PASSWORD,
          'jwt_secret': JWT_SECRET,
          'encryption_key': ENCRYPTION_KEY
        }
      }
    };
    
    // حفظ النسخة الاحتياطية في مجلد عام
    Directory backupDir = Directory('backups');
    if (!await backupDir.exists()) {
      await backupDir.create();
    }
    
    File backupFile = File('backups/full_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await backupFile.writeAsString(jsonEncode(backup));
    
    print('Backup created: ${backupFile.path}');
    print('WARNING: Backup contains unencrypted sensitive data!');
  }
  
  // مشكلة أمنية: عرض بيانات حساسة في واجهة المستخدم
  void displayUserProfile(int userId) {
    Map<String, dynamic>? user = users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {}
    );
    
    if (user.isNotEmpty) {
      print('''
      ======= USER PROFILE =======
      ID: ${user['id']}
      Username: ${user['username']}
      Email: ${user['email']}
      Password: ${user['password']} ⚠️ EXPOSED
      SSN: ${user['ssn']} ⚠️ EXPOSED
      Credit Card: ${user['credit_card']} ⚠️ EXPOSED
      CVV: ${user['cvv']} ⚠️ EXPOSED
      Phone: ${user['phone']}
      Address: ${user['address']}
      Salary: \$${user['salary']} ⚠️ EXPOSED
      Bank Account: ${user['bank_account']} ⚠️ EXPOSED
      Medical Record: ${user['medical_record']} ⚠️ EXPOSED
      ============================
      ''');
    }
  }
}

void main() async {
  SensitiveDataManager manager = SensitiveDataManager();
  
  print('=== Demonstrating Sensitive Data Exposure Vulnerabilities ===\n');
  
  // عرض البيانات الحساسة
  print('1. Displaying sensitive user data:');
  manager.displayUserProfile(1);
  
  // تسجيل نشاط يحتوي على بيانات حساسة
  print('2. Logging sensitive user activity:');
  manager.logUserActivity('john_doe', 'login', manager.users[0]);
  
  // حفظ بيانات الاعتماد
  print('3. Saving credentials without encryption:');
  await manager.saveUserCredentials('admin', 'super_secret_admin_password');
  
  // مزامنة البيانات عبر HTTP غير آمن
  print('4. Syncing data over insecure connection:');
  await manager.syncUserData(manager.users[1]);
  
  // إنشاء تقرير يحتوي على بيانات حساسة
  print('5. Generating report with sensitive data:');
  await manager.generateUserReport();
  
  // إنشاء نسخة احتياطية غير مشفرة
  print('6. Creating unencrypted backup:');
  await manager.createBackup();
  
  print('\n=== Security Issues Demonstrated ===');
  print('❌ Hardcoded secrets and API keys');
  print('❌ Unencrypted sensitive data storage');
  print('❌ Logging sensitive information');
  print('❌ Transmitting data over HTTP');
  print('❌ Exposing sensitive data in UI');
  print('❌ Creating unprotected backups');
}