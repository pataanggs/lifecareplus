import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.topGradient, AppColors.bottomGradient],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/lifecareplus_logo.png', width: 200),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: RoundedButton(
                  text: 'Mulai',
                  onPressed: () => _navigateToLogin(context),
                  color: Colors.white, textColor: AppColors.buttonTextColor, // ✅ default optional
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
