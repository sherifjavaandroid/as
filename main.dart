// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:crypto/crypto.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'OWASP Mobile Risks Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'OWASP Mobile Risks Demo'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _apiInputController = TextEditingController();
  
//   String _status = 'Not logged in';
//   String _apiResponse = '';
  
//   // M1: Improper Credential Usage - BAD PRACTICE
//   // Storing credentials in plain text
//   void _saveCredentialsBadly() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('username', _usernameController.text);
//     await prefs.setString('password', _passwordController.text); // VERY BAD PRACTICE
    
//     setState(() {
//       _status = 'Credentials saved insecurely!';
//     });
//   }
  
//   // M1: Better Practice
//   void _saveCredentialsSecurely() async {
//     const storage = FlutterSecureStorage();
//     await storage.write(key: 'username', value: _usernameController.text);
//     await storage.write(key: 'password', value: _passwordController.text);
    
//     setState(() {
//       _status = 'Credentials saved securely!';
//     });
//   }
  
//   // M4: Insufficient Input Validation - BAD PRACTICE
//   void _processUserInputUnsafely() {
//     final userInput = _apiInputController.text;
//     // No validation, could be SQL injection or XSS
    
//     // This simulates sending the unvalidated input to an API
//     _makeUnsafeApiCall(userInput);
//   }
  
//   // M4: Better Practice
//   void _processUserInputSafely() {
//     final userInput = _apiInputController.text;
    
//     // Simple validation - in real apps, use more sophisticated validation
//     if (userInput.contains("'") || userInput.contains('"') || 
//         userInput.contains('<') || userInput.contains('>')) {
//       setState(() {
//         _apiResponse = 'Invalid input detected!';
//       });
//       return;
//     }
    
//     _makeApiCall(userInput);
//   }
  
//   // M5: Insecure Communication - BAD PRACTICE
//   void _makeUnsafeApiCall(String input) async {
//     try {
//       // Using HTTP instead of HTTPS
//       final response = await http.post(
//         Uri.parse('http://example.com/api'), 
//         body: {'query': input}
//       );
      
//       setState(() {
//         _apiResponse = 'Response: ${response.body}';
//       });
//     } catch (e) {
//       setState(() {
//         _apiResponse = 'Error: $e';
//       });
//     }
//   }
  
//   // M5: Better Practice
//   void _makeApiCall(String input) async {
//     try {
//       // Using HTTPS and validating certificates
//       final response = await http.post(
//         Uri.parse('https://example.com/api'),
//         body: {'query': input},
//         headers: {'Content-Type': 'application/json'},
//       );
      
//       setState(() {
//         _apiResponse = 'Response: ${response.body}';
//       });
//     } catch (e) {
//       setState(() {
//         _apiResponse = 'Error: $e';
//       });
//     }
//   }
  
//   // M9: Insecure Data Storage - BAD PRACTICE
//   void _storeDataInsecurely() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/sensitive_data.txt');
//     await file.writeAsString('SSN: 123-45-6789\nCredit Card: 4111-1111-1111-1111');
//   }
  
//   // M9: Better Practice
//   void _storeDataSecurely() async {
//     const storage = FlutterSecureStorage();
//     await storage.write(key: 'sensitive_data', value: encryptData('Your sensitive data'));
//   }
  
//   // M10: Insufficient Cryptography - BAD PRACTICE
//   String _weakHash(String input) {
//     // MD5 is considered weak for security purposes
//     return md5.convert(utf8.encode(input)).toString();
//   }
  
//   // M10: Better Practice
//   String encryptData(String data) {
//     // In a real app, use a proper encryption library
//     // This is a simplistic example using SHA-256
//     final key = utf8.encode('some-secure-key');
//     final bytes = utf8.encode(data);
//     final hmacSha256 = Hmac(sha256, key);
//     final digest = hmacSha256.convert(bytes);
//     return digest.toString();
//   }
  
//   // Memory Leak Example - BAD PRACTICE
//   Timer? _timer;
//   List<String> _hugeList = [];
  
//   void _createMemoryLeak() {
//     // Creates a timer that continuously adds items to a list but never stops
//     _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       setState(() {
//         // Continuously growing list that's never cleared
//         _hugeList.addAll(List.generate(1000, (index) => 'Item $index ${DateTime.now()}'));
//       });
//     });
//   }
  
//   void _fixMemoryLeak() {
//     // Cancel the timer to stop the leak
//     _timer?.cancel();
//     _timer = null;
    
//     // Clear the list
//     setState(() {
//       _hugeList.clear();
//     });
//   }
  
//   // Battery Drain Example - BAD PRACTICE
//   void _startBatteryDrain() {
//     // Excessive location updates, network calls, or animations would drain battery
//     _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       // Simulating intensive processing
//       for (var i = 0; i < 10000; i++) {
//         final calculation = i * i / 3.14159;
//       }
      
