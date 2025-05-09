import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_button.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void _proceed() {
    if (selectedGender != null) {
      // Simpan ke state global / Firebase / local db
      // Lanjut ke halaman selanjutnya
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gender tersimpan: $selectedGender')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih salah satu terlebih dahulu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back_ios, color: AppColors.textHighlight),
                Text('Kembali', style: TextStyle(color: AppColors.textHighlight, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 36),
            const Center(
              child: Text('Jenis Kelamin Anda?',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _genderButton(
                    icon: Icons.male,
                    label: 'Laki-Laki',
                    selected: selectedGender == 'Laki-Laki',
                    onTap: () => _selectGender('Laki-Laki'),
                  ),
                  const SizedBox(height: 24),
                  _genderButton(
                    icon: Icons.female,
                    label: 'Perempuan',
                    selected: selectedGender == 'Perempuan',
                    onTap: () => _selectGender('Perempuan'),
                  ),
                ],
              ),
            ),
            RoundedButton(text: 'Selanjutnya', onPressed: _proceed),
          ],
        ),
      ),
    );
  }

  Widget _genderButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: selected ? AppColors.textHighlight : AppColors.background,
            child: Icon(icon, size: 60, color: selected ? Colors.black : Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}
