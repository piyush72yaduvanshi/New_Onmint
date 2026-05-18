import 'package:flutter/material.dart';

/// Blood bank requests list screen
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Requests'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Blood requests list - To be implemented'),
      ),
    );
  }
}
