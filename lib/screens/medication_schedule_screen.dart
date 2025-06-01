import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '/cubits/medication-schedule/medication_schedule_cubit.dart';
import '/widgets/rounded_button.dart';
import 'medication_stock_screen.dart';
import '/utils/colors.dart';

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
  String _selectedDosage = '1 tablet';
  String _selectedTime = '08.00';
  bool _showContent = false;
  String _formattedDate = '';
  MedicationScheduleCubit? _medicationScheduleCubit;

  final List<Map<String, dynamic>> _dosageOptions = [
    {
      'value': '1 tablet',
      'icon': Icons.medication_outlined,
      'description': 'Satu tablet per dosis',
    },
    {
      'value': '2 tablet',
      'icon': Icons.medication_outlined,
      'description': 'Dua tablet per dosis',
    },
    {
      'value': '3 tablet',
      'icon': Icons.medication_outlined,
      'description': 'Tiga tablet per dosis',
    },
    {
      'value': '1 sendok teh',
      'icon': Icons.soup_kitchen_outlined,
      'description': 'Satu sendok teh per dosis',
    },
    {
      'value': '1 kapsul',
      'icon': Icons.medication_liquid_outlined,
      'description': 'Satu kapsul per dosis',
    },
  ];

  final List<Map<String, dynamic>> _timePresets = [
    {'time': '06.00', 'label': 'Pagi', 'icon': Icons.wb_sunny_outlined},
    {'time': '08.00', 'label': 'Pagi', 'icon': Icons.wb_sunny_outlined},
    {'time': '12.00', 'label': 'Siang', 'icon': Icons.wb_sunny_outlined},
    {'time': '19.00', 'label': 'Malam', 'icon': Icons.nightlight_round},
    {'time': '21.00', 'label': 'Malam', 'icon': Icons.nightlight_round},
    {'time': '22.00', 'label': 'Malam', 'icon': Icons.nightlight_round},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    _medicationScheduleCubit = MedicationScheduleCubit();
    _medicationScheduleCubit?.initialize();
    _setFormattedDate();
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

  @override
  void dispose() {
    _medicationScheduleCubit?.close();
    super.dispose();
  }

  void _proceed() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MedicationStockScreen(
              medicationName: widget.medicationName,
              frequency: widget.frequency,
              time: _selectedTime,
              dosage: _selectedDosage,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationScheduleCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _medicationScheduleCubit!,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<MedicationScheduleCubit, MedicationScheduleState>(
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
                          _buildHeader(state),
                          const SizedBox(height: 24),
                          _buildBackButton(),
                          const SizedBox(height: 40),
                          _buildMedicationInfo(),
                          const SizedBox(height: 40),
                          _buildScheduleSection(),
                          const SizedBox(height: 40),
                          _buildDosageSection(),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MedicationScheduleState state) {
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  color: Color(0xFF05606B),
                ),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.frequency,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ).animate(delay: 450.ms).fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      children: [
        Text(
          'Kapan baiknya kami mengingatkan Anda?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Colors.white.withOpacity(0.9),
          ),
        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Pilih waktu yang paling sesuai dengan jadwal Anda',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ).animate(delay: 550.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 40),
        _buildTimeSelector(),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Jam',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _showTimePickerSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildDosageSection() {
    return Column(
      children: [
        const Text(
          'Berapa dosis yang Anda butuhkan?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Colors.white,
          ),
        ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'Pilih dosis sesuai dengan anjuran dokter',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
        ).animate(delay: 750.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 40),
        _buildDosageSelector(),
      ],
    );
  }

  Widget _buildDosageSelector() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Dosis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: _showDosagePickerSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDosage,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 800.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildSubmitButton() {
    return Center(
      child: RoundedButton(
            text: 'Selanjutnya',
            onPressed: _proceed,
            color: AppColors.textHighlight,
            textColor: Colors.black,
            width: 300,
            height: 50,
            borderRadius: 25,
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

  void _showTimePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedTime = _selectedTime;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSheetHeader('Pilih Waktu'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTimeDisplay(tempSelectedTime),
                            const SizedBox(height: 30),
                            _buildTimePicker(tempSelectedTime, setModalState),
                            const SizedBox(height: 40),
                            _buildTimePresets(tempSelectedTime, setModalState),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildConfirmButton(() => Navigator.pop(context)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDosagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedDosage = _selectedDosage;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSheetHeader('Pilih Dosis'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDosageDisplay(tempSelectedDosage),
                            const SizedBox(height: 30),
                            _buildDosageOptions(
                              tempSelectedDosage,
                              setModalState,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildConfirmButton(() => Navigator.pop(context)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF05606B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        time,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Color(0xFF05606B),
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    String selectedTime,
    Function(void Function()) setModalState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimePickerColumn('Jam', selectedTime.split('.')[0], (index) {
          final hour = index.toString().padLeft(2, '0');
          final minutes = selectedTime.split('.')[1];
          setModalState(() => selectedTime = '$hour.$minutes');
          setState(() => _selectedTime = '$hour.$minutes');
        }, 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        _buildTimePickerColumn('Menit', selectedTime.split('.')[1], (index) {
          final minute = index.toString().padLeft(2, '0');
          final hour = selectedTime.split('.')[0];
          setModalState(() => selectedTime = '$hour.$minute');
          setState(() => _selectedTime = '$hour.$minute');
        }, 60),
      ],
    );
  }

  Widget _buildTimePickerColumn(
    String label,
    String selectedValue,
    Function(int) onChanged,
    int itemCount,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            overAndUnderCenterOpacity: 0.5,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final value = index.toString().padLeft(2, '0');
                final isSelected = selectedValue == value;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF05606B).withOpacity(0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? const Color(0xFF05606B) : Colors.black87,
                    ),
                  ),
                );
              },
            ),
            controller: FixedExtentScrollController(
              initialItem: int.parse(selectedValue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePresets(
    String selectedTime,
    Function(void Function()) setModalState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu yang disarankan:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _timePresets.map((preset) {
                final isSelected = selectedTime == preset['time'];
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setModalState(() => selectedTime = preset['time']);
                    setState(() => _selectedTime = preset['time']);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF05606B) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF05606B)
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF05606B,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          preset['icon'],
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${preset['time']} (${preset['label']})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDosageDisplay(String dosage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        dosage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF05606B),
        ),
      ),
    );
  }

  Widget _buildDosageOptions(
    String selectedDosage,
    Function(void Function()) setModalState,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children:
          _dosageOptions.map((option) {
            final isSelected = selectedDosage == option['value'];
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setModalState(() => selectedDosage = option['value']);
                setState(() => _selectedDosage = option['value']);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.42,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF05606B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF05606B)
                            : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: const Color(0xFF05606B).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          option['icon'],
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option['value'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildConfirmButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RoundedButton(
        text: 'Konfirmasi',
        onPressed: onPressed,
        color: AppColors.textHighlight,
        textColor: Colors.black,
        width: double.infinity,
        height: 50,
        borderRadius: 25,
      ),
    );
  }
}
