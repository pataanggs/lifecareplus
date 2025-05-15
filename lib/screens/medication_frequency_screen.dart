import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'medication_schedule_screen.dart';

class MedicationFrequencyScreen extends StatefulWidget {
  final String medicationName;

  const MedicationFrequencyScreen({super.key, required this.medicationName});

  @override
  State<MedicationFrequencyScreen> createState() =>
      _MedicationFrequencyScreenState();
}

class _MedicationFrequencyScreenState extends State<MedicationFrequencyScreen> {
  bool _showContent = false;
  String _selectedFrequency = 'Sekali Sehari'; // Default selection

  final List<String> _frequencies = [
    'Sekali Sehari',
    'Dua Kali Sehari',
    'Tanpa Jadwal (Tanpa Alarm)',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _proceed() {
    HapticFeedback.mediumImpact();

    // Navigate to next screen (schedule setting)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationScheduleScreen(
          medicationName: widget.medicationName,
          frequency: _selectedFrequency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05606B), // Teal at top
              Color(0xFF88C1D0), // Light blue in middle
              Color(0xFFB5D8E2), // Lighter blue at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Header with profile and greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Greeting text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, Asavira',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                            const SizedBox(height: 4),

                            Text(
                              'SABTU, DES 28',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                          ],
                        ),

                        // Profile icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Back button with "Kembali" text
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kembali',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),

                    // Medication form section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Medication name label
                        Text(
                          'Nama Obat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade200,
                          ),
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 8),

                        // Medication name input (non-editable)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.medicationName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 40),

                        // Frequency question
                        Center(
                          child: Text(
                            'Seberapa sering Anda butuh\nminum obat ini?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                        const SizedBox(height: 32),

                        // Frequency options with radio buttons
                        ..._frequencies.asMap().entries.map((entry) {
                          final index = entry.key;
                          final frequency = entry.value;
                          return _buildFrequencyOption(
                            frequency: frequency,
                            delay: 700 + (index * 100),
                          );
                        }),

                        const SizedBox(height: 40),
                      ],
                    ),

                    // Next button with consistent styling
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: RoundedButton(
                              text: 'Selanjutnya',
                              onPressed: _proceed,
                              color:
                                  AppColors
                                      .textHighlight, // Changed to match app standard color
                              textColor:
                                  Colors
                                      .black, // Changed to black for consistency
                              width: 300, // Changed to standard width
                              height: 50, // Changed to standard height
                              borderRadius: 25, // Changed to standard radius
                              elevation: 3, // Standard elevation
                            )
                            .animate(delay: 1100.ms)
                            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOutQuad,
                            ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyOption({
    required String frequency,
    required int delay,
  }) {
    final isSelected = _selectedFrequency == frequency;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFrequency = frequency);
      },
      child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF9AC0C9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    frequency,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? const Color(0xFF05606B) : Colors.white,
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF05606B)
                                : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                            : null,
                  ),
                ],
              ),
            ),
          )
          .animate(delay: delay.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideX(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
