import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Assuming these imports are correct and files exist
import '/cubits/medication-schedule/medication_schedule_cubit.dart';
import '/widgets/rounded_button.dart'; // Ensure this widget is also responsive
import 'medication_stock_screen.dart';
import '/utils/colors.dart'; // Assuming AppColors.textHighlight is defined here

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
          (word) => word.isNotEmpty
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
        builder: (context) => MedicationStockScreen(
          medicationName: widget.medicationName,
          frequency: widget.frequency,
          time: _selectedTime,
          dosage: _selectedDosage,
        ),
      ),
    );
  }

  // Helper for responsive font size, adjust clamping as needed
  double _responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor with clamping to prevent excessively large/small fonts
    final factor = (screenWidth / 375.0).clamp(0.85, 1.2);
    return baseSize * factor;
  }


  @override
  Widget build(BuildContext context) {
    if (_medicationScheduleCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                      // Responsive padding
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.02), // Initial top spacing
                          _buildHeader(state, screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.02), // Responsive spacing
                          _buildBackButton(screenWidth),
                          SizedBox(height: screenHeight * 0.04), // Responsive spacing
                          _buildMedicationInfo(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.04), // Responsive spacing
                          _buildScheduleSection(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.04), // Responsive spacing
                          _buildDosageSection(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.05), // Responsive spacing
                          _buildSubmitButton(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.05), // Responsive spacing (ensure content doesn't stick to bottom)
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

  Widget _buildHeader(MedicationScheduleState state, double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${state.data.nickname}',
              style: TextStyle(
                // Responsive font size
                fontSize: _responsiveFontSize(context, 24), // Adjusted base size
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            SizedBox(height: screenHeight * 0.005), // Responsive spacing
            Text(
              _formattedDate,
              style: TextStyle(
                fontSize: _responsiveFontSize(context, 13), // Adjusted base size
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ],
        ),
        Container(
          // Responsive size
          width: screenWidth * 0.12,
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: Colors.white,
            // Responsive icon size
            size: screenWidth * 0.07,
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildBackButton(double screenWidth) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios, color: Colors.white,
            // Responsive icon size
            size: screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.02), // Responsive spacing
          Text(
            'Kembali',
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 17), // Adjusted base size
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildMedicationInfo(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          // Responsive padding
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06, vertical: screenHeight * 0.018),
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
                // Responsive icon size
                size: screenWidth * 0.065,
              ),
              SizedBox(width: screenWidth * 0.03), // Responsive spacing
              Flexible( // Added Flexible to prevent overflow with long medication names
                child: Text(
                  widget.medicationName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveFontSize(context, 22), // Adjusted base size
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05606B),
                  ),
                  overflow: TextOverflow.ellipsis, // Handle overflow
                  maxLines: 2, // Allow up to two lines
                ),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
        SizedBox(height: screenHeight * 0.018), // Responsive spacing
        Container(
          // Responsive padding
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.009),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.frequency,
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 13), // Adjusted base size
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ).animate(delay: 450.ms).fadeIn(duration: 500.ms),
      ],
    );
  }

  Widget _buildScheduleSection(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          'Kapan baiknya kami mengingatkan Anda?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _responsiveFontSize(context, 20), // Adjusted base size
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Colors.white.withOpacity(0.9),
          ),
        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        SizedBox(height: screenHeight * 0.01), // Responsive spacing
        Text(
          'Pilih waktu yang paling sesuai dengan jadwal Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: _responsiveFontSize(context, 13), color: Colors.white.withOpacity(0.7)),
        ).animate(delay: 550.ms).fadeIn(duration: 400.ms),
        SizedBox(height: screenHeight * 0.035), // Responsive spacing
        _buildTimeSelector(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildTimeSelector(double screenWidth, double screenHeight) {
    return Row(
      children: [
        Expanded(
          flex: 2, // Give more space to label if needed
          child: Text(
            'Jam',
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 20), // Adjusted base size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          flex: 3, // Give more space to picker
          child: InkWell(
            onTap: _showTimePickerSheet,
            child: Container(
              // Responsive padding
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: screenHeight * 0.014),
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
                        // Responsive icon size
                        size: screenWidth * 0.055,
                      ),
                      SizedBox(width: screenWidth * 0.02), // Responsive spacing
                      Text(
                        _selectedTime,
                        style: TextStyle(
                          fontSize: _responsiveFontSize(context, 18), // Adjusted base size
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey, size: screenWidth * 0.06),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildDosageSection(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          'Berapa dosis yang Anda butuhkan?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _responsiveFontSize(context, 20), // Adjusted base size
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Colors.white,
          ),
        ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
        SizedBox(height: screenHeight * 0.01), // Responsive spacing
        Text(
          'Pilih dosis sesuai dengan anjuran dokter',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: _responsiveFontSize(context, 13), color: Colors.white.withOpacity(0.7)),
        ).animate(delay: 750.ms).fadeIn(duration: 400.ms),
        SizedBox(height: screenHeight * 0.035), // Responsive spacing
        _buildDosageSelector(screenWidth, screenHeight),
      ],
    );
  }

  Widget _buildDosageSelector(double screenWidth, double screenHeight) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Dosis',
            style: TextStyle(
              fontSize: _responsiveFontSize(context, 20), // Adjusted base size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          flex: 3,
          child: InkWell(
            onTap: _showDosagePickerSheet,
            child: Container(
              // Responsive padding
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: screenHeight * 0.014),
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
                  Flexible( // Added flexible for dosage text
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Important for Flexible
                      children: [
                        Icon(
                          Icons.medication_outlined, // Consider dynamic icon based on dosage type later
                          color: Colors.teal.shade700,
                          // Responsive icon size
                          size: screenWidth * 0.055,
                        ),
                        SizedBox(width: screenWidth * 0.02), // Responsive spacing
                        Flexible( // Ensure text doesn't overflow
                          child: Text(
                            _selectedDosage,
                            style: TextStyle(
                              fontSize: _responsiveFontSize(context, 17), // Adjusted base size
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey, size: screenWidth * 0.06),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate(delay: 800.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildSubmitButton(double screenWidth, double screenHeight) {
    return Center(
      child: RoundedButton(
        text: 'Selanjutnya',
        onPressed: _proceed,
        color: AppColors.textHighlight, // Make sure AppColors is defined
        textColor: Colors.black,
        // Responsive size
        width: screenWidth * 0.8,
        height: screenHeight * 0.065,
        borderRadius: (screenHeight * 0.065) / 2, // Maintain circular ends
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedTime = _selectedTime; // This is the state for the modal
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              // Responsive height for modal
              height: screenHeight * 0.75, // Slightly increased for more scroll space
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSheetHeader('Pilih Waktu', screenWidth),
                  Expanded(
                    child: Padding(
                      // Responsive padding
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTimePicker(
                              tempSelectedTime, // Pass the modal's current time state
                              (newTime) { // Callback to update modal's time state
                                setModalState(() {
                                  tempSelectedTime = newTime;
                                });
                                // Also update main screen state live, or on confirm
                                setState(() => _selectedTime = newTime);
                              },
                              screenWidth,
                              screenHeight,
                            ),
                            SizedBox(height: screenHeight * 0.03), // Responsive spacing
                            _buildTimePresets(tempSelectedTime, (newTime) {
                              setModalState(() {
                                tempSelectedTime = newTime;
                              });
                               setState(() => _selectedTime = newTime);
                            }, screenWidth, screenHeight),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildConfirmButton(() => Navigator.pop(context), screenWidth, screenHeight),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDosagePickerSheet() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String tempSelectedDosage = _selectedDosage; // State for the modal
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              // Responsive height
              height: screenHeight * 0.6, // Adjusted for dosage options
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildSheetHeader('Pilih Dosis', screenWidth),
                  Expanded(
                    child: Padding(
                      // Responsive padding
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildDosageDisplay(tempSelectedDosage, screenWidth, screenHeight),
                            SizedBox(height: screenHeight * 0.03), // Responsive spacing
                            _buildDosageOptions(
                              tempSelectedDosage,
                              (newDosage) {
                                setModalState(() {
                                  tempSelectedDosage = newDosage;
                                });
                                setState(() => _selectedDosage = newDosage);
                              },
                              screenWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildConfirmButton(() => Navigator.pop(context), screenWidth, screenHeight),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetHeader(String title, double screenWidth) {
    return Container(
      width: double.infinity,
      // Responsive padding
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
      decoration: const BoxDecoration(
        color: Color(0xFF05606B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            // Responsive size
            width: screenWidth * 0.1,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: screenWidth * 0.04), // Responsive spacing
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: _responsiveFontSize(context, 18), // Adjusted base size
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.02), // Responsive spacing
        ],
      ),
    );
  }

  Widget _buildTimePicker(
    String currentSheetTime,
    Function(String newTime) onTimeUpdated, // This updates the modal's temp state
    double screenWidth,
    double screenHeight,
  ) {

    // Controllers need to be managed if `currentSheetTime` changes (e.g. from presets)
    // Using a StatefulWidget or re-creating controllers on build (if performance allows)
    // For simplicity, assume StatefulBuilder handles rebuilds sufficiently.
    // However, for robust scroll position updates when `currentSheetTime` changes from outside (presets),
    // a more involved state management for controllers might be needed or keying the StatefulBuilder/picker.

    // This StatefulBuilder is for the picker's internal hour/minute state to update its own display
    return StatefulBuilder(
      key: ValueKey(currentSheetTime), // Rebuild if currentSheetTime from preset changes
      builder: (context, setPickerState) {
        // Local state for selected hour and minute, re-initialized when key changes
        int displayHour = int.tryParse(currentSheetTime.split('.')[0]) ?? 8;
        int displayMinute = int.tryParse(currentSheetTime.split('.')[1]) ?? 0;

        final hourController = FixedExtentScrollController(initialItem: displayHour);
        final minuteController = FixedExtentScrollController(initialItem: displayMinute);
        
        void updateLocalTimeAndNotify(int newHour, int newMinute) {
          setPickerState(() { // Update picker's internal display state
            displayHour = newHour;
            displayMinute = newMinute;
          });
          final newFormattedTime = '${newHour.toString().padLeft(2, '0')}.${newMinute.toString().padLeft(2, '0')}';
          onTimeUpdated(newFormattedTime); // Notify the modal sheet (and consequently main screen)
        }

        return Column(
          children: [
            Container(
              // Responsive padding and margin
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.05),
              margin: EdgeInsets.only(bottom: screenHeight * 0.03),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF05606B).withOpacity(0.1),
                    const Color(0xFF88C1D0).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF05606B).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  '${displayHour.toString().padLeft(2, '0')}.${displayMinute.toString().padLeft(2, '0')}',
                  key: ValueKey<String>('${displayHour.toString().padLeft(2, '0')}.${displayMinute.toString().padLeft(2, '0')}'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveFontSize(context, 40), // Adjusted base size
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF05606B),
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSafeTimePickerColumn(
                  'Jam',
                  displayHour,
                  (index) {
                    updateLocalTimeAndNotify(index, displayMinute);
                    HapticFeedback.selectionClick();
                  },
                  24,
                  hourController,
                  screenWidth,
                  screenHeight,
                ),
                Padding(
                  // Responsive padding
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, 38), // Adjusted base size
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildSafeTimePickerColumn(
                  'Menit',
                  displayMinute,
                  (index) {
                    updateLocalTimeAndNotify(displayHour, index);
                    HapticFeedback.selectionClick();
                  },
                  60,
                  minuteController,
                  screenWidth,
                  screenHeight,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSafeTimePickerColumn(
    String label,
    int selectedValue,
    Function(int) onChanged,
    int itemCount,
    FixedExtentScrollController controller,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      children: [
        Container(
          // Responsive padding
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
          decoration: BoxDecoration(
            color: const Color(0xFF05606B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _responsiveFontSize(context, 15), // Adjusted base size
              color: const Color(0xFF05606B),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.015), // Responsive spacing
        Container(
          // Responsive size for the picker wheel
          height: screenHeight * 0.22, // Adjust as needed
          width: screenWidth * 0.22,   // Adjust as needed
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            // Responsive item extent
            itemExtent: screenHeight * 0.045, // e.g., 40 for 890 height
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.5,
            overAndUnderCenterOpacity: 0.5,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final isSelected = selectedValue == index;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF05606B).withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: _responsiveFontSize(context, isSelected ? 20 : 17), // Adjusted base sizes
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF05606B) : Colors.black87,
                    ),
                    child: Text(index.toString().padLeft(2, '0')),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePresets(
    String currentSheetTime, // This is tempSelectedTime from modal
    Function(String) onPresetSelected, // Callback to update tempSelectedTime
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: _responsiveFontSize(context, 19), color: Colors.teal.shade700),
            SizedBox(width: screenWidth * 0.02), // Responsive spacing
            Text(
              'Waktu yang disarankan',
              style: TextStyle(
                fontSize: _responsiveFontSize(context, 16), // Adjusted base size
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02), // Responsive spacing
        Wrap(
          // Responsive spacing
          spacing: screenWidth * 0.03,
          runSpacing: screenHeight * 0.015,
          children: _timePresets.map((preset) {
            final isSelected = currentSheetTime == preset['time'];
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onPresetSelected(preset['time'] as String);
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                // Responsive padding
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.014, horizontal: screenWidth * 0.045),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF05606B) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF05606B) : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF05606B).withOpacity(0.3),
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
                      preset['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: _responsiveFontSize(context, 17), // Adjusted base size
                    ),
                    SizedBox(width: screenWidth * 0.02), // Responsive spacing
                    Text(
                      '${preset['time']} (${preset['label']})',
                      style: TextStyle(
                        fontSize: _responsiveFontSize(context, 14), // Adjusted base size
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOutQuad,
                );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDosageDisplay(String dosage, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      // Responsive padding and margin
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.05),
      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        dosage,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _responsiveFontSize(context, 28), // Adjusted base size
          fontWeight: FontWeight.bold,
          color: const Color(0xFF05606B),
        ),
      ),
    );
  }

  Widget _buildDosageOptions(
    String currentSelectedDosage, // From modal's state
    Function(String) onDosageSelected, // Callback to update modal's state
    double screenWidth,
  ) {
    return Wrap(
      // Responsive spacing
      spacing: screenWidth * 0.025,
      runSpacing: screenWidth * 0.04,
      alignment: WrapAlignment.center,
      children: _dosageOptions.map((option) {
        final isSelected = currentSelectedDosage == option['value'];
        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onDosageSelected(option['value'] as String);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // Responsive width for dosage option cards
            width: screenWidth * 0.42, // Keeps two items per row generally
            // Responsive padding
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04, horizontal: screenWidth * 0.03),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF05606B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF05606B) : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: isSelected
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
                      option['icon'] as IconData,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: _responsiveFontSize(context, 19), // Adjusted base size
                    ),
                    SizedBox(width: screenWidth * 0.02), // Responsive spacing
                    Flexible( // To prevent overflow with long dosage value
                      child: Text(
                        option['value'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: _responsiveFontSize(context, 15), // Adjusted base size
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.01), // Responsive spacing
                Text(
                  option['description'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveFontSize(context, 11), // Adjusted base size
                    color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConfirmButton(VoidCallback onPressed, double screenWidth, double screenHeight) {
    return Padding(
      // Responsive padding
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: RoundedButton(
        text: 'Konfirmasi',
        onPressed: onPressed,
        color: AppColors.textHighlight, // Ensure AppColors is defined
        textColor: Colors.black,
        width: double.infinity, // Takes full width of padding
        // Responsive height
        height: screenHeight * 0.06,
        borderRadius: (screenHeight * 0.06) / 2, // Maintain circular ends
      ),
    );
  }
}
