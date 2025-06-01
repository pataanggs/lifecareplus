import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/auth/terms_conditions.screen.dart';
import '/screens/auth/login_screen.dart';
import '/widgets/rounded_button.dart';
import '/screens/root_screen.dart';
import '/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isNavigating = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _setSystemUI();
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
        _checkAuthState();
      }
    });
  }

  Future<void> _checkAuthState() async {
    if (_isNavigating) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final hasUser = _auth.currentUser != null;

      if (kDebugMode) {
        print("Auth state check - isLoggedIn: $isLoggedIn, hasUser: $hasUser");
      }

      if (isLoggedIn && hasUser) {
        _navigateToHome();
      } else {
        if (isLoggedIn != hasUser) {
          await prefs.setBool('is_logged_in', false);
        }
        _showStartButton();
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      _showStartButton();
    }
  }

  void _navigateToHome() {
    if (!_isNavigating && mounted) {
      _isNavigating = true;

      if (kDebugMode) {
        print("Navigating to home with user: ${_auth.currentUser?.uid}");
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RootScreen()),
        (route) => false,
      );
    }
  }

  void _showStartButton() {
    if (mounted) {
      setState(() => _showButton = true);
    }
  }

  void _navigateToLogin(BuildContext context) async {
    if (_isNavigating) return;
    _isNavigating = true;

    HapticFeedback.mediumImpact();
    _animationController.reverse().then((_) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
      );

      if (result == true) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      } else {
        _isNavigating = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.topGradient, AppColors.bottomGradient],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundElements(),
              Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildLogo(),
                        const SizedBox(height: 30),
                        _buildTagline(),
                        const SizedBox(height: 60),
                        if (_showButton) _buildStartButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Top left circle
        Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 1000.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

        // Bottom right circle
        Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            )
            .animate(delay: 400.ms)
            .fadeIn(duration: 1000.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

        // Floating particles
        ...List.generate(20, (index) {
          return Positioned(
                top: 100 + (index * 50),
                left: 20 + (index * 20),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              )
              .animate(delay: (200 + (index * 50)).ms)
              .fadeIn(duration: 800.ms)
              .moveY(begin: 0, end: -20, duration: 2000.ms)
              .then()
              .fadeOut(duration: 800.ms);
        }),
      ],
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: Curves.easeOutCubic.transform(_animationController.value),
          child: Opacity(opacity: _animationController.value, child: child),
        );
      },
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 1000.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
            Image.asset('assets/lifecareplus_logo.png', width: 200)
                .animate(delay: 500.ms)
                .fadeIn(duration: 800.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.3, 1.0),
            ),
            child: const Text(
              'Your personal health companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.white.withOpacity(0.9),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Take control of your health journey',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedButton(
                text: 'Mulai',
                onPressed: () => _navigateToLogin(context),
                color: AppColors.textHighlight,
                textColor: Colors.black,
                width: 200,
                height: 50,
                borderRadius: 25,
                elevation: 3,
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          const SizedBox(height: 16),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}
