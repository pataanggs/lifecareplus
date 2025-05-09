import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_button.dart';

class ProfileDataScreen extends StatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final age = int.parse(_ageController.text);
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);

      // TODO: Simpan data ke database / Firestore / state management
      _saveUserData(age, height, weight);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data disimpan! Lanjut ke dashboard...')),
      );

      // Navigasi ke dashboard atau halaman berikutnya
    }
  }
  
  void _saveUserData(int age, double height, double weight) {
    // Placeholder function to use the variables
    // TODO: Implement actual data saving logic
    print('Saving user data: Age: $age, Height: $height cm, Weight: $weight kg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Lengkapi Data Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              _buildTextField(
                controller: _ageController,
                label: 'Usia (tahun)',
                hint: 'Contoh: 23',
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v < 1 || v > 120) return 'Usia tidak valid';
                  return null;
                },
              ),
              _buildTextField(
                controller: _heightController,
                label: 'Tinggi Badan (cm)',
                hint: 'Contoh: 170',
                validator: (value) {
                  final v = double.tryParse(value ?? '');
                  if (v == null || v < 50 || v > 250) {
                    return 'Tinggi tidak valid';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _weightController,
                label: 'Berat Badan (kg)',
                hint: 'Contoh: 60',
                validator: (value) {
                  final v = double.tryParse(value ?? '');
                  if (v == null || v < 20 || v > 300) {
                    return 'Berat tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              RoundedButton(
                text: 'Simpan dan Lanjutkan',
                onPressed: _saveProfile, color: AppColors.textHighlight, textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          validator: validator,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
