import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.forward().then((_) {
      if (mounted) {
        setState(() => _showButton = true);
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildTagline(),
                const Spacer(flex: 3),
                if (_showButton) _buildStartButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
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
      child: Image.asset('assets/lifecareplus_logo.png', width: 200),
    );
  }

  Widget _buildTagline() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0),
      ),
      child: const Text(
        'Your personal health companion',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return RoundedButton(
      text: 'Mulai',
      onPressed: () => _navigateToLogin(context),
      color: AppColors.textHighlight,
      textColor: Colors.black,
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut);
  }
}
