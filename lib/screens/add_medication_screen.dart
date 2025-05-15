import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../utils/show_snackbar.dart';
import '../widgets/rounded_button.dart';
import 'medication_frequency_screen.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  bool _showContent = false;
  final TextEditingController _medicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }

  void _addReminder() {
    if (_medicationController.text.isEmpty) {
      showSnackBar(context, 'Silakan masukkan nama obat terlebih dahulu');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MedicationFrequencyScreen(
              medicationName: _medicationController.text,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Add this line to handle keyboard properly
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
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: SingleChildScrollView(
              // Wrap with SingleChildScrollView
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
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

                    // Back button with "Kembali" text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
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
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                    ),

                    const SizedBox(height: 60),

                    // Medication form area
                    Flexible(
                      // Changed from Expanded to Flexible
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Medicine icon
                            Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.medical_services_outlined,
                                      size: 60,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                )
                                .animate(delay: 400.ms)
                                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.0, 1.0),
                                  duration: 600.ms,
                                  curve: Curves.easeOutQuad,
                                ),

                            const SizedBox(height: 60),

                            // Instructions text
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Buat Pengingat: Ketik nama obat, vitamin, atau suplemen anda',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ).animate(delay: 500.ms).fadeIn(duration: 500.ms),

                            const SizedBox(height: 60),

                            // Medication name input field
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: TextField(
                                controller: _medicationController,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Nama obat...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF05606B),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
                          ],
                        ),
                      ),
                    ),

                    // Add reminder button with adjusted styling for this screen
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32,
                        right: 32,
                        bottom: 40,
                      ),
                      child: RoundedButton(
                            text: 'Tambah Pengingat',
                            onPressed: _addReminder,
                            color:
                                AppColors
                                    .textHighlight, // Keeping the standard highlight color
                            textColor:
                                Colors.black, // Keeping the standard text color
                            width:
                                double
                                    .infinity, // Changed to match full width of the container
                            height:
                                56, // Increased height to better fit this screen
                            borderRadius:
                                30, // Increased to match the input field border radius
                            elevation: 3, // Keeping the standard shadow
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
            ),
          ),
        ),
      ),
    );
  }
}

class MedicationScheduleScreen extends StatefulWidget {
  final String medicationName;
  final String frequency;

  const MedicationScheduleScreen({
    super.key,
    required this.medicationName,
    required this.frequency,
  });

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Schedule'),
        backgroundColor: const Color(0xFF05606B),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Schedule setup for ${widget.medicationName} (${widget.frequency})',
        ),
      ),
    );
  }
}
