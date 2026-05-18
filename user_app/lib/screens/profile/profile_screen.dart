import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import '../../config/app_colors.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../services/my_bookings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary,
                    child: user.profilePictureUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.profilePictureUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 48, color: Colors.white),
                                );
                              },
                            ),
                          )
                        : Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 48, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Info Cards
                  _buildInfoCard('Personal Information', [
                    _buildInfoRow(Icons.person, 'Name', user.fullName),
                    _buildInfoRow(Icons.email, 'Email', user.email),
                    _buildInfoRow(Icons.phone, 'Phone', user.phone),
                    if (user.gender != null)
                      _buildInfoRow(Icons.wc, 'Gender', user.gender!),
                    if (user.bloodGroup != null)
                      _buildInfoRow(Icons.bloodtype, 'Blood Group', user.bloodGroup!),
                  ]),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoCard('Address', [
                    if (user.city.isNotEmpty)
                      _buildInfoRow(Icons.location_city, 'City', user.city),
                    if (user.state.isNotEmpty)
                      _buildInfoRow(Icons.map, 'State', user.state),
                    if (user.pincode.isNotEmpty)
                      _buildInfoRow(Icons.pin_drop, 'Pincode', user.pincode),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  _buildActionButton(
                    'My Bookings',
                    Icons.calendar_today,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Change Password',
                    Icons.lock,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Logout',
                    Icons.logout,
                    () async {
                      final navigator = Navigator.of(context);
                      await authProvider.logout();
                      if (mounted) {
                        navigator.pushReplacementNamed('/login');
                      }
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.primary,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: color ?? AppColors.primary),
          ],
        ),
      ),
    );
  }
}