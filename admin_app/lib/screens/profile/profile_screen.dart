import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_client/api_client.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final OnMintApiClient _apiClient;
  late final AuthService _authService;
  final _imagePicker = ImagePicker();
  
  User? _user;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiClient = Provider.of<OnMintApiClient>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _apiClient.auth.getProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUpdating = true);

      final updatedUser = await _apiClient.auth.updateProfile(
        {},
        profilePicturePath: image.path,
      );

      if (mounted) {
        setState(() {
          _user = updatedUser;
          _isUpdating = false;
        });
        ToastUtils.showSuccess('Profile picture updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ToastUtils.showError('Failed to update profile picture: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile Picture'),
        content: const Text('Are you sure you want to delete your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);

    try {
      final updatedUser = await _apiClient.auth.deleteProfilePicture();
      if (mounted) {
        setState(() {
          _user = updatedUser;
          _isUpdating = false;
        });
        ToastUtils.showSuccess('Profile picture deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ToastUtils.showError('Failed to delete profile picture: ${e.toString()}');
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ToastUtils.showError('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadProfile,
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Profile Picture Section
                        _buildProfilePictureSection(),
                        
                        const SizedBox(height: 32),
                        
                        // Profile Info
                        _buildProfileInfo(),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        _buildActionButtons(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfilePictureSection() {
    final hasProfilePicture = _user?.profilePictureUrl != null && 
                              _user!.profilePictureUrl!.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Profile Picture
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[200],
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            image: hasProfilePicture
                ? DecorationImage(
                    image: NetworkImage(_user!.profilePictureUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: !hasProfilePicture
              ? Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey[400],
                )
              : null,
        ),
        
        // Loading Overlay
        if (_isUpdating)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        
        // Edit Button
        if (!_isUpdating)
          Positioned(
            bottom: 0,
            right: 0,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'upload') {
                  _pickAndUploadImage();
                } else if (value == 'delete') {
                  _deleteProfilePicture();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'upload',
                  child: Row(
                    children: [
                      Icon(Icons.upload, size: 20),
                      SizedBox(width: 8),
                      Text('Upload New'),
                    ],
                  ),
                ),
                if (hasProfilePicture)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person,
            label: 'Name',
            value: '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.email,
            label: 'Email',
            value: _user?.email ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: _user?.phone ?? 'N/A',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.admin_panel_settings,
            label: 'Role',
            value: _user!.role.toUpperCase(),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Location',
            value: '${_user?.city ?? ''}, ${_user?.state ?? ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Change Password Button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to change password screen
              ToastUtils.showInfo('Change password feature coming soon');
            },
            icon: const Icon(Icons.lock),
            label: const Text('Change Password'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Logout Button
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
