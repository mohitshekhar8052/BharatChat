import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _globeController;
  late AnimationController _starsController;
  late AnimationController _bubble1Controller;
  late AnimationController _bubble2Controller;
  late AnimationController _bubble3Controller;
  late AnimationController _bubble4Controller;
  late AnimationController _bubble5Controller;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Globe rotation animation
    _globeController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    // Stars twinkling animation
    _starsController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // Chat bubble animations with different delays
    _bubble1Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _bubble2Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _bubble2Controller.repeat();
    });

    _bubble3Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _bubble3Controller.repeat();
    });

    _bubble4Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _bubble4Controller.repeat();
    });

    _bubble5Controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) _bubble5Controller.repeat();
    });

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _globeController.dispose();
    _starsController.dispose();
    _bubble1Controller.dispose();
    _bubble2Controller.dispose();
    _bubble3Controller.dispose();
    _bubble4Controller.dispose();
    _bubble5Controller.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Starry sky background
          _buildStarryBackground(),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x80000000)],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Main content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3D Globe with chat bubbles
                      SizedBox(
                        width: 350,
                        height: 350,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating globe
                            _buildRotatingGlobe(),

                            // Animated chat bubbles
                            _buildChatBubble(
                              _bubble1Controller,
                              -40,
                              15,
                              5,
                              Icons.forum,
                              "Hi there!",
                            ),
                            _buildChatBubble(
                              _bubble2Controller,
                              55,
                              65,
                              75,
                              Icons.waving_hand,
                              "Hello!",
                            ),
                            _buildChatBubble(
                              _bubble3Controller,
                              -70,
                              45,
                              -15,
                              Icons.sentiment_satisfied,
                              ":)",
                            ),
                            _buildChatBubble(
                              _bubble4Controller,
                              30,
                              80,
                              20,
                              Icons.public,
                              "Global",
                            ),
                            _buildChatBubble(
                              _bubble5Controller,
                              80,
                              5,
                              60,
                              Icons.chat_bubble,
                              "Chat",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Title with shadow effect
                      const Text(
                        'Welcome to Chat App',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 8,
                              color: Color(0x40000000),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      const Text(
                        'The future of real-time conversation is here.\nMore immersive and modern than ever.',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xCCB3D9FF),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildGetStartedButton(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarryBackground() {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [Color(0xFF0c0c1e), Color(0xFF081426)],
            ),
          ),
          child: Stack(
            children: [
              // Stars layer 1
              CustomPaint(
                size: Size.infinite,
                painter: StarsPainter(_starsController.value, 1),
              ),
              // Stars layer 2
              CustomPaint(
                size: Size.infinite,
                painter: StarsPainter((_starsController.value + 0.3) % 1.0, 2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRotatingGlobe() {
    return AnimatedBuilder(
      animation: _globeController,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_globeController.value * 2 * math.pi)
            ..rotateX(0.2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Globe with glow effect
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A9FF).withOpacity(0.5),
                      blurRadius: 80,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00A9FF).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Stack(
                    children: [
                      // Globe image
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF1E40AF),
                              Color(0xFF1E3A8A),
                              Color(0xFF1E293B),
                            ],
                          ),
                        ),
                      ),
                      // Shimmer effect
                      _buildShimmerEffect(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(150),
          child: Transform.translate(
            offset: Offset(
              ((_shimmerController.value * 3) - 1) * 300,
              ((_shimmerController.value * 2) - 0.5) * 150,
            ),
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 200,
                height: 400,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble(
    AnimationController controller,
    double rotateY,
    double top,
    double left,
    IconData icon,
    String text,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        double opacity = 0;
        double scale = 0.3;
        double translateY = 20;

        if (progress <= 0.15) {
          opacity = progress / 0.15;
          scale = 0.3 + (0.7 * progress / 0.15);
          translateY = 20 - (20 * progress / 0.15);
        } else if (progress <= 0.5) {
          opacity = 1;
          scale =
              1 + (0.15 * math.sin((progress - 0.15) / (0.5 - 0.15) * math.pi));
          translateY =
              -5 * math.sin((progress - 0.15) / (0.5 - 0.15) * math.pi);
        } else if (progress <= 0.85) {
          opacity = 1;
          scale = 1;
          translateY = 0;
        } else {
          final fadeProgress = (progress - 0.85) / 0.15;
          opacity = 1 - fadeProgress;
          scale = 1 - (0.7 * fadeProgress);
          translateY = 20 * fadeProgress;
        }

        return Positioned(
          top: MediaQuery.of(context).size.height * top / 100,
          left: MediaQuery.of(context).size.width * left / 100,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotateY * math.pi / 180)
              ..scale(scale)
              ..translate(0.0, translateY, 0.0),
            child: Opacity(
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xE600A9FF), Color(0xE6006AFF)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A9FF).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        },
        style:
            ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A9FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: const Color(0xFF00A9FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.1),
              ),
            ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00A9FF).withOpacity(0.6),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  final int layer;

  StarsPainter(this.animationValue, this.layer);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3 + (0.7 * animationValue))
      ..style = PaintingStyle.fill;

    final stars = [
      {'x': 0.2, 'y': 0.3, 'size': 1.0},
      {'x': 0.8, 'y': 0.6, 'size': 1.0},
      {'x': 0.5, 'y': 0.9, 'size': 1.0},
      {'x': 0.1, 'y': 0.7, 'size': 1.5},
      {'x': 0.9, 'y': 0.1, 'size': 1.5},
      {'x': 0.4, 'y': 0.1, 'size': 1.0},
      {'x': 0.7, 'y': 0.8, 'size': 1.0},
      {'x': 0.3, 'y': 0.5, 'size': 1.5},
      {'x': 0.6, 'y': 0.2, 'size': 1.5},
    ];

    for (var star in stars) {
      final x = star['x']! * size.width;
      final y = star['y']! * size.height;
      final starSize = star['size']! * (layer == 1 ? 1.0 : 1.2);

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
