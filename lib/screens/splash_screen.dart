import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'auth/login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/terms_conditions.screen.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showButton = false;
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start the animation
    _animationController.forward().then((_) {
      setState(() => _showButton = true);
      // Check for existing user session
      _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    if (_isNavigating) return;

    try {
      // Ensure auth service is initialized
      await _authService.ensureInitialized();

      // Check for active user session
      final userId = await _storageService.getCurrentUserId();
      final currentUser = _authService.currentUser;

      debugPrint('SplashScreen: User ID from storage: $userId');
      debugPrint('SplashScreen: Current user from auth: ${currentUser?.uid}');

      // Check for consistency - if we have both user ID and current user
      if (userId != null && currentUser != null) {
        debugPrint('SplashScreen: Active session found, navigating to home');
        _isNavigating = true;

        // Navigate directly to home
        Future.microtask(() {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else if (userId != null && currentUser == null) {
        // Inconsistent state - user ID in storage but no auth user
        debugPrint(
          'SplashScreen: Inconsistent state - user ID in storage but no auth user',
        );
        await _authService.signOut();
        await _storageService.setCurrentUserId(null);
      } else if (userId == null && currentUser != null) {
        // Inconsistent state - auth user but no user ID in storage
        debugPrint(
          'SplashScreen: Inconsistent state - auth user but no user ID in storage',
        );
        await _storageService.setCurrentUserId(currentUser.uid);

        // Still navigate to home since we have an auth user
        debugPrint(
          'SplashScreen: Fixed inconsistent state, navigating to home',
        );
        _isNavigating = true;
        Future.microtask(() {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } else {
        debugPrint('SplashScreen: No active session, showing start button');
      }
    } catch (e) {
      debugPrint('SplashScreen: Error checking auth state: $e');
      // Clear any potentially inconsistent state on error
      try {
        await _authService.signOut();
        await _storageService.setCurrentUserId(null);
      } catch (e) {
        debugPrint('SplashScreen: Error clearing auth state: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) async {
    if (_isNavigating) return;
    _isNavigating = true;

    _animationController.reverse().then((_) async {
      // Show Terms & Conditions first
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen()),
      );

      // Only proceed to login if terms were accepted
      if (result == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _isNavigating = false; // Reset flag if cancelled
      }
    });
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
                // Spacer for top margin
                const Spacer(flex: 2),

                // Logo with smooth scale and fade animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Curves.easeOutCubic.transform(
                        _animationController.value,
                      ),
                      child: Opacity(
                        opacity: _animationController.value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/lifecareplus_logo.png',
                    width: 200, // Adjust logo size to fit modern look
                  ),
                ),

                // Tagline with fade-in animation
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(0.3, 1.0),
                  ),
                  child: const Text(
                    'Your personal health companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight
                              .w600, // Slightly bold for better readability
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Show the "Mulai" button after the logo animation
                if (_showButton)
                  RoundedButton(
                    text: 'Mulai',
                    onPressed: () => _navigateToLogin(context),
                    color: AppColors.textHighlight,
                    textColor: Colors.black,
                  ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
