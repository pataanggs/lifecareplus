import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifecareplus/utils/colors.dart';
import 'package:lifecareplus/widgets/rounded_button.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'height_input_screen.dart';

class WeightInputScreen extends StatefulWidget {
  final String selectedGender;
  final int selectedAge;
  final int selectedHeight;

  const WeightInputScreen({
    super.key,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
  });

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen>
    with SingleTickerProviderStateMixin {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  late AnimationController _animationController;

  int selectedWeight = 75;
  final int minWeight = 30;
  final int maxWeight = 200;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedWeight();

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

  void _scrollToSelectedWeight() {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: selectedWeight - minWeight,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5,
      );
    }
  }

  void _onNext() {
    HapticFeedback.mediumImpact();
    print(
      '[LOG] Gender: \x1b[1m${widget.selectedGender}\x1b[0m, Age: ${widget.selectedAge}, Height: ${widget.selectedHeight}, Weight: $selectedWeight',
    );
    _animationController.reverse().then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => HeightInputScreen(
                selectedGender: widget.selectedGender,
                selectedAge: widget.selectedAge,
                selectedWeight: selectedWeight,
              ),
        ),
      );
    });
  }

  void _updateWeight(int weight) {
    if (weight != selectedWeight &&
        weight >= minWeight &&
        weight <= maxWeight) {
      HapticFeedback.selectionClick();
      setState(() {
        selectedWeight = weight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05606B),
      body: AnimatedOpacity(
        opacity: _showContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFFD6E56C),
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

                    const SizedBox(height: 40),
                    const Center(
                          child: Text(
                            'Berat Badan Anda?',
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

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Animate(
                          key: ValueKey<int>(selectedWeight),
                          effects: [
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  selectedWeight.toString(),
                                  key: ValueKey<int>(selectedWeight),
                                  style: const TextStyle(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Text(
                                  " Kg",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
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

                    Container(
                          height: 80,
                          color: const Color(0xAABEE5AC),
                          child: ScrollablePositionedList.builder(
                            itemCount: maxWeight - minWeight + 1,
                            itemScrollController: itemScrollController,
                            scrollOffsetController: scrollOffsetController,
                            itemPositionsListener: itemPositionsListener,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final weight = index + minWeight;
                              final isSelected = weight == selectedWeight;

                              return GestureDetector(
                                onTap: () {
                                  _updateWeight(weight);
                                  _scrollToSelectedWeight();
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
                                    color: const Color(0xAABEE5AC),
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
                                      child: Text(weight.toString()),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        .animate(delay: 800.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut),
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
                    .animate(delay: 1000.ms)
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
