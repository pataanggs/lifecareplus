import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifecareplus/cubits/medication-stock/medication_stock_cubit.dart';

import 'medication_summary_screen.dart';
import '/widgets/rounded_button.dart';
import '/utils/colors.dart';

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
  bool _reminderEnabled = true;
  int _reminderThreshold = 10;
  bool _showContent = false;
  int _currentStock = 30;
  late String _unitType;

  MedicationStockCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _unitType = _getUnitFromDosage();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _cubit = MedicationStockCubit();
    _cubit?.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _cubit?.close();
  }

  void _toggleReminder(bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      _reminderEnabled = value;
    });
  }

  void _saveSettings() {
    HapticFeedback.mediumImpact();
    _cubit?.saveMedicationData(
      medicationName: widget.medicationName,
      frequency: widget.frequency,
      time: widget.time,
      dosage: widget.dosage,
      unitType: _unitType,
      currentStock: _currentStock,
      reminderThreshold: _reminderThreshold,
      stockReminderEnabled: _reminderEnabled,
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
          if (_reminderThreshold > _currentStock) {
            _reminderThreshold = _currentStock > 1 ? _currentStock - 1 : 1;
          }
        });
      },
      suffix: _unitType,
    );
  }

  void _showThresholdEditor() {
    _showNumberPickerDialog(
      title: 'Atur Batas Pengingat',
      initialValue: _reminderThreshold,
      minValue: 1,
      maxValue: _currentStock - 1 > 0 ? _currentStock - 1 : 1,
      onChanged: (value) => setState(() => _reminderThreshold = value),
      suffix: _unitType,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocProvider.value(
      value: _cubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<MedicationStockCubit, MedicationStockState>(
          listener: (context, state) {
            if (state is MedicationStockStateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.data.errorMessage ?? 'Error')),
              );
            }

            if (state is MedicationStockStateSuccess) {
              if (state.data.isSuccess) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MedicationSummaryScreen(
                          stockReminderEnabled: _reminderEnabled,
                          medicationName: widget.medicationName,
                          reminderThreshold: _reminderThreshold,
                          currentStock: _currentStock,
                          frequency: widget.frequency,
                          dosage: widget.dosage,
                          unitType: _unitType,
                          time: widget.time,
                        ),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF05606B),
                    Color(0xFF88C1D0),
                    Color(0xFFB5D8E2),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                              'Hi, ${state.data.nickname}',
                                              style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                            )
                                            .animate(delay: 100.ms)
                                            .fadeIn(duration: 400.ms),
                                        const SizedBox(height: 4),
                                        Text(
                                              state.data.formattedDate,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                            )
                                            .animate(delay: 200.ms)
                                            .fadeIn(duration: 400.ms),
                                      ],
                                    ),
                                    Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: .2,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        )
                                        .animate(delay: 200.ms)
                                        .fadeIn(duration: 400.ms),
                                  ],
                                ),
                                const SizedBox(height: 24),
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
                                    )
                                    .animate(delay: 300.ms)
                                    .fadeIn(duration: 400.ms),
                                const SizedBox(height: 40),
                                Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: .05,
                                              ),
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
                                    )
                                    .animate(delay: 400.ms)
                                    .fadeIn(duration: 400.ms),
                                const SizedBox(height: 30),
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
                                Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ingatkan Saya',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap:
                                              () => _toggleReminder(
                                                !_reminderEnabled,
                                              ),
                                          child: Container(
                                            width: 70,
                                            height: 38,
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeOut,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    .animate(delay: 600.ms)
                                    .fadeIn(duration: 400.ms),
                                const SizedBox(height: 60),
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
                                    InkWell(
                                      onTap:
                                          _reminderEnabled
                                              ? _showStockEditor
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
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                                            ? const Color(
                                                              0xFF9C4380,
                                                            )
                                                            : Colors
                                                                .grey
                                                                .shade500,
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
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                                                            ? const Color(
                                                              0xFF9C4380,
                                                            )
                                                            : Colors
                                                                .grey
                                                                .shade500,
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
                              width: double.infinity,
                              height: 56,
                              borderRadius: 28,
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
            );
          },
        ),
      ),
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
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        Container(
                          width: 200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF05606B,
                            ).withValues(alpha: .1),
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
              color: Colors.black.withValues(alpha: .2),
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
}
