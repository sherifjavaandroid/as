import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// 1. Insecure Data Storage - Storing sensitive information in SharedPreferences
class InsecureDataStorageWidget extends StatefulWidget {
  @override
  _InsecureDataStorageWidgetState createState() => _InsecureDataStorageWidgetState();
}

// 15. Cross-Site Scripting (XSS) Vulnerability
class XssVulnerabilityWidget extends StatefulWidget {
  @override
  _XssVulnerabilityWidgetState createState() => _XssVulnerabilityWidgetState();
}

class _XssVulnerabilityWidgetState extends State<XssVulnerabilityWidget> {
  final _commentController = TextEditingController();
  List<String> _comments = [];

  // SECURITY VULNERABILITY: Reflecting user input directly in WebView
  // Without sanitizing the input, this allows XSS attacks
  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  String _getHtmlContent() {
    String commentsHtml = '';
    for (final comment in _comments) {
      // Dangerous: No sanitization of user input before rendering
      commentsHtml += '<div class="comment">$comment</div>';
    }

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: Arial, sans-serif; padding: 16px; }
          .comment { padding: 8px; margin-bottom: 8px; background-color: #f0f0f0; border-radius: 4px; }
        </style>
      </head>
      <body>
        <h2>Comments:</h2>
        $commentsHtml
      </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('XSS Vulnerability')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      helperText: 'Try entering: <script>alert("XSS")</script>',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
          Expanded(
            child: WebView(
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController controller) {
                controller.loadHtmlString(_getHtmlContent());
              },
              onPageFinished: (String url) {
                // Page finished loading
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// 16. Weak Cryptography Usage
class WeakCryptographyWidget extends StatefulWidget {
  @override
  _WeakCryptographyWidgetState createState() => _WeakCryptographyWidgetState();
}

class _WeakCryptographyWidgetState extends State<WeakCryptographyWidget> {
  final _dataController = TextEditingController();
  String _encryptedData = 'No data encrypted yet';

  // SECURITY VULNERABILITY: Using weak cryptographic algorithms
  // MD5 and simple XOR are not secure for sensitive data
  String _encryptWithMD5(String input) {
    // MD5 is cryptographically broken and unsuitable for further use
    List<int> bytes = utf8.encode(input);
    Digest digest = md5.convert(bytes);
    return digest.toString();
  }

  String _encryptWithXOR(String input, String key) {
    // Simple XOR encryption is trivial to break
    List<int> inputBytes = utf8.encode(input);
    List<int> keyBytes = utf8.encode(key);
    List<int> encryptedBytes = [];

    for (int i = 0; i < inputBytes.length; i++) {
      encryptedBytes.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encryptedBytes);
  }

  void _encrypt() {
    final input = _dataController.text;
    if (input.isEmpty) return;

    final md5Result = _encryptWithMD5(input);
    final xorResult = _encryptWithXOR(input, 'weakkey');

    setState(() {
      _encryptedData = 'MD5: $md5Result\nXOR: $xorResult';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weak Cryptography')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Data to Encrypt',
                hintText: 'Enter sensitive data',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _encrypt,
              child: Text('Encrypt Data'),
            ),
            SizedBox(height: 16),
            Text('Encrypted Results:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              width: double.infinity,
              child: Text(_encryptedData),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: This app uses weak cryptographic algorithms (MD5, XOR) that can be easily broken.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }
}

// 17. Lack of App Transport Security
class NoAppTransportSecurityWidget extends StatefulWidget {
  @override
  _NoAppTransportSecurityWidgetState createState() => _NoAppTransportSecurityWidgetState();
}

class _NoAppTransportSecurityWidgetState extends State<NoAppTransportSecurityWidget> {
  String _connectionStatus = 'Not connected';

  // SECURITY VULNERABILITY: Disabling App Transport Security / CleartextTraffic
  // This allows the app to connect to insecure HTTP endpoints
  Future<void> _checkConnection() async {
    setState(() {
      _connectionStatus = 'Checking connection...';
    });

    try {
      // Making an HTTP (not HTTPS) request, which would be blocked with proper security settings
      final response = await http.get(Uri.parse('http://example.com'));
      
      setState(() {
        _connectionStatus = 'Connected successfully to HTTP endpoint with status: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('No App Transport Security')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app disables App Transport Security (iOS) / CleartextTraffic (Android)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkConnection,
              child: Text('Test HTTP Connection'),
            ),
            SizedBox(height: 16),
            Text('Connection Status:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              width: double.infinity,
              child: Text(_connectionStatus),
            ),
            SizedBox(height: 16),
            Text(
              'In AndroidManifest.xml:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text(
                '<application\n    android:usesCleartextTraffic="true"\n    ... >',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'In Info.plist:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text(
                '<key>NSAppTransportSecurity</key>\n<dict>\n    <key>NSAllowsArbitraryLoads</key>\n    <true/>\n</dict>',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 18. Insecure Clipboard Handling
class InsecureClipboardWidget extends StatefulWidget {
  @override
  _InsecureClipboardWidgetState createState() => _InsecureClipboardWidgetState();
}

class _InsecureClipboardWidgetState extends State<InsecureClipboardWidget> {
  final _sensitiveDataController = TextEditingController();
  String _clipboardContent = 'No clipboard data';

  // SECURITY VULNERABILITY: Insecure clipboard handling
  // Sensitive data should not be copied to clipboard without protection
  void _copyToClipboard() {
    final sensitiveData = _sensitiveDataController.text;
    if (sensitiveData.isEmpty) return;
    
    // Copying sensitive data to clipboard without restrictions
    Clipboard.setData(ClipboardData(text: sensitiveData));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _readFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    setState(() {
      _clipboardContent = clipboardData?.text ?? 'No data in clipboard';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Clipboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _sensitiveDataController,
              decoration: InputDecoration(
                labelText: 'Sensitive Data',
                hintText: 'Enter sensitive data (e.g., password, credit card)',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _copyToClipboard,
                  child: Text('Copy to Clipboard'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _readFromClipboard,
                  child: Text('Read from Clipboard'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Clipboard Content:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              width: double.infinity,
              child: Text(_clipboardContent),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: Sensitive data in clipboard can be accessed by other apps.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensitiveDataController.dispose();
    super.dispose();
  }
}

// 19. Insecure Deep Links
class InsecureDeepLinksWidget extends StatelessWidget {
  // SECURITY VULNERABILITY: Insecure deep link handling
  // Not validating deep link parameters can lead to security vulnerabilities
  void _handleDeepLink(BuildContext context, String link) {
    // Parse the deep link
    final uri = Uri.parse(link);
    
    // Not validating the parameters or origin of the deep link
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'user') {
      final userId = uri.queryParameters['id'];
      final token = uri.queryParameters['token'];
      
      // Using parameters without validation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _UserProfileScreen(userId: userId, token: token),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Deep Links')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURITY VULNERABILITY: Insecure Deep Link Handling',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Example deep link:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text('myapp://user?id=12345&token=abc123'),
            ),
            SizedBox(height: 16),
            Text('Vulnerable code:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text('''
void handleDeepLink(String link) {
  final uri = Uri.parse(link);
  
  // Not validating parameters
  if (uri.pathSegments.first == 'user') {
    final userId = uri.queryParameters['id'];
    final token = uri.queryParameters['token'];
    
    // Using parameters without validation
    navigateToUserProfile(userId, token);
  }
}
              '''),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleDeepLink(
                context,
                'myapp://user?id=12345&token=abc123',
              ),
              child: Text('Simulate Deep Link'),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: The app does not validate deep link parameters, which could allow attackers to inject malicious data.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileScreen extends StatelessWidget {
  final String? userId;
  final String? token;
  
  const _UserProfileScreen({this.userId, this.token});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $userId'),
            Text('Token: $token'),
            SizedBox(height: 16),
            Text(
              'Warning: These parameters were not validated and could contain malicious data.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// 20. No Screen Security / Screenshot Protection
class NoScreenshotProtectionWidget extends StatefulWidget {
  @override
  _NoScreenshotProtectionWidgetState createState() => _NoScreenshotProtectionWidgetState();
}

class _NoScreenshotProtectionWidgetState extends State<NoScreenshotProtectionWidget> {
  final _creditCardController = TextEditingController();
  final _cvvController = TextEditingController();

  // SECURITY VULNERABILITY: No screenshot protection for sensitive screens
  // This allows sensitive information to be captured in screenshots
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('No Screenshot Protection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURITY VULNERABILITY: No Screenshot Protection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This sensitive screen allows screenshots, which can expose sensitive data:',
            ),
            SizedBox(height: 16),
            TextField(
              controller: _creditCardController,
              decoration: InputDecoration(
                labelText: 'Credit Card Number',
                hintText: 'Enter your credit card number',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: 'Enter CVV',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: 16),
            Text(
              'In secure apps, this screen should prevent screenshots using platform-specific code:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text('''
// For Android:
if (Platform.isAndroid) {
  const MethodChannel('com.example.app/security')
      .invokeMethod('preventScreenshots');
}

// For iOS:
// Use ScreenshotProtectionKit or similar
              '''),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: Screenshots of this screen can expose sensitive financial information.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _creditCardController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

class _InsecureDataStorageWidgetState extends State<InsecureDataStorageWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _storedCredentials = 'No credentials stored yet';

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  // SECURITY VULNERABILITY: Storing sensitive data in SharedPreferences
  // SharedPreferences stores data as plain text and is accessible to attackers 
  // with root access or if the app's data is backed up
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text); // Storing password in plaintext
    
    setState(() {
      _storedCredentials = 'Username: ${_usernameController.text}, Password: ${_passwordController.text}';
    });
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final password = prefs.getString('password') ?? '';
    
    setState(() {
      _storedCredentials = 'Username: $username, Password: $password';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lack of Binary Protection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURITY VULNERABILITY: No Binary Protection',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This app lacks proper binary protection mechanisms, making it vulnerable to reverse engineering and tampering:',
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('No Root Detection'),
              subtitle: Text('The app does not detect if the device is rooted/jailbroken'),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('No Anti-Tampering Protection'),
              subtitle: Text('The app can be modified and repackaged'),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('No Code Obfuscation'),
              subtitle: Text('The code can be easily decompiled and analyzed'),
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('No Anti-Debugging'),
              subtitle: Text('The app can be debugged and analyzed at runtime'),
            ),
          ],
        ),
      ),
    );
  } {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Data Storage')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveCredentials,
              child: Text('Save Credentials'),
            ),
            SizedBox(height: 16),
            Text('Stored Credentials:'),
            Text(_storedCredentials),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// 2. Insecure Network Communication - Using HTTP instead of HTTPS
class InsecureNetworkWidget extends StatefulWidget {
  @override
  _InsecureNetworkWidgetState createState() => _InsecureNetworkWidgetState();
}

class _InsecureNetworkWidgetState extends State<InsecureNetworkWidget> {
  String _response = 'No data yet';
  bool _isLoading = false;

  // SECURITY VULNERABILITY: Using HTTP instead of HTTPS
  // HTTP transmissions are not encrypted, making them susceptible to eavesdropping
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Using HTTP instead of HTTPS allows data to be intercepted
      final response = await http.get(Uri.parse('http://example.com/api/user'));
      
      setState(() {
        _response = response.body;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Network')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Fetch Data (HTTP)'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Text('Response: $_response'),
          ],
        ),
      ),
    );
  }
}

// 3. SQL Injection Vulnerability
class SqlInjectionWidget extends StatefulWidget {
  @override
  _SqlInjectionWidgetState createState() => _SqlInjectionWidgetState();
}

class _SqlInjectionWidgetState extends State<SqlInjectionWidget> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  late Database _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'users.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT)',
        );
        // Insert some sample data
        await db.insert('users', {'name': 'John', 'email': 'john@example.com'});
        await db.insert('users', {'name': 'Jane', 'email': 'jane@example.com'});
      },
    );
  }

  // SECURITY VULNERABILITY: SQL Injection
  // User input is directly concatenated into SQL query without parameterization
  Future<void> _searchUsers() async {
    // Vulnerable to SQL injection attacks like: ' OR '1'='1
    final searchTerm = _searchController.text;
    
    // Dangerous! Direct string concatenation in SQL query
    final results = await _database.rawQuery(
      "SELECT * FROM users WHERE name LIKE '%" + searchTerm + "%' OR email LIKE '%" + searchTerm + "%'",
    );
    
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQL Injection')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                helperText: "Try entering: ' OR '1'='1",
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchUsers,
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            Text('Results:'),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final user = _results[index];
                  return ListTile(
                    title: Text(user['name'] ?? ''),
                    subtitle: Text(user['email'] ?? ''),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _database.close();
    super.dispose();
  }
}

// 4. Insecure WebView Implementation
class InsecureWebViewWidget extends StatefulWidget {
  @override
  _InsecureWebViewWidgetState createState() => _InsecureWebViewWidgetState();
}

class _InsecureWebViewWidgetState extends State<InsecureWebViewWidget> {
  late WebViewController _controller;
  final _urlController = TextEditingController(text: 'https://example.com');

  @override
  void initState() {
    super.initState();
  }

  // SECURITY VULNERABILITY: Insecure WebView Configuration
  // Allowing JavaScript execution, file access, and universal access from file URLs
  // makes the app vulnerable to XSS and other web attacks
  void _loadUrl() {
    _controller.loadRequest(Uri.parse(_urlController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure WebView')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'URL',
                      hintText: 'Enter URL to load',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _loadUrl,
                ),
              ],
            ),
          ),
          Expanded(
            child: WebView(
              initialUrl: _urlController.text,
              javascriptMode: JavascriptMode.unrestricted, // Allowing any JavaScript to execute
              onWebViewCreated: (WebViewController controller) {
                _controller = controller;
              },
              javascriptChannels: <JavascriptChannel>{
                // Exposing a JavaScript channel without proper validation
                JavascriptChannel(
                  name: 'Flutter',
                  onMessageReceived: (JavascriptMessage message) {
                    // Processing message without validation
                    print('Message from JavaScript: ${message.message}');
                  },
                ),
              },
              navigationDelegate: (NavigationRequest request) {
                // No validation of navigation requests
                return NavigationDecision.navigate;
              },
              gestureNavigationEnabled: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

// 5. Logging Sensitive Information
class SensitiveLoggingWidget extends StatefulWidget {
  @override
  _SensitiveLoggingWidgetState createState() => _SensitiveLoggingWidgetState();
}

class _SensitiveLoggingWidgetState extends State<SensitiveLoggingWidget> {
  final _creditCardController = TextEditingController();
  final _cvvController = TextEditingController();
  String _log = '';

  // SECURITY VULNERABILITY: Logging Sensitive Information
  // Logging sensitive data exposes it in system logs which may be accessible to attackers
  void _processPayment() {
    final creditCard = _creditCardController.text;
    final cvv = _cvvController.text;
    
    // Dangerous! Logging sensitive information
    print('Processing payment with Credit Card: $creditCard, CVV: $cvv');
    
    // Adding to debug log that might be captured in crash reports
    setState(() {
      _log += 'Processing payment with Credit Card: $creditCard, CVV: $cvv\n';
    });
    
    // Simulate payment processing
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Payment processed successfully'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sensitive Logging')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _creditCardController,
              decoration: InputDecoration(
                labelText: 'Credit Card Number',
                hintText: 'Enter your credit card number',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: 'Enter CVV',
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processPayment,
              child: Text('Process Payment'),
            ),
            SizedBox(height: 16),
            Text('Debug Log:'),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.black12,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Text(_log),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _creditCardController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

// 6. Hardcoded Credentials
class HardcodedCredentialsWidget extends StatelessWidget {
  // SECURITY VULNERABILITY: Hardcoded API Keys and Credentials
  // These can be extracted from the app binary through reverse engineering
  final String apiKey = 'AIzaSyD3XbgGEPJ5xW7GXnlLEjfakdla302KFNM'; // Fake API key for example
  final String databasePassword = 'super_secret_password';
  final String serverUrl = 'https://api.example.com';

  Future<void> _fetchData() async {
    try {
      // Using hardcoded credentials in API calls
      final response = await http.get(
        Uri.parse('$serverUrl/data'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      
      print('Response: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _connectToDatabase() async {
    // Using hardcoded credentials for database connection
    print('Connecting to database with password: $databasePassword');
    // Database connection code would go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hardcoded Credentials')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Server URL: $serverUrl'),
            Text('API Key: $apiKey'),
            Text('Database Password: $databasePassword'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Fetch Data with API Key'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _connectToDatabase,
              child: Text('Connect to Database'),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Insecure File Storage
class InsecureFileStorageWidget extends StatefulWidget {
  @override
  _InsecureFileStorageWidgetState createState() => _InsecureFileStorageWidgetState();
}

class _InsecureFileStorageWidgetState extends State<InsecureFileStorageWidget> {
  final _dataController = TextEditingController();
  String _savedData = 'No data saved yet';

  // SECURITY VULNERABILITY: Storing sensitive data in unencrypted files
  // Files in external storage are accessible to other apps
  Future<void> _saveToFile() async {
    try {
      // Getting external storage directory - accessible to other apps
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/sensitive_data.txt');
      
      // Writing data without encryption
      await file.writeAsString(_dataController.text);
      
      setState(() {
        _savedData = 'Data saved to: ${file.path}';
      });
    } catch (e) {
      setState(() {
        _savedData = 'Error: $e';
      });
    }
  }

  Future<void> _readFromFile() async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/sensitive_data.txt');
      
      if (await file.exists()) {
        final data = await file.readAsString();
        setState(() {
          _savedData = 'Read from file: $data';
        });
      } else {
        setState(() {
          _savedData = 'File does not exist yet';
        });
      }
    } catch (e) {
      setState(() {
        _savedData = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure File Storage')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _dataController,
              decoration: InputDecoration(
                labelText: 'Sensitive Data',
                hintText: 'Enter sensitive data to save',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _saveToFile,
                  child: Text('Save to File'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _readFromFile,
                  child: Text('Read from File'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(_savedData),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }
}

// 8. Insufficient Certificate Validation
class InsecureCertificateWidget extends StatefulWidget {
  @override
  _InsecureCertificateWidgetState createState() => _InsecureCertificateWidgetState();
}

class _InsecureCertificateWidgetState extends State<InsecureCertificateWidget> {
  String _response = 'No data fetched yet';

  // SECURITY VULNERABILITY: Bypassing SSL Certificate Validation
  // This allows man-in-the-middle attacks by accepting any certificate
  Future<void> _fetchDataInsecurely() async {
    setState(() {
      _response = 'Fetching data...';
    });

    try {
      // Creating an HTTP client that accepts any certificate
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Accepting all certificates, even invalid ones
          print('Accepting invalid certificate from $host:$port');
          return true;
        };

      final request = await httpClient.getUrl(Uri.parse('https://example.com/api/data'));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      setState(() {
        _response = 'Response: $responseBody';
      });
      
      httpClient.close();
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Certificate Validation')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _fetchDataInsecurely,
              child: Text('Fetch Data (Insecure Certificate Validation)'),
            ),
            SizedBox(height: 16),
            Text(_response),
          ],
        ),
      ),
    );
  }
}

// 9. Insecure Random Number Generation
class InsecureRandomWidget extends StatefulWidget {
  @override
  _InsecureRandomWidgetState createState() => _InsecureRandomWidgetState();
}

class _InsecureRandomWidgetState extends State<InsecureRandomWidget> {
  String _generatedToken = 'No token generated yet';

  // SECURITY VULNERABILITY: Using predictable random number generation
  // Using predictable random numbers for security-critical functionality
  String _generateInsecureToken() {
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    final token = 'TOKEN_$random';
    return token;
  }

  void _generateToken() {
    setState(() {
      _generatedToken = _generateInsecureToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Random Numbers')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _generateToken,
              child: Text('Generate Access Token'),
            ),
            SizedBox(height: 16),
            Text('Generated Token: $_generatedToken'),
            SizedBox(height: 8),
            Text(
              'Warning: This token is generated using an insecure method and could be predicted by attackers.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// 10. Excessive App Permissions
class ExcessivePermissionsWidget extends StatefulWidget {
  @override
  _ExcessivePermissionsWidgetState createState() => _ExcessivePermissionsWidgetState();
}

class _ExcessivePermissionsWidgetState extends State<ExcessivePermissionsWidget> {
  Map<Permission, PermissionStatus> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // SECURITY VULNERABILITY: Requesting excessive permissions
  // Requesting permissions the app doesn't actually need increases attack surface
  Future<void> _requestAllPermissions() async {
    // Requesting many permissions, some of which might not be necessary
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.contacts,
      Permission.phone,
      Permission.sms,
      Permission.calendar,
    ];

    final statuses = await permissions.request();
    setState(() {
      _permissionStatus = statuses;
    });
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.location,
      Permission.contacts,
      Permission.phone,
      Permission.sms,
      Permission.calendar,
    ];

    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    setState(() {
      _permissionStatus = statuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Excessive Permissions')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _requestAllPermissions,
              child: Text('Request All Permissions'),
            ),
            SizedBox(height: 16),
            Text('Permission Status:'),
            Expanded(
              child: ListView(
                children: _permissionStatus.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key.toString().split('.').last),
                    subtitle: Text(entry.value.toString()),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 11. Insecure Authentication - No Biometrics or 2FA
class InsecureAuthenticationWidget extends StatefulWidget {
  @override
  _InsecureAuthenticationWidgetState createState() => _InsecureAuthenticationWidgetState();
}

class _InsecureAuthenticationWidgetState extends State<InsecureAuthenticationWidget> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoggedIn = false;

  // SECURITY VULNERABILITY: Weak authentication mechanism
  // No biometric authentication, no 2FA, no account lockout
  void _login() {
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    // Simplified authentication with no security mechanisms
    if (username.isNotEmpty && password.isNotEmpty) {
      // No rate limiting for failed attempts
      // No 2FA
      // No biometric authentication
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insecure Authentication')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoggedIn
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${_usernameController.text}!'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Warning: This login is not secure. No 2FA, biometrics, or other security measures are implemented.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// 12. Exported Components without Proper Permissions
// This is more related to Android manifest configuration, but can be shown in code
class ExportedComponentsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exported Components')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURITY VULNERABILITY: Exported Activities/Services/Receivers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This app may have components exported in the Android manifest without proper permissions.',
            ),
            SizedBox(height: 16),
            Text(
              'Example of vulnerable AndroidManifest.xml:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.black12,
              child: Text('''
<activity
    android:name=".SensitiveActivity"
    android:exported="true"> <!-- Vulnerable: exported without permissions -->
    <intent-filter>
        <action android:name="com.example.app.SENSITIVE_ACTION" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
              '''),
            ),
            SizedBox(height: 16),
            Text(
              'This allows other apps to access this component without restrictions, potentially exposing sensitive functionality.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// 13. Improper Error Handling - Revealing Sensitive Information
class ImproperErrorHandlingWidget extends StatefulWidget {
  @override
  _ImproperErrorHandlingWidgetState createState() => _ImproperErrorHandlingWidgetState();
}

class _ImproperErrorHandlingWidgetState extends State<ImproperErrorHandlingWidget> {
  String _errorMessage = 'No errors yet';

  // SECURITY VULNERABILITY: Revealing detailed error information
  // Detailed error messages can reveal internal implementation details to attackers
  void _simulateError() {
    try {
      // Simulating a database connection error
      throw Exception('Failed to connect to database at 192.168.1.100:3306 with user "admin"');
    } catch (e) {
      // Revealing the entire error to the user, including sensitive details
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Improper Error Handling')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _simulateError,
              child: Text('Simulate Error'),
            ),
            SizedBox(height: 16),
            Text('Error Message:'),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.red[100],
              width: double.infinity,
              child: Text(_errorMessage),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: Detailed error messages can reveal sensitive information about the application\'s infrastructure.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// 14. Lack of Binary Protection
class BinaryProtectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context)