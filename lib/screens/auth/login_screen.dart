import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_input.dart';
import '../../widgets/rounded_button.dart';
import '../auth/register_screen.dart';
import '../onboarding/gender_selection_screen.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    // Login sukses → pindah ke GenderSelection
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GenderSelectionScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: ListView(
          children: [
            // Baris atas: Kembali dan Masuk
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                // Add invisible icon to balance the layout
                const SizedBox(width: 24),
              ],
            ),

            const SizedBox(height: 36),

            // Selamat Datang
            const Center(
              child: Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Input Email
            RoundedInput(
              label: 'Nama Pengguna/Email',
              hint: 'example@example.com',
              controller: emailController,
            ),

            // Input Password
            RoundedInput(
              label: 'Kata Sandi',
              hint: '**************',
              isPassword: true,
              controller: passwordController,
            ),

            // Lupa kata sandi
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            // Tombol Masuk
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 16),
              child: RoundedButton(
                text: 'Masuk',
                onPressed: () => _login(context), color: AppColors.textHighlight, textColor: Colors.white,
              ),
            ),

            // Daftar
            Center(
              child: GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen()),
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}