//       // Force UI updates too frequently
//       setState(() {});
//     });
//   }
  
//   void _stopBatteryDrain() {
//     _timer?.cancel();
//     _timer = null;
//   }
  
//   // Performance Problems - BAD PRACTICE
//   Widget _inefficientListBuilder() {
//     return ListView.builder(
//       shrinkWrap: true, // Causes performance issues with large lists
//       itemCount: 1000,
//       itemBuilder: (context, index) {
//         // Rebuilding all widgets unnecessarily
//         return Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.primaries[index % Colors.primaries.length],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             children: [
//               // Excessive widget nesting
//               Container(
//                 child: Container(
//                   child: Container(
//                     child: Text(
//                       'Item $index',
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text('Description for item $index'),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   // Performance improvement - GOOD PRACTICE
//   Widget _efficientListBuilder() {
//     return ListView.builder(
//       itemCount: 1000,
//       itemBuilder: (context, index) {
//         // Using const where possible
//         return ListTile(
//           title: Text('Item $index'),
//           subtitle: Text('Description for item $index'),
//           tileColor: index.isEven ? Colors.grey[200] : null,
//         );
//       },
//     );
//   }
  
//   @override
//   void dispose() {
//     // Cleanup resources
//     _timer?.cancel();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _apiInputController.dispose();
//     super.dispose();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(widget.title),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             const Text(
//               'OWASP Mobile Risks Demo',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
            
//             // M1: Improper Credential Usage
//             const Text('M1: Improper Credential Usage', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _saveCredentialsBadly,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Save Insecurely'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _saveCredentialsSecurely,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Save Securely'),
//                 ),
//               ],
//             ),
//             Text('Status: $_status'),
//             const Divider(),
            
//             // M4 & M5: Input Validation & Communication
//             const Text('M4 & M5: Input Validation & Communication', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             TextField(
//               controller: _apiInputController,
//               decoration: const InputDecoration(labelText: 'API Input'),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _processUserInputUnsafely,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Process Unsafely'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _processUserInputSafely,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Process Safely'),
//                 ),
//               ],
//             ),
//             Text('API Response: $_apiResponse'),
//             const Divider(),
            
//             // M9 & M10: Data Storage & Cryptography
//             const Text('M9 & M10: Data Storage & Cryptography', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _storeDataInsecurely,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Store Insecurely'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _storeDataSecurely,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Store Securely'),
//                 ),
//               ],
//             ),
//             const Divider(),
            
//             // Memory Leaks
//             const Text('Memory Leaks Demo', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _createMemoryLeak,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Create Memory Leak'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _fixMemoryLeak,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Fix Memory Leak'),
//                 ),
//               ],
//             ),
//             Text('Items in huge list: ${_hugeList.length}'),
//             const Divider(),
            
//             // Battery Drain
//             const Text('Battery Drain Demo', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _startBatteryDrain,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Start Battery Drain'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _stopBatteryDrain,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Stop Battery Drain'),
//                 ),
//               ],
//             ),
//             const Divider(),
            
//             // Performance Demo
//             const Text('Performance Demo', 
//               style: TextStyle(fontWeight: FontWeight.bold)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => Dialog(
//                         child: Container(
//                           height: 400,
//                           width: 300,
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               const Text('Inefficient List'),
//                               Expanded(child: _inefficientListBuilder()),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Inefficient UI'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => Dialog(
//                         child: Container(
//                           height: 400,
//                           width: 300,
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               const Text('Efficient List'),
//                               Expanded(child: _efficientListBuilder()),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                   child: const Text('Efficient UI'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors/sensors.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
  startBadCode();
}

void startBadCode() {
  // 🧭 الموقع - تشغيل مستمر بدون cancel
  Geolocator.getPositionStream().listen((Position position) {
    print("📍 Location: ${position.latitude}, ${position.longitude}");
  });

  // ⏱️ مؤقت يعمل باستمرار كل ثانية
  Timer.periodic(Duration(seconds: 1), (timer) {
    print("⏱️ Timer tick...");
  });

  // 📡 طلبات شبكة متكررة
  Timer.periodic(Duration(seconds: 3), (timer) async {
    final response = await http.get(Uri.parse('https://example.com/data'));
    print("📡 Data received: ${response.statusCode}");
  });

  // 🧠 استخدام مستشعرات بدون إيقافها
  accelerometerEvents.listen((AccelerometerEvent event) {
    print("📈 Accelerometer: ${event.x}, ${event.y}, ${event.z}");
  });

  // 🌙 منع السكون باستمرار
  Wakelock.enable();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery Drain App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bad Battery App 😈'),
        ),
        body: Center(
          child: Text('This app drains your battery!'),
        ),
      ),
    );
  }
}
