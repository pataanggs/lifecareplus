import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '/cubits/medication-stock/medication_stock_cubit.dart';
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
  String _formattedDate = '';
  MedicationStockCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _unitType = _getUnitFromDosage();
    _setFormattedDate();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _cubit = MedicationStockCubit();
    _cubit?.initialize();
    _showAlarmInfoIfNeeded();
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID');
    final formatted = formatter.format(now);
    _formattedDate = formatted
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');
  }

  void _showAlarmInfoIfNeeded() {
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 800), () {
        _showAlarmPermissionInfo();
      });
    }
  }

  void _showAlarmPermissionInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text('Penting'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Untuk pengingat obat yang akurat, pastikan izin "Pengaturan Alarm" atau '
                  '"Alarm & Reminder" diaktifkan.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Anda dapat mengaturnya di Pengaturan > Aplikasi > LifeCarePlus > Izin.',
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Saya Mengerti'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _cubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocConsumer<MedicationStockCubit, MedicationStockState>(
          listener: (context, state) {
            if (state is MedicationStockStateError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.data.errorMessage ?? 'Error')),
                    ],
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                                _buildHeader(state),
                                const SizedBox(height: 24),
                                _buildBackButton(),
                                const SizedBox(height: 40),
                                _buildMedicationInfo(),
                                const SizedBox(height: 30),
                                _buildReminderQuestion(),
                                const SizedBox(height: 40),
                                _buildReminderToggle(),
                                const SizedBox(height: 60),
                                _buildStockSection(),
                                const SizedBox(height: 30),
                                _buildThresholdSection(),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildSubmitButton(),
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

  Widget _buildHeader(MedicationStockState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${state.data.nickname}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 4),
            Text(
              _formattedDate,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ],
        ),
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
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildMedicationInfo() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              color: Colors.teal.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget.medicationName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444444),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildReminderQuestion() {
    return Center(
      child: Column(
        children: [
          Text(
            'Apakah Anda butuh pengingat untuk\nmengisi ulang persediaan obat?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.teal.shade700, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Kami akan mengingatkan Anda saat persediaan hampir habis',
                  style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildReminderToggle() {
    return Row(
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
                      ? Colors.teal.shade700
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
                      color: Colors.black.withOpacity(0.1),
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
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.teal.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Persediaan saat ini',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _reminderEnabled ? _showStockEditor : null,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                ? Colors.teal.shade700
                                : Colors.grey.shade500,
                      ),
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.edit, color: Colors.teal.shade700, size: 18),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: 700.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildThresholdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active_outlined,
              color: Colors.teal.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
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
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _reminderEnabled ? _showThresholdEditor : null,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                ? Colors.teal.shade700
                                : Colors.grey.shade500,
                      ),
                    ),
                    if (_reminderEnabled) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.edit, color: Colors.teal.shade700, size: 18),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: 800.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
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
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.teal.shade700,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$tempValue $suffix',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
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
                                  HapticFeedback.selectionClick();
                                  setModalState(() => tempValue--);
                                }
                              },
                            ),
                            const SizedBox(width: 20),
                            _buildControlButton(
                              icon: Icons.add,
                              onPressed: () {
                                if (tempValue < maxValue) {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => tempValue++);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: RoundedButton(
                      text: 'Konfirmasi',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
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
          color: Colors.teal.shade700,
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

  String _getUnitFromDosage() {
    final parts = widget.dosage.split(' ');
    if (parts.length >= 2) {
      return parts[1];
    }
    return 'tablet';
  }
}
