import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/mock_auth_service.dart';
import '../../utils/colors.dart';
import '../../utils/show_snackbar.dart';
import 'dart:developer' as developer;
import '../../widgets/rounded_input.dart';
import '../../widgets/rounded_button.dart';
import '../../services/local_storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isNavigating = false; // Flag to prevent multiple navigation attempts

  // Controls when we show the main content
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    // Slight delay before starting animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    // Initialize auth service and check current user
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Ensure auth service is initialized first
      await _authService.ensureInitialized();
      // Then check if user is logged in
      _checkCurrentUser();
    } catch (e) {
      developer.log("Error initializing auth: $e");
    }
  }

  void _checkCurrentUser() async {
    // Use proper service methods instead of accessing internal fields
    final storageService = LocalStorageService();
    final storedUserId = await storageService.getCurrentUserId();
    final currentUser = _authService.currentUser;

    developer.log("Login screen - stored user ID: $storedUserId");
    developer.log("Login screen - current user: ${currentUser?.uid}");

    // Check for inconsistent state
    if (storedUserId != null && currentUser == null) {
      developer.log("Inconsistent state: ID in storage but no current user");
      // Force sign out to clear inconsistent state
      await _authService.signOut();
      return;
    }

    if ((storedUserId != null && currentUser != null) &&
        mounted &&
        !_isNavigating) {
      // User is already logged in, navigate to home
      _isNavigating = true; // Set flag to prevent multiple navigations
      developer.log("User already logged in, redirecting to home");
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    // Prevent multiple sign-in attempts
    if (_isLoading || _isNavigating) {
      return;
    }

    // Validate inputs
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Email dan password harus diisi');
      return;
    }

    setState(() => _isLoading = true);

    try {
      developer.log("Starting email/password sign-in process");

      // Try to sign in
      final MockUserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email: email, password: password);

      developer.log("Successfully signed in with email/password");
      developer.log("User ID: ${userCredential.user?.uid}");

      // Set navigation flag to prevent loops
      _isNavigating = true;

      // Simply navigate to home screen after successful login
      // We'll check profile completeness there to avoid login loops
      if (mounted) {
        developer.log("Navigating to home after successful login");
        // Use named routes for consistency and remove all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      developer.log(
        "Error during sign-in: $e",
        error: e,
        stackTrace: StackTrace.current,
      );
      if (mounted) {
        String errorMessage = 'Terjadi kesalahan saat masuk';

        if (e.toString().contains('No user found')) {
          errorMessage = 'Email tidak terdaftar';
        } else if (e.toString().contains('password is invalid')) {
          errorMessage = 'Password salah';
        }

        showSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToRegister() {
    HapticFeedback.selectionClick();
    // Use pushReplacementNamed to avoid navigation stacking
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ListView(
              children: [
                // Header row with back button and title
                Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textHighlight,
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: AppColors.textHighlight,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    )
                    .animate(delay: 100.ms)
                    .slideY(
                      begin: -0.2,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),

                const SizedBox(height: 36),

                // Welcome text
                const Center(
                      child: Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 60),

                // App logo
                Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/lifecareplus_logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 60),

                // Email input
                Animate(
                  effects: [
                    SlideEffect(
                      begin: const Offset(0, 0.2),
                      end: const Offset(0, 0),
                      duration: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    FadeEffect(
                      begin: 0,
                      end: 1,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
                  ],
                  delay: 400.ms,
                  child: RoundedInput(
                    label: 'Email',
                    hint: 'Masukkan email anda',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Password input
                Animate(
                  effects: [
                    SlideEffect(
                      begin: const Offset(0, 0.2),
                      end: const Offset(0, 0),
                      duration: 400.ms,
                      curve: Curves.easeOutQuad,
                    ),
                    FadeEffect(
                      begin: 0,
                      end: 1,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
                  ],
                  delay: 500.ms,
                  child: RoundedInput(
                    label: 'Password',
                    hint: 'Masukkan password anda',
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signIn(),
                  ),
                ),

                const SizedBox(height: 40),

                // Login button
                Animate(
                  effects: [
                    FadeEffect(duration: 400.ms),
                    ScaleEffect(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
                  ],
                  delay: 600.ms,
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.textHighlight,
                            ),
                          )
                          : RoundedButton(
                            text: 'Masuk',
                            onPressed: _signIn,
                            color: AppColors.textHighlight,
                            textColor: Colors.black,
                            width: double.infinity,
                            height: 50,
                          ),
                ),

                const SizedBox(height: 24),

                // Register link
                Center(
                      child: GestureDetector(
                        onTap: _navigateToRegister,
                        child: const Text.rich(
                          TextSpan(
                            text: 'Belum punya akun? ',
                            style: TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: 'Daftar',
                                style: TextStyle(
                                  color: AppColors.textHighlight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 40),

                // Terms and privacy policy text
                const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Dengan masuk, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi kami',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
