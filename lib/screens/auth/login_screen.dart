import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/screens/onboarding/gender_selection_screen.dart';
import '/screens/onboarding/age_selection_screen.dart';
import '/screens/onboarding/weight_input_screen.dart';
import '/screens/onboarding/height_input_screen.dart';
import '/screens/auth/register_screen.dart';
import '/utils/onboarding_preferences.dart';
import '/widgets/rounded_button.dart';
import '/cubits/auth/auth_cubit.dart';
import '/widgets/rounded_input.dart';
import '/utils/show_snackbar.dart';
import '/utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  bool _showContent = false;
  bool _isNavigating = false;

  AuthCubit? _authCubit;

  @override
  void initState() {
    super.initState();
    _setSystemUI();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    try {
      _authCubit = context.read<AuthCubit>();
    } catch (e) {
      SharedPreferences.getInstance().then((prefs) {
        setState(() {
          _authCubit = AuthCubit(prefs);
        });
      });
    }
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _authCubit?.close();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isNavigating || _authCubit == null) return;
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context, 'Email dan password harus diisi');
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      if (kDebugMode) {
        print("Starting email/password sign-in process");
      }
      await _authCubit!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign in: $e");
      }
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isNavigating || _authCubit == null) return;

    try {
      HapticFeedback.mediumImpact();
      if (kDebugMode) {
        print("Starting Google sign-in process");
      }
      final UserCredential credential = await _authCubit!.signInWithGoogle();
      await _handleSuccessfulLogin(credential);
    } catch (e) {
      if (kDebugMode) {
        print("Error during Google sign in: $e");
      }
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    }
  }

  Future<void> _handleSuccessfulLogin(UserCredential userCredential) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userId = userCredential.user?.uid ?? '';
      final bool hasCompletedOnboarding =
          prefs.getBool('${userId}_onboarding_completed') ?? false;

      if (hasCompletedOnboarding) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/onboarding',
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error handling successful login: $e");
      }
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/onboarding',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authCubit == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.textHighlight),
        ),
      );
    }

    return BlocProvider.value(
      value: _authCubit!,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateLoaded) {
            if (kDebugMode) {
              print("Successfully signed in with email/password");
            }
            _isNavigating = true;

            final hasCompletedOnboarding =
                await OnboardingPreferences.hasCompletedAllSteps();
            if (!hasCompletedOnboarding) {
              final nextStep =
                  await OnboardingPreferences.getNextIncompleteStep();
              if (kDebugMode) {
                print("nextStep: $nextStep");
              }

              switch (nextStep) {
                case 'gender':
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GenderSelectionScreen(),
                    ),
                  );
                  break;
                case 'age':
                  final gender = await OnboardingPreferences.getGender();
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AgeInputScreen(selectedGender: gender!),
                    ),
                  );
                  break;
                case 'weight':
                  final gender = await OnboardingPreferences.getGender();
                  final age = await OnboardingPreferences.getAge();
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return WeightInputScreen(
                          selectedGender: gender!,
                          selectedAge: age!,
                          selectedHeight: 173, // Default height
                        );
                      },
                    ),
                  );
                  break;
                case 'height':
                  final gender = await OnboardingPreferences.getGender();
                  final weight = await OnboardingPreferences.getWeight();
                  final age = await OnboardingPreferences.getAge();
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => HeightInputScreen(
                            selectedGender: gender!,
                            selectedAge: age!,
                            selectedWeight: weight!,
                          ),
                    ),
                  );
                  break;
                default:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
              }
            } else {
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          }

          if (state is AuthStateFailure) {
            if (context.mounted) {
              showSnackBar(context, 'Terjadi kesalahan saat masuk');
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 48,
                ),
                child: AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _headerComponent(context),
                      const SizedBox(height: 60),
                      _formComponent(state),
                      const SizedBox(height: 24),
                      _footerComponent(context),
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

  Widget _headerComponent(BuildContext context) {
    return Column(
      children: [
        Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        color: AppColors.textHighlight,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
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
      ],
    );
  }

  Widget _formComponent(AuthState state) {
    return Column(
      children: [
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
              state is AuthStateLoading
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
      ],
    );
  }

  Widget _footerComponent(BuildContext context) {
    return Column(
      children: [
        // Divider with "or" text
        Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau masuk dengan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
            )
            .animate(delay: 600.ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut),

        // Google Sign In Button
        SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Image.asset('assets/google_logo.png', height: 24),
                label: const Text(
                  'Masuk dengan Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _signInWithGoogle,
              ),
            )
            .animate(delay: 650.ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 24),

        // Register link
        Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BlocProvider.value(
                            value: _authCubit!, // Pass the existing instance
                            child: const RegisterScreen(),
                          ),
                    ),
                  );
                },
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

        // Terms and conditions
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Dengan masuk, Anda menyetujui Syarat & Ketentuan dan Kebijakan Privasi kami',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ).animate(delay: 800.ms).fadeIn(duration: 400.ms, curve: Curves.easeOut),
      ],
    );
  }
}
