import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;

  late Animation<double> _floatAnimation1;
  late Animation<double> _floatAnimation2;
  late Animation<double> _floatAnimation3;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize floating animations
    _floatController1 = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _floatController2 = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    _floatController3 = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _floatAnimation1 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController1, curve: Curves.easeInOut),
    );

    _floatAnimation2 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController2, curve: Curves.easeInOut),
    );

    _floatAnimation3 = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController3, curve: Curves.easeInOut),
    );

    // Start animations with delays
    _floatController1.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 2), () {
      _floatController2.repeat(reverse: true);
    });
    Future.delayed(const Duration(seconds: 4), () {
      _floatController3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111618),
      body: Stack(
        children: [
          // Background floating elements
          Positioned.fill(
            child: Stack(
              children: [
                // Blue floating circle
                AnimatedBuilder(
                  animation: _floatAnimation1,
                  builder: (context, child) {
                    return Positioned(
                      top:
                          MediaQuery.of(context).size.height * 0.1 +
                          _floatAnimation1.value,
                      left: MediaQuery.of(context).size.width * 0.1,
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: const Color(0xFF13A4EC).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(64),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF13A4EC).withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Purple floating circle
                AnimatedBuilder(
                  animation: _floatAnimation2,
                  builder: (context, child) {
                    return Positioned(
                      bottom:
                          MediaQuery.of(context).size.height * 0.2 +
                          _floatAnimation2.value,
                      right: MediaQuery.of(context).size.width * 0.05,
                      child: Container(
                        width: 192,
                        height: 192,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(96),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 80,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Pink floating circle
                AnimatedBuilder(
                  animation: _floatAnimation3,
                  builder: (context, child) {
                    return Positioned(
                      top:
                          MediaQuery.of(context).size.height * 0.3 +
                          _floatAnimation3.value,
                      right: MediaQuery.of(context).size.width * 0.15,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(48),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.2),
                              blurRadius: 50,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Header with back button and logo
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 32),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF283339),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        // Centered logo and app name
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble,
                                size: 32,
                                color: const Color(0xFF13A4EC),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ChatApp',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),

                  // "Create Account" title
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Join our community today',
                    style: TextStyle(fontSize: 16, color: Color(0xFF9DB0B9)),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Form fields
                  Column(
                    children: [
                      // Full Name field
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF9DB0B9),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email field
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: Color(0xFF9DB0B9),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Password field
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF9DB0B9),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Confirm Password field
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF283339),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _confirmPasswordController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF9DB0B9),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _handleSignUp();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading
                              ? const Color(0xFF13A4EC).withOpacity(0.7)
                              : const Color(0xFF13A4EC),
                          foregroundColor: Colors.white,
                          elevation: _isLoading ? 0 : 2,
                          shadowColor: const Color(0xFF13A4EC).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white.withOpacity(0.9),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Creating Account...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Color(0xFF9DB0B9),
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF13A4EC),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Terms of service
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color(0xFF9DB0B9),
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By creating an account, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    // Validate all fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate email format
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password confirmation
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase authentication
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      if (mounted && userCredential != null) {
        // Show animated success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome ${_nameController.text}! Account created successfully!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        // Add delay for better user experience
        await Future.delayed(const Duration(milliseconds: 1000));

        // Navigate to MainTabScreen after successful signup
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
