import 'package:flutter/material.dart';

/// Services management screen for nurses
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Available Services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildServiceCard(
            'Home Nursing Care',
            'Basic nursing care at patient\'s home',
            true,
          ),
          _buildServiceCard(
            'Wound Dressing',
            'Professional wound care and dressing',
            true,
          ),
          _buildServiceCard(
            'Injection Administration',
            'Safe injection services',
            true,
          ),
          _buildServiceCard(
            'IV Therapy',
            'Intravenous therapy at home',
            false,
          ),
          _buildServiceCard(
            'Post-Surgery Care',
            'Post-operative nursing care',
            true,
          ),
          _buildServiceCard(
            'Elderly Care',
            'Specialized care for elderly patients',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String description, bool isEnabled) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        value: isEnabled,
        onChanged: (value) {
          // TODO: Update service availability
        },
      ),
    );
  }
}
