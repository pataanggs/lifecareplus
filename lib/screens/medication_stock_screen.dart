import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'medication_summary_screen.dart';

class MedicationStockScreen extends StatefulWidget {
  final String medicationName;
  final String frequency;
  final String time;
  final String dosage;

  const MedicationStockScreen({
    super.key,
    required this.medicationName,
    required this.frequency,
    required this.time,
    required this.dosage,
  });

  @override
  State<MedicationStockScreen> createState() => _MedicationStockScreenState();
}

class _MedicationStockScreenState extends State<MedicationStockScreen> {
  bool _showContent = false;
  bool _reminderEnabled = true;
  int _currentStock = 30;
  int _reminderThreshold = 10;
  late String _unitType; // Store the unit type

  @override
  void initState() {
    super.initState();
    _unitType = _getUnitFromDosage(); // Set unit type from dosage
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _toggleReminder(bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      _reminderEnabled = value;
    });
  }

  // Replace the _saveSettings method with this updated version
  void _saveSettings() {
    HapticFeedback.mediumImpact();

    // Navigate to the summary screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicationSummaryScreen(
              medicationName: widget.medicationName,
              frequency: widget.frequency,
              time: widget.time,
              dosage: widget.dosage,
              stockReminderEnabled: _reminderEnabled,
              currentStock: _currentStock,
              reminderThreshold: _reminderThreshold,
              unitType: _unitType,
            ),
      ),
    );
  }

  void _showStockEditor() {
    _showNumberPickerDialog(
      title: 'Atur Jumlah Persediaan',
      initialValue: _currentStock,
      minValue: 1,
      maxValue: 100,
      onChanged: (value) {
        setState(() {
          _currentStock = value;
          // Ensure threshold is not greater than current stock
          if (_reminderThreshold > _currentStock) {
            _reminderThreshold = _currentStock > 1 ? _currentStock - 1 : 1;
          }
        });
      },
      suffix: _unitType, // Use the dynamically determined unit
    );
  }

  void _showThresholdEditor() {
    _showNumberPickerDialog(
      title: 'Atur Batas Pengingat',
      initialValue: _reminderThreshold,
      minValue: 1,
      maxValue: _currentStock - 1 > 0 ? _currentStock - 1 : 1,
      onChanged: (value) => setState(() => _reminderThreshold = value),
      suffix: _unitType, // Use the dynamically determined unit
    );
  }

  void _showNumberPickerDialog({
    required String title,
    required int initialValue,
    required int minValue,
    required int maxValue,
    required Function(int) onChanged,
    required String suffix,
  }) {
    int tempValue = initialValue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF05606B),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Value display
                        Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF05606B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF05606B),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$tempValue $suffix',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF05606B),
                            ),
                          ),
                        ),

                        // Plus/minus controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton(
                              icon: Icons.remove,
                              onPressed: () {
                                if (tempValue > minValue) {
                                  setModalState(() => tempValue--);
                                }
                              },
                            ),
                            const SizedBox(width: 20),
                            _buildControlButton(
                              icon: Icons.add,
                              onPressed: () {
                                if (tempValue < maxValue) {
                                  setModalState(() => tempValue++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Confirm button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RoundedButton(
                      text: 'Konfirmasi',
                      onPressed: () {
                        onChanged(tempValue);
                        Navigator.pop(context);
                      },
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: 300,
                      height: 50,
                      borderRadius: 25,
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF05606B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  // Add this helper method to extract the unit from dosage
  String _getUnitFromDosage() {
    // Extract the unit part from dosage (e.g., "2 tablet" -> "tablet", "1 kapsul" -> "kapsul")
    final parts = widget.dosage.split(' ');
    if (parts.length >= 2) {
      return parts[1]; // Return the unit part (tablet, kapsul, etc.)
    }
    return 'tablet'; // Default fallback
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
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                                      )
                                      .animate(delay: 100.ms)
                                      .fadeIn(duration: 400.ms),

                                  const SizedBox(height: 4),

                                  Text(
                                        'SABTU, DES 28',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      )
                                      .animate(delay: 200.ms)
                                      .fadeIn(duration: 400.ms),
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

                          // Medication name display
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.medicationName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF444444),
                                ),
                              ),
                            ),
                          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 30),

                          // Question text
                          Center(
                            child: Text(
                              'Apakah Anda butuh pengingat untuk\nmengisi ulang persediaan obat?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 40),

                          // Toggle switch row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ingatkan Saya',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),

                              // Custom Switch
                              GestureDetector(
                                onTap: () => _toggleReminder(!_reminderEnabled),
                                child: Container(
                                  width: 70,
                                  height: 38,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        _reminderEnabled
                                            ? const Color(0xFF05606B)
                                            : Colors.grey.shade300,
                                  ),
                                  child: AnimatedAlign(
                                    alignment:
                                        _reminderEnabled
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 60),

                          // Current stock section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Persediaan saat ini',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Stock display with tap functionality
                              InkWell(
                                onTap:
                                    _reminderEnabled ? _showStockEditor : null,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color:
                                          _reminderEnabled
                                              ? Colors.transparent
                                              : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Jumlah',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$_currentStock $_unitType',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _reminderEnabled
                                                      ? const Color(0xFF9C4380)
                                                      : Colors.grey.shade500,
                                            ),
                                          ),
                                          if (_reminderEnabled) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.edit,
                                              color: Color(0xFF9C4380),
                                              size: 18,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 30),

                          // Reminder threshold section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingatkan saya saat:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _reminderEnabled
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade500,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Threshold display with tap functionality
                              InkWell(
                                onTap:
                                    _reminderEnabled
                                        ? _showThresholdEditor
                                        : null,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color:
                                          _reminderEnabled
                                              ? Colors.transparent
                                              : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Sisa Persediaan',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '$_reminderThreshold $_unitType',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _reminderEnabled
                                                      ? const Color(0xFF9C4380)
                                                      : Colors.grey.shade500,
                                            ),
                                          ),
                                          if (_reminderEnabled) ...[
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.edit,
                                              color: Color(0xFF9C4380),
                                              size: 18,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).animate(delay: 800.ms).fadeIn(duration: 400.ms),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),

                // Save button at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: RoundedButton(
                        text: 'Simpan',
                        onPressed: _saveSettings,
                        color: AppColors.textHighlight,
                        textColor: Colors.black,
                        width:
                            double
                                .infinity, // Changed to match the full width of the screen
                        height:
                            56, // Increased height for better visibility as final action
                        borderRadius:
                            28, // Matches the radius of the input fields
                        elevation: 3,
                      )
                      .animate(delay: 900.ms)
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
    );
  }
}
