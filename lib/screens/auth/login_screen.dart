import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_input.dart';
import '../../widgets/rounded_button.dart';
import '../auth/register_screen.dart';
import '../home_screen.dart';
import '../../utils/show_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
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
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    HapticFeedback.lightImpact();
    
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Email dan password wajib diisi');
      return;
    }

    
    try {
      await _authService.signInWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah, silakan coba lagi';
          break;
        case 'user-disabled':
          errorMessage = 'Akun anda telah dinonaktifkan';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Gagal login. Silakan coba lagi';
      }
      
      if (mounted) {
        showSnackBar(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Terjadi kesalahan sistem');
      }
    } finally {
      if (mounted) {
      }
    }
  }

  void _resetPassword() async {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      showSnackBar(context, 'Masukkan email untuk reset password');
      return;
    }
    
    
    try {
      await _authService.resetPassword(email);
      if (mounted) {
        showSnackBar(
          context, 
          'Email reset password telah dikirim ke $email',
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Gagal mengirim email reset password');
      }
    } finally {
      if (mounted) {
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
                ).animate(delay: 100.ms).slideY(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(
                  duration: 400.ms, 
                  curve: Curves.easeOut,
                ),

                const SizedBox(height: 36),

                // Form inputs
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
                  delay: 300.ms,
                  child: RoundedInput(
                    label: 'Nama Pengguna/Email',
                    hint: 'example@example.com',
                    controller: emailController,
                  ),
                ),

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
                    label: 'Kata Sandi',
                    hint: '**************',
                    isPassword: true,
                    controller: passwordController,
                  ),
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _resetPassword();
                    },
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),

                // Login button
                Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Animate(
                    effects: [
                      FadeEffect(duration: 400.ms),
                      ScaleEffect(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      )
                    ],
                    delay: 600.ms,
                    child: RoundedButton(
                      text: 'Masuk',
                      onPressed: () => _login(context),
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                    ),
                  ),
                ),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Kamu belum punya akun? ',
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Daftar Sekarang',
                            style: TextStyle(
                              color: AppColors.textHighlight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn(
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}