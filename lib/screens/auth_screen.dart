import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;

  late Animation<double> _floatAnimation1;
  late Animation<double> _floatAnimation2;
  late Animation<double> _floatAnimation3;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _rememberEmail = false;

  @override
  void initState() {
    super.initState();

    // Load saved email
    _loadSavedEmail();

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
    _emailController.dispose();
    _passwordController.dispose();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Header with logo and app name
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          size: 40,
                          color: const Color(0xFF13A4EC),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'XtrChat',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "Get Started" title
                  const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Form fields
                  Column(
                    children: [
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Remember Email Checkbox
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Color(0xFF13A4EC);
                                  }
                                  return Colors.transparent;
                                },
                              ),
                              checkColor: WidgetStateProperty.all(Colors.white),
                              side: const BorderSide(
                                color: Color(0xFF9DB0B9),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          child: Checkbox(
                            value: _rememberEmail,
                            onChanged: (value) {
                              setState(() {
                                _rememberEmail = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rememberEmail = !_rememberEmail;
                            });
                          },
                          child: const Text(
                            'Remember my email',
                            style: TextStyle(
                              color: Color(0xFF9DB0B9),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons
                  Column(
                    children: [
                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    _handleLogin();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? const Color(0xFF13A4EC).withOpacity(0.7)
                                  : const Color(0xFF13A4EC),
                              foregroundColor: Colors.white,
                              elevation: _isLoading ? 0 : 2,
                              shadowColor: const Color(
                                0xFF13A4EC,
                              ).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          'Signing in...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Login',
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

                      const SizedBox(height: 16),

                      // "or" text
                      const Text(
                        'or',
                        style: TextStyle(
                          color: Color(0xFF9DB0B9),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to sign up screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF283339),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

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
                            text: 'By continuing, you agree to our ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
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

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fill in all fields'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        'Attempting to sign in with email: ${_emailController.text.trim()}',
      );

      // Firebase authentication
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('Sign in successful: ${userCredential?.user?.email}');

      if (mounted && userCredential != null) {
        // Save email if remember option is checked
        await _saveEmail();

        // Show success animation/message
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
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Login Successful! Welcome back!',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );

        // Add slight delay for better UX
        await Future.delayed(const Duration(milliseconds: 800));

        // Navigate to MainTabScreen with smooth transition
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      print('Sign in error: $e');
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

  // Load saved email from SharedPreferences
  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('remembered_email');
      final rememberEmail = prefs.getBool('remember_email') ?? false;

      if (mounted && savedEmail != null && rememberEmail) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberEmail = true;
        });
      }
    } catch (e) {
      print('Error loading saved email: $e');
    }
  }

  // Save email to SharedPreferences
  Future<void> _saveEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberEmail) {
        await prefs.setString('remembered_email', _emailController.text.trim());
        await prefs.setBool('remember_email', true);
      } else {
        await prefs.remove('remembered_email');
        await prefs.setBool('remember_email', false);
      }
    } catch (e) {
      print('Error saving email: $e');
    }
  }
}
