// database_service.dart - مثال على SQL Injection
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

class DatabaseService {
  late Database db;
  
  void initializeDatabase() {
    // إنشاء قاعدة البيانات
    db = sqlite3.open('app_database.db');
    
    // إنشاء جدول المستخدمين
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        email TEXT,
        role TEXT DEFAULT 'user'
      )
    ''');
    
    // إضافة بعض البيانات التجريبية
    db.execute('''
      INSERT OR IGNORE INTO users (id, username, password, email, role) 
      VALUES (1, 'admin', 'admin123', 'admin@example.com', 'admin')
    ''');
    
    db.execute('''
      INSERT OR IGNORE INTO users (id, username, password, email, role) 
      VALUES (2, 'user1', 'password123', 'user1@example.com', 'user')
    ''');
  }
  
  // مشكلة أمنية خطيرة: SQL Injection
  Map<String, dynamic>? authenticateUser(String username, String password) {
    // استعلام خطير بدون حماية
    String query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
    
    print('Executing query: $query');
    
    try {
      ResultSet results = db.select(query);
      
      if (results.isNotEmpty) {
        Row row = results.first;
        return {
          'id': row['id'],
          'username': row['username'],
          'email': row['email'],
          'role': row['role']
        };
      }
      return null;
    } catch (e) {
      print('Database error: $e');
      return null;
    }
  }
  
  // مشكلة أمنية: استعلام قابل للحقن
  List<Map<String, dynamic>> searchUsers(String searchTerm) {
    String query = "SELECT id, username, email FROM users WHERE username LIKE '%$searchTerm%' OR email LIKE '%$searchTerm%'";
    
    print('Executing search query: $query');
    
    try {
      ResultSet results = db.select(query);
      List<Map<String, dynamic>> users = [];
      
      for (Row row in results) {
        users.add({
          'id': row['id'],
          'username': row['username'],
          'email': row['email']
        });
      }
      
      return users;
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }
  
  // مشكلة أمنية: تحديث بدون حماية
  bool updateUserRole(String username, String newRole) {
    String query = "UPDATE users SET role = '$newRole' WHERE username = '$username'";
    
    print('Executing update query: $query');
    
    try {
      db.execute(query);
      return true;
    } catch (e) {
      print('Update error: $e');
      return false;
    }
  }
  
  // مشكلة أمنية: حذف بدون حماية
  bool deleteUser(String userId) {
    String query = "DELETE FROM users WHERE id = $userId";
    
    print('Executing delete query: $query');
    
    try {
      db.execute(query);
      return true;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }
  
  void closeDatabase() {
    db.dispose();
  }
}

// تطبيق تجريبي لاستخدام قاعدة البيانات
class LoginApp {
  DatabaseService dbService = DatabaseService();
  
  void initialize() {
    dbService.initializeDatabase();
    print('Database initialized successfully');
  }
  
  void demonstrateVulnerabilities() {
    print('\n=== Demonstrating SQL Injection Vulnerabilities ===');
    
    // محاولة تسجيل دخول عادية
    print('\n1. Normal Login:');
    var user = dbService.authenticateUser('admin', 'admin123');
    print('Login result: $user');
    
    // هجوم SQL Injection
    print('\n2. SQL Injection Attack:');
    // المهاجم يدخل: admin'--
    var maliciousUser = dbService.authenticateUser("admin'--", "anything");
    print('Malicious login result: $maliciousUser');
    
    // هجوم آخر للحصول على جميع المستخدمين
    print('\n3. Get All Users Attack:');
    // المهاجم يدخل: ' OR '1'='1
    var allUsers = dbService.authenticateUser("' OR '1'='1'--", "anything");
    print('All users attack result: $allUsers');
    
    // هجوم في البحث
    print('\n4. Search Injection:');
    var searchResults = dbService.searchUsers("' UNION SELECT id, username, password FROM users--");
    print('Search injection results: $searchResults');
    
    // هجوم في التحديث
    print('\n5. Update Injection:');
    dbService.updateUserRole("user1'; UPDATE users SET password = 'hacked' WHERE role = 'admin'--", "admin");
    
    // هجوم في الحذف
    print('\n6. Delete Injection:');
    dbService.deleteUser("1 OR 1=1"); // سيحذف جميع المستخدمين!
  }
  
  void cleanup() {
    dbService.closeDatabase();
  }
}

void main() {
  LoginApp app = LoginApp();
  
  try {
    app.initialize();
    app.demonstrateVulnerabilities();
  } catch (e) {
    print('Application error: $e');
  } finally {
    app.cleanup();
  }
  
  print('\n=== SQL Injection Examples ===');
  print("Try these malicious inputs:");
  print("Username: admin'--");
  print("Username: ' OR '1'='1'--");
  print("Search: ' UNION SELECT username, password, email FROM users--");
}