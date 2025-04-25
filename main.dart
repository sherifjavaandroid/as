import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const PrivEscApp());
}

class PrivEscApp extends StatelessWidget {
  const PrivEscApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Privilege Esc Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _output = 'Press the button to attempt `su`…';

  Future<void> _attemptEscalation() async {
    String result;
    try {
      // This will only succeed on a rooted device where "su" is available.
      final ProcessResult pr = await Process.run('su', ['-c', 'id']);
      result =
          'Exit code: ${pr.exitCode}\n\nSTDOUT:\n${pr.stdout}\n\nSTDERR:\n${pr.stderr}';
    } catch (e) {
      result = 'Failed to run `su`: $e';
    }

    setState(() => _output = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privilege Escalation Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(_output),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _attemptEscalation,
              child: const Text('Run `su -c id`'),
            ),
          ],
        ),
      ),
    );
  }
}
