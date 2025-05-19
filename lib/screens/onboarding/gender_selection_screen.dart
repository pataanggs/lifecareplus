import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_button.dart';
import 'age_selection_screen.dart'; // Add this import
import '../../utils/onboarding_preferences.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  void _selectGender(String gender) async {
    setState(() {
      selectedGender = gender;
    });
    await OnboardingPreferences.saveGender(gender);
  }

  void _onNext() {
    if (selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih salah satu gender')));
      return;
    }

    // Navigate to AgeInputScreen and pass the selected gender
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgeInputScreen(selectedGender: selectedGender!),
      ),
    );
  }

  Widget _buildGenderOption({
    required String label,
    required bool isMale,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color circleColor =
        isMale ? const Color(0xFFD6E56C) : const Color(0xFFD6E56C);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: isSelected ? circleColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? circleColor : Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                isMale ? Icons.male : Icons.female,
                color: isSelected ? Colors.black : Colors.white,
                size: 70,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Back + Kembali
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: AppColors.textHighlight),
                    SizedBox(width: 4),
                    Text(
                      'Kembali',
                      style: TextStyle(
                        color: AppColors.textHighlight,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Title
              const Center(
                child: Text(
                  'Jenis Kelamin Anda?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Gender Options in Expanded to center them
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGenderOption(
                        label: 'Laki-Laki',
                        isMale: true,
                        isSelected: selectedGender == 'Laki-Laki',
                        onTap: () => _selectGender('Laki-Laki'),
                      ),
                      const SizedBox(height: 40),
                      _buildGenderOption(
                        label: 'Perempuan',
                        isMale: false,
                        isSelected: selectedGender == 'Perempuan',
                        onTap: () => _selectGender('Perempuan'),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Selanjutnya
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  child: RoundedButton(text: 'Selanjutnya', onPressed: _onNext, color: AppColors.textHighlight, textColor: Colors.black,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
