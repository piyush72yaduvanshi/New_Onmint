import 'package:flutter/material.dart';
import 'dashboard_screen_simple.dart';
import '../services/bloodbank_screen.dart';
import '../services/ambulance_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override  
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BloodbankScreen(),
    const AmbulanceScreen(), // SOS/Emergency
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // If SOS is tapped, show emergency dialog
    if (index == 2) {
      _showEmergencyDialog();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Color(0xFFFF6B6B), size: 32),
            SizedBox(width: 12),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Do you need emergency assistance?\n\nThis will immediately request an ambulance to your location.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to ambulance screen
              setState(() => _selectedIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AmbulanceScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Ambulance'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  isSelected: _selectedIndex == 0,
                ),
                _buildNavItem(
                  icon: Icons.bloodtype_rounded,
                  label: 'Blood',
                  index: 1,
                  isSelected: _selectedIndex == 1,
                ),
                _buildNavItem(
                  icon: Icons.emergency_rounded,
                  label: 'SOS',
                  index: 2,
                  isSelected: _selectedIndex == 2,
                  isEmergency: true,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                  isSelected: _selectedIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    bool isEmergency = false,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: isEmergency
                      ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
                      : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : isEmergency
                      ? const Color(0xFFFF6B6B)
                      : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isEmergency
                        ? const Color(0xFFFF6B6B)
                        : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
