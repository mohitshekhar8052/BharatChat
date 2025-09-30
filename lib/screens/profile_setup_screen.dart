import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _professionController = TextEditingController();
  final _companyController = TextEditingController();
  final _educationController = TextEditingController();

  String _selectedGender = '';
  DateTime? _selectedDateOfBirth;
  List<String> _selectedInterests = [];
  bool _isLoading = false;

  // Predefined interests
  final List<String> _availableInterests = [
    'Technology',
    'Sports',
    'Music',
    'Travel',
    'Photography',
    'Reading',
    'Gaming',
    'Movies',
    'Cooking',
    'Art',
    'Fashion',
    'Health & Fitness',
    'Science',
    'Business',
    'Education',
    'Nature',
    'Food',
    'Dancing',
    'Writing',
    'Volunteering',
    'Cars',
    'Animals',
    'History',
    'Politics',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final userData = await FirestoreService.getCurrentUserProfile();
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        setState(() {
          _displayNameController.text = user.displayName;
          _bioController.text =
              user.bio == 'Just another chat app user enjoying conversations!'
              ? ''
              : user.bio;
          _phoneController.text = user.phoneNumber;
          _locationController.text = user.location;
          _websiteController.text = user.website;
          _professionController.text = user.profession;
          _companyController.text = user.company;
          _educationController.text = user.education;
          _selectedGender = user.gender;
          _selectedInterests = List.from(user.interests);
          if (user.dateOfBirth.isNotEmpty) {
            try {
              _selectedDateOfBirth = DateTime.parse(user.dateOfBirth);
            } catch (e) {
              // Handle invalid date format
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirestoreService.updateUserProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? 'Just another chat app user enjoying conversations!'
            : _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth:
            _selectedDateOfBirth?.toIso8601String().split('T')[0] ?? '',
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
        interests: _selectedInterests,
        profession: _professionController.text.trim(),
        company: _companyController.text.trim(),
        education: _educationController.text.trim(),
        gender: _selectedGender,
      );

      // Mark profile as completed if enough fields are filled
      final completionPercentage = _calculateCompletionPercentage();
      if (completionPercentage >= 75.0) {
        await FirestoreService.markProfileCompleted();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateCompletionPercentage() {
    int completedFields = 0;
    int totalFields = 8;

    if (_displayNameController.text.trim().isNotEmpty) completedFields++;
    if (_bioController.text.trim().isNotEmpty) completedFields++;
    if (_phoneController.text.trim().isNotEmpty) completedFields++;
    if (_selectedDateOfBirth != null) completedFields++;
    if (_locationController.text.trim().isNotEmpty) completedFields++;
    if (_professionController.text.trim().isNotEmpty) completedFields++;
    if (_selectedInterests.isNotEmpty) completedFields++;
    if (_selectedGender.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2428),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_calculateCompletionPercentage().toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF13A4EC),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Progress indicator
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Completion: ${_calculateCompletionPercentage().toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _calculateCompletionPercentage() / 100,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF13A4EC),
                    ),
                  ),
                ],
              ),
            ),

            // Display Name
            _buildTextField(
              controller: _displayNameController,
              label: 'Display Name',
              icon: Icons.person,
              required: true,
            ),

            // Bio
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info,
              maxLines: 3,
            ),

            // Phone Number
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            // Date of Birth
            _buildDatePicker(),

            // Gender
            _buildGenderSelector(),

            // Location
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
            ),

            // Website
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              icon: Icons.link,
              keyboardType: TextInputType.url,
            ),

            // Profession
            _buildTextField(
              controller: _professionController,
              label: 'Profession',
              icon: Icons.work,
            ),

            // Company
            _buildTextField(
              controller: _companyController,
              label: 'Company',
              icon: Icons.business,
            ),

            // Education
            _buildTextField(
              controller: _educationController,
              label: 'Education',
              icon: Icons.school,
            ),

            // Interests
            _buildInterestsSelector(),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A4EC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label + (required ? ' *' : ''),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF283339),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF9DB0B9)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Enter your $label',
                hintStyle: const TextStyle(color: Color(0xFF9DB0B9)),
              ),
              validator: required
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '$label is required';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of Birth',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF283339),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateOfBirth ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDateOfBirth = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF9DB0B9)),
                    const SizedBox(width: 16),
                    Text(
                      _selectedDateOfBirth != null
                          ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                          : 'Select your date of birth',
                      style: TextStyle(
                        color: _selectedDateOfBirth != null
                            ? Colors.white
                            : const Color(0xFF9DB0B9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildGenderOption('Male'),
              const SizedBox(width: 12),
              _buildGenderOption('Female'),
              const SizedBox(width: 12),
              _buildGenderOption('Other'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF13A4EC)
                : const Color(0xFF283339),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            gender,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9DB0B9),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interests',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF13A4EC)
                        : const Color(0xFF283339),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9DB0B9),
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedInterests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Selected: ${_selectedInterests.join(', ')}',
              style: const TextStyle(color: Color(0xFF13A4EC), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
