import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifecareplus/utils/colors.dart';
import 'package:lifecareplus/widgets/rounded_button.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'weight_input_screen.dart';
import 'package:lifecareplus/utils/onboarding_preferences.dart';

class AgeInputScreen extends StatefulWidget {
  final String selectedGender;

  const AgeInputScreen({super.key, required this.selectedGender});

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}


class _AgeInputScreenState extends State<AgeInputScreen>
    with SingleTickerProviderStateMixin {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  // Animation controller for coordinated animations
  late AnimationController _animationController;

  int selectedAge = 28;
  final int minAge = 18;
  final int maxAge = 100;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Adjust initial age based on gender
    if (widget.selectedGender == 'Laki-Laki') {
      selectedAge = 28;
    } else {
      selectedAge = 25;
    }

    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;

      if (positions.isNotEmpty) {
        final centerItem = positions
            .map((item) => MapEntry(item, (item.itemLeadingEdge - 0.5).abs()))
            .reduce((a, b) => a.value < b.value ? a : b)
            .key;

        final indexInCenter = centerItem.index;
        final ageInCenter = indexInCenter + minAge;

        if (ageInCenter != selectedAge) {
          setState(() => selectedAge = ageInCenter);
        }
      }
    });

    // Scroll to the selected age with a slight delay to ensure the list is built
    WidgetsBinding.instance.addPostFrameCallback((_) {

      _scrollToSelectedAge();

      // Start animations after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _showContent = true);
          _animationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToSelectedAge() {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: selectedAge - minAge,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5, // tengah layar
      );
    }
  }

  void _onNext() async {
    HapticFeedback.mediumImpact();
    await OnboardingPreferences.saveAge(selectedAge);
    // Animate out before navigating
    _animationController.reverse().then((_) {
      // Navigate to WeightInputScreen and pass gender & age
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeightInputScreen(
            selectedGender: widget.selectedGender,
            selectedAge: selectedAge,
            selectedHeight: 173, // default height, will be set in next screen
          ),
        ),
      );
    });
  }

  void _updateAge(int age) async {
    if (age != selectedAge && age >= minAge && age <= maxAge) {
      HapticFeedback.selectionClick();
      setState(() {
        selectedAge = age;
      });
      await OnboardingPreferences.saveAge(age);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05606B), // Exact teal from the image
      body: AnimatedOpacity(
        opacity: _showContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: SafeArea(
          child: Column(
            children: [
              // Top padding
              const SizedBox(height: 16),

              // Back button and title area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFFD6E56C), // Yellow-green color
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Kembali',
                                style: TextStyle(
                                  color: const Color(0xFFD6E56C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 100.ms)
                        .slideY(
                          begin: -0.2,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutQuad,
                        ),

                    // Title
                    const SizedBox(height: 40),
                    const Center(
                          child: Text(
                            'Berapa Umur Anda?',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad,
                        ),
                  ],
                ),
              ),

              // Age display and picker area - takes remaining space
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large selected age with animation
                    Animate(
                          key: ValueKey<int>(selectedAge),
                          effects: [
                            // Subtle scale animation when value changes
                            ScaleEffect(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                            ),
                          ],
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              '$selectedAge',
                              key: ValueKey<int>(selectedAge),
                              style: const TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1.0, 1.0),
                          duration: 700.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    // Triangle indicator with subtle bounce animation
                    const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFFD6E56C),
                          size: 48,
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .moveY(
                          begin: 0,
                          end: 5,
                          duration: 1.seconds,
                          curve: Curves.easeInOut,
                        )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 300.ms, curve: Curves.easeOut),

                    const SizedBox(height: 4),

                    // Horizontal age picker with fade-in
                    Container(
                          height: 80,
                          color: const Color(
                            0xAABEE5AC,
                          ), // Light green with slight transparency
                          child: ScrollablePositionedList.builder(
                            itemCount: maxAge - minAge + 1,
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final age = index + minAge;
                              final isSelected = age == selectedAge;

                              return GestureDetector(
                                onTap: () {
                                  _updateAge(age);
                                  _scrollToSelectedAge();
                                },
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    border:
                                        isSelected
                                            ? const Border(
                                              left: BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                              right: BorderSide(
                                                color: Colors.white,
                                                width: 1,
                                              ),
                                            )
                                            : null,
                                    color:
                                        isSelected
                                            ? const Color(0xAABEE5AC)
                                            : const Color(0xAABEE5AC),
                                  ),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style: TextStyle(
                                        fontSize: isSelected ? 38 : 30,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      child: Text(age.toString()),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .animate(delay: 900.ms)
                        .fadeIn(duration: 500.ms, curve: Curves.easeOut),
                  ],
                ),
              ),

              // Next button with elegant entrance animation
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                child: RoundedButton(
                      text: 'Selanjutnya',
                      onPressed: _onNext,
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: 300,
                      height: 50,
                      elevation: 3, // Add some nice elevation for depth
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
            ],
          ),
        ),
      ),
    );
  }
}
