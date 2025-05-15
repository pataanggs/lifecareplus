import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'add_medication_screen.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    // Check if user has existing medications
    _checkExistingMedications();
  }

  Future<void> _checkExistingMedications() async {
    try {
      if (mounted) {
        setState(() {
        });
      }
    } catch (e) {
      debugPrint('Error checking medications: $e');
    }
  }

  void _createReminder() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05606B), // Teal at top
              Color(0xFF88C1D0), // Light blue in middle
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile and greeting
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
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
                ),

                const SizedBox(height: 24),

                // Back button and page title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      const Spacer(),

                      // Title
                      const Text(
                        'Pengobatan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),

                      // Empty space to balance layout
                      const SizedBox(width: 20),
                    ],
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                ),

                const SizedBox(height: 40),

                // Medication calendar icon
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                            width: 160,
                            height: 160,
                            child: Column(
                              children: [
                                // Calendar header
                                Container(
                                  width: 150,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF05606B),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 30,
                                        color: Color(0xFF05606B),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 10,
                                        color: Colors.transparent,
                                      ),
                                      Container(
                                        width: 15,
                                        height: 30,
                                        color: Color(0xFF05606B),
                                      ),
                                    ],
                                  ),
                                ),

                                // Calendar body
                                Container(
                                  width: 150,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9DBDC7),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          childAspectRatio: 1,
                                        ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF05606B),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 48),

                      // Title text
                      const Text(
                        'Mulai disini',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Buat Pengingat untuk pengobatan Anda, lacak stok obat, dan banyak lagi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 40),

                      // Create reminder button with consistent styling
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 16,
                          top: 40,
                        ),
                        child: RoundedButton(
                              text: 'Buat Pengingat Pertama',
                              onPressed: _createReminder,
                              color:
                                  AppColors
                                      .textHighlight, // Using the standard highlight color
                              textColor:
                                  Colors.black, // Black text for consistency
                              width:
                                  300, // Standard width used in other screens
                              height: 50, // Standard height
                              borderRadius: 25, // Standard borderRadius
                              elevation:
                                  3, // Standard elevation for shadow consistency
                            )
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                            .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOutQuad,
                            ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
