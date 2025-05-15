import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'auth/login_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'auth/terms_conditions.screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showButton = false;

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
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin(BuildContext context) async {
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
                    'srdyuiwghieurhdqwoheuidrqyhijkdhiyqehiohdysgaidhgagd',
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
