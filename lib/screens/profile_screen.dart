import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool statusVisibility = true;
  bool contactInfoVisibility = true;
  final AuthService _authService = AuthService();

  // Profile editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isUpdating = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // User profile data from Firestore
  Map<String, dynamic>? _userProfileData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Load current user data from both Auth and Firestore
  Future<void> _loadUserData() async {
    try {
      // Get Firestore data
      final profileData = await _authService.getUserProfileData();

      setState(() {
        _userProfileData = profileData;
      });

      // Populate controllers with Firestore data or fallback to Auth data
      final user = _authService.currentUser;
      if (user != null) {
        _nameController.text =
            profileData?['displayName'] ?? user.displayName ?? '';
        _statusController.text =
            profileData?['status'] ?? 'Hey there! I am using ChatApp';
        _bioController.text =
            profileData?['bio'] ??
            'Just another chat app user enjoying conversations!';
      }
    } catch (e) {
      // Fallback to Auth data if Firestore fails
      final user = _authService.currentUser;
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _statusController.text = 'Hey there! I am using ChatApp';
        _bioController.text =
            'Just another chat app user enjoying conversations!';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111618).withOpacity(0.8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Section
                  Column(
                    children: [
                      // Profile Image
                      GestureDetector(
                        onTap: _showImagePickerDialog,
                        child: Container(
                          width: 144,
                          height: 144,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : (_authService.currentUser?.photoURL != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            _authService.currentUser!.photoURL!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: NetworkImage(
                                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAsOvNz016w18Zrwfw1F2rrzo59M9HPl0hl8-VOiuI7qw63ybwwHPRceJfXsLZa7WYR1GhUPELa8df2FavArPKlunAGfiBLjP2natiAVLFhPxw6_-Kxy97Ni27CqZZ0lyGoA99czrWuH3T-UMCoTPfZrc6Fyp_MIJ40bO1N5jQxqkjEdflQxiLAUDAlARDhawjLG37g-HplXrFjFUz0yINVJ_prqLM7HLb0D2PMDGcv450aIde_JRMdb3XjYHNMutQPLvWzgu5vjcY',
                                          ),
                                          fit: BoxFit.cover,
                                        )),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.touch_app,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name and Username
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _userProfileData?['displayName'] ??
                                    _authService.userDisplayName ??
                                    'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.36,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _showEditProfileDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF13A4EC,
                                    ).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF13A4EC),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _authService.userEmail ?? 'user@example.com',
                            style: const TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Personal Details Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          'Personal Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.27,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildDetailItem(
                              'Name',
                              _userProfileData?['displayName'] ??
                                  _authService.userDisplayName ??
                                  'Not set',
                              hasBottomBorder: true,
                              onEdit: _showEditProfileDialog,
                            ),
                            _buildDetailItem(
                              'Email',
                              _userProfileData?['email'] ??
                                  _authService.userEmail ??
                                  'Not set',
                              hasBottomBorder: true,
                            ),
                            _buildDetailItem(
                              'Status',
                              _userProfileData?['status'] ??
                                  (_statusController.text.isEmpty
                                      ? 'Hey there! I am using ChatApp'
                                      : _statusController.text),
                              hasBottomBorder: true,
                              onEdit: _showEditProfileDialog,
                            ),
                            _buildDetailItem(
                              'Bio',
                              _userProfileData?['bio'] ??
                                  (_bioController.text.isEmpty
                                      ? 'Just another chat app user!'
                                      : _bioController.text),
                              hasBottomBorder: false,
                              onEdit: _showEditProfileDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Privacy Settings Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          'Privacy Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.27,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildPrivacyItem(
                              'Status Visibility',
                              'Only contacts can see your status',
                              statusVisibility,
                              (value) {
                                setState(() {
                                  statusVisibility = value;
                                });
                              },
                              hasBottomBorder: true,
                            ),
                            _buildPrivacyItem(
                              'Contact Info Visibility',
                              'Only contacts can see your info',
                              contactInfoVisibility,
                              (value) {
                                setState(() {
                                  contactInfoVisibility = value;
                                });
                              },
                              hasBottomBorder: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Theme Settings Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Text(
                          'Appearance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.27,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Column(
                              children: [
                                _buildThemeItem(
                                  'Dark',
                                  'Dark theme',
                                  AppTheme.dark,
                                  themeProvider,
                                  hasBottomBorder: true,
                                ),
                                _buildThemeItem(
                                  'Light',
                                  'Light theme',
                                  AppTheme.light,
                                  themeProvider,
                                  hasBottomBorder: true,
                                ),
                                _buildThemeItem(
                                  'System',
                                  'Follow system theme',
                                  AppTheme.system,
                                  themeProvider,
                                  hasBottomBorder: false,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Action Buttons Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle edit profile
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF13A4EC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF283339),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    required bool hasBottomBorder,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(
                bottom: BorderSide(color: Color(0x80475569), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9DB0B9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF13A4EC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF13A4EC),
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    required bool hasBottomBorder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(
                bottom: BorderSide(color: Color(0x80475569), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9DB0B9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF13A4EC),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0x80475569),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeItem(
    String title,
    String subtitle,
    AppTheme theme,
    ThemeProvider themeProvider, {
    bool hasBottomBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFF475569), width: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF13A4EC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeProvider.getThemeIcon(theme),
              color: const Color(0xFF13A4EC),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFA0AABA),
                    fontSize: 14,
                    letterSpacing: -0.21,
                  ),
                ),
              ],
            ),
          ),
          Radio<AppTheme>(
            value: theme,
            groupValue: themeProvider.currentTheme,
            onChanged: (AppTheme? value) {
              if (value != null) {
                themeProvider.setTheme(value);
              }
            },
            activeColor: const Color(0xFF13A4EC),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF13A4EC);
              }
              return Colors.white54;
            }),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283339),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Color(0xFF9DB0B9), fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF9DB0B9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _performLogout(),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFF13A4EC),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Close the dialog first
      Navigator.of(context).pop();

      // Show a simple loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF13A4EC)),
          ),
        ),
      );

      // Sign out from Firebase
      await _authService.signOut();

      // Dismiss loading
      if (mounted) {
        Navigator.of(context).pop();

        // Show success and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Signed out successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ),
        );

        // Navigate to auth screen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      // Dismiss loading if shown
      if (mounted) {
        Navigator.of(context).pop();

        // Only show error if it's a critical authentication failure
        // Firestore permission errors are handled gracefully in AuthService
        if (e.toString().contains('Failed to sign out')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Authentication error occurred. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          // For other errors (like Firestore permission), still navigate
          // as the Firebase Auth sign out likely succeeded
          print('Warning during logout: $e');

          // Show success message since sign out likely worked
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Signed out successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 1),
            ),
          );

          // Navigate to auth screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/auth', (route) => false);
        }
      }
    }
  }

  // Show edit profile dialog
  void _showEditProfileDialog() {
    // Reset controllers with current data
    _loadUserData();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E2327),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit_outlined, color: Color(0xFF13A4EC), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display Name Field
                      _buildEditField(
                        controller: _nameController,
                        label: 'Display Name',
                        icon: Icons.person_outline,
                        hint: 'Enter your display name',
                      ),
                      const SizedBox(height: 16),

                      // Status Field
                      _buildEditField(
                        controller: _statusController,
                        label: 'Status',
                        icon: Icons.mood_outlined,
                        hint: 'What\'s on your mind?',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Bio Field
                      _buildEditField(
                        controller: _bioController,
                        label: 'Bio',
                        icon: Icons.info_outline,
                        hint: 'Tell us about yourself',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: _isUpdating
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF9DB0B9), fontSize: 16),
                  ),
                ),

                // Save Button
                ElevatedButton(
                  onPressed: _isUpdating
                      ? null
                      : () async {
                          await _updateProfile(setDialogState);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF13A4EC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build edit field widget
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9DB0B9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2F35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3A4048), width: 1),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 16,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF9DB0B9), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Update profile method
  Future<void> _updateProfile(StateSetter setDialogState) async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Display name cannot be empty', Colors.red);
      return;
    }

    setDialogState(() {
      _isUpdating = true;
    });

    try {
      // Update Firebase Auth profile and Firestore
      await _authService.updateUserProfile(
        displayName: _nameController.text.trim(),
        status: _statusController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        // Reload user data to reflect changes
        await _loadUserData();

        // Update local state
        setState(() {});

        // Close dialog
        Navigator.pop(context);

        // Show success message
        _showSnackBar('Profile updated successfully!', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update profile: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setDialogState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // Helper method to show snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color == Colors.green
            ? Colors.green.shade600
            : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show image picker dialog
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2327),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9DB0B9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImagePickerOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    _buildImagePickerOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    if (_selectedImage != null ||
                        _authService.currentUser?.photoURL != null)
                      _buildImagePickerOption(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        onTap: _removeImage,
                        isDestructive: true,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build image picker option widget
  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF13A4EC).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : const Color(0xFF13A4EC).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF13A4EC),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFF13A4EC),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        Navigator.pop(context);
        _showSnackBar(
          'Profile photo updated! Tap edit to save changes.',
          Colors.green,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Failed to pick image: $e', Colors.red);
    }
  }

  // Remove profile image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    Navigator.pop(context);
    _showSnackBar(
      'Profile photo removed! Tap edit to save changes.',
      Colors.orange,
    );
  }
}
