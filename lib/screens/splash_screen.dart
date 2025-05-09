import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            Image.asset('assets/lifecare_logo.png', width: 200),
            const Spacer(),
Padding(
  padding: const EdgeInsets.only(bottom: 40.0),
  child: RoundedButton(
    text: 'Mulai',
    onPressed: () => _navigateToHome(context),
  ),
),
          ],
        ),
      ),
    );
  }
}
