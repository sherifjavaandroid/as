import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserProfileScreen(userId: '5'), // ← أي ID نكتبه هنا هيتم عرضه
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  final String userId;
  UserProfileScreen({required this.userId});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String userInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchUser(widget.userId);
  }

  void fetchUser(String userId) async {
    final url = Uri.parse('https://example.com/api/users/$userId');
    final response = await http.get(url);
    setState(() {
      userInfo = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(child: Text(userInfo)),
    );
  }
}
