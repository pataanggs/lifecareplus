import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';
import '../../utils/show_snackbar.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controls when we show the main content
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    // Slight delay before starting animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      developer.log("Starting Google sign-in process");

      // First ensure we're signed out from any previous sessions
      try {
        await _authService.signOut();
        developer.log("Successfully signed out from previous sessions");
      } catch (e) {
        developer.log("Error during sign-out: $e");
        // Continue anyway
      }

      final UserCredential? userCredential =
          await _authService.signInWithGoogle();

      if (userCredential == null) {
        // User canceled the sign-in flow
        developer.log("Google sign-in was cancelled by user");
        if (mounted) {
          showSnackBar(context, 'Sign-in dibatalkan');
        }
        return;
      }

      developer.log("Successfully got userCredential from Google sign-in");

      // Check if user data is complete
      final User user = userCredential.user!;
      developer.log("User ID: ${user.uid}");
      developer.log("User email: ${user.email}");
      developer.log("Fetching user profile from Firestore");

      final userProfile = await _authService.getUserProfile(user.uid);
      developer.log("User profile retrieved: ${userProfile != null}");

      if (mounted) {
        // If user profile exists but gender/age/height/weight are not set
        // we should send them to onboarding to complete their profile
        if (userProfile == null ||
            userProfile.gender.isEmpty ||
            userProfile.age == 0 ||
            userProfile.height == 0 ||
            userProfile.weight == 0) {
          developer.log("User needs to complete onboarding");
          // Navigate to onboarding
          Navigator.pushReplacementNamed(context, '/onboarding');
        } else {
          developer.log("User profile is complete, navigating to home");
          // Navigate to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Gagal masuk dengan Google';
      developer.log("FirebaseAuthException during Google sign-in: ${e.code}");

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'Akun sudah terdaftar dengan metode login yang berbeda';
          break;
        case 'invalid-credential':
          errorMessage = 'Kredensial tidak valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Login dengan Google tidak diizinkan';
          break;
        case 'user-disabled':
          errorMessage = 'Akun anda telah dinonaktifkan';
          break;
        case 'user-not-found':
          errorMessage = 'Akun tidak ditemukan';
          break;
        default:
          errorMessage = 'Gagal masuk dengan Google: ${e.message}';
      }

      if (mounted) {
        showSnackBar(context, errorMessage);
      }
    } catch (e) {
      developer.log("General exception during Google sign-in: $e");
      print('Detailed Google Sign-In error: $e');
      if (mounted) {
        showSnackBar(context, 'Terjadi kesalahan saat masuk dengan Google');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

                const SizedBox(height: 80),

                // Description text
                const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Masuk dengan Google untuk melanjutkan dan menikmati layanan LifeCare+',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut),

                const SizedBox(height: 48),

                // Google Sign In button
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Animate(
                    effects: [
                      FadeEffect(duration: 400.ms),
                      ScaleEffect(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                    ],
                    delay: 500.ms,
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.textHighlight,
                              ),
                            )
                            : ElevatedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 3,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Masuk dengan Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ),

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
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
