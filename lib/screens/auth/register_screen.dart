import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../utils/colors.dart';
import '../../utils/show_snackbar.dart';
import '../../widgets/rounded_input.dart';
import '../../widgets/rounded_button.dart';
import '../onboarding/gender_selection_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _showContent = false;
  bool _isNavigating = false;

  late AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    SharedPreferences.getInstance().then((prefs) {
      _authCubit = AuthCubit(prefs);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _authCubit.close();
    super.dispose();
  }

  void _register() async {
    if (_isNavigating) return;
    HapticFeedback.lightImpact();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validate inputs
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Semua field harus diisi');
      return;
    }

    if (password != confirmPassword) {
      showSnackBar(context, 'Password tidak sama');
      return;
    }

    if (password.length < 6) {
      showSnackBar(context, 'Password minimal 6 karakter');
      return;
    }

    try {
      await _authCubit.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthStateLoaded) {
            _isNavigating = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
            );
          }

          if (state is AuthStateFailure) {
            if (mounted) {
              showSnackBar(context, 'Terjadi kesalahan saat mendaftar');
            }
          }
        },
        builder: (context, state) {
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
                      // Header with back button
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
                          Expanded(
                            child: Center(
                              child: Text(
                                'Buat Akun',
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

                      const SizedBox(height: 24),

                      // Welcome text
                      const Center(
                        child: Text(
                          'Ayo Mulai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut),

                      const SizedBox(height: 24),

                      // Form fields - staggered animations
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
                          label: 'Nama Lengkap',
                          hint: 'Masukkan nama lengkap anda',
                          controller: nameController,
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
                        delay: 350.ms,
                        child: RoundedInput(
                          label: 'Email',
                          hint: 'example@example.com',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
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
                          label: 'Nomor Hp',
                          hint: '+62 812 3456 7890',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
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
                        delay: 500.ms,
                        child: RoundedInput(
                          label: 'Kata Sandi',
                          hint: '************',
                          controller: passwordController,
                          isPassword: true,
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
                        delay: 600.ms,
                        child: RoundedInput(
                          label: 'Konfirmasi Kata Sandi',
                          hint: '************',
                          controller: confirmPasswordController,
                          isPassword: true,
                        ),
                      ),

                      // Register button
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
                            ),
                          ],
                          delay: 700.ms,
                          child: state is AuthStateLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.textHighlight,
                                  ),
                                )
                              : RoundedButton(
                                  text: 'Daftar',
                                  onPressed: _register,
                                  color: AppColors.textHighlight,
                                  textColor: Colors.black,
                                ),
                        ),
                      ),

                      // Login link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context);
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: 'Kamu sudah punya akun? ',
                              style: TextStyle(color: Colors.white),
                              children: [
                                TextSpan(
                                  text: 'Masuk',
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
                      .animate(delay: 800.ms)
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
