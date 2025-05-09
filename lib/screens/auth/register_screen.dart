import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_input.dart';
import '../../widgets/rounded_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _register() {
    // Proses registrasi (nanti integrasi Firebase/Auth)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: ListView(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.textHighlight),
                Text(
                  'Buat Akun',
                  style: TextStyle(
                    color: AppColors.textHighlight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Ayo Mulai',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            RoundedInput(
              label: 'Nama Lengkap',
              hint: 'example@example.com',
              controller: nameController,
            ),
            RoundedInput(
              label: 'Nomor Hp',
              hint: '+62 812 3456 7890',
              controller: phoneController,
            ),
            RoundedInput(
              label: 'Kata Sandi',
              hint: '************',
              controller: passwordController,
              isPassword: true,
            ),
            RoundedInput(
              label: 'Konfirmasi Kata Sandi',
              hint: '************',
              controller: confirmPasswordController,
              isPassword: true,
            ),
            RoundedButton(text: 'Daftar', onPressed: _register),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
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
            ),
          ],
        ),
      ),
    );
  }
}
