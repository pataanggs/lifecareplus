import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AgeInputScreen extends StatefulWidget {
  final String selectedGender;

  const AgeInputScreen({
    super.key,
    required this.selectedGender,
  });

  @override
  State<AgeInputScreen> createState() => _AgeInputScreenState();
}

class _AgeInputScreenState extends State<AgeInputScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  
  int selectedAge = 28;
  final int minAge = 18;
  final int maxAge = 100;
  
  @override
  void initState() {
    super.initState();
    // Adjust initial age based on gender if needed
    if (widget.selectedGender == 'Laki-Laki') {
      selectedAge = 28;
    } else {
      selectedAge = 25;
    }
    
    // Scroll to the selected age with a slight delay to ensure the list is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedAge();
    });
  }
  
  void _scrollToSelectedAge() {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: selectedAge - minAge,
        duration: const Duration(milliseconds: 300),
        alignment: 0.5, // Center alignment
      );
    }
  }

  void _onNext() {
    // TODO: Navigasi ke input tinggi badan atau halaman berikutnya
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Gender: ${widget.selectedGender}, Umur dipilih: $selectedAge')),
    );
  }
  
  void _updateAge(int age) {
    if (age != selectedAge && age >= minAge && age <= maxAge) {
      setState(() {
        selectedAge = age;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get highlight color based on gender
// Yellow-green for female
    
    return Scaffold(
      backgroundColor: const Color(0xFF05606B), // Exact teal from the image
      body: SafeArea(
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
                    onTap: () => Navigator.pop(context),
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
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
                  ),
                ],
              ),
            ),
            
            // Age display and picker area - takes remaining space
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large selected age
                  Text(
                    selectedAge.toString(),
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Triangle indicator pointing DOWN
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFD6E56C),
                    size: 48,
                  ),
                  const SizedBox(height: 4),
                  
                  // Horizontal age picker
                  Container(
                    height: 80,
                    color: const Color(0xAABEE5AC), // Light green with slight transparency
                    child: ScrollablePositionedList.builder(
                      itemCount: maxAge - minAge + 1,
                      itemScrollController: itemScrollController,
                      scrollOffsetController: scrollOffsetController,
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
                              border: isSelected
                                  ? const Border(
                                      left: BorderSide(color: Colors.white, width: 1),
                                      right: BorderSide(color: Colors.white, width: 1),
                                    )
                                  : null,
                              color: isSelected
                                  ? const Color(0xAABEE5AC)
                                  : const Color(0xAABEE5AC),
                            ),
                            child: Center(
                              child: Text(
                                age.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 38 : 30,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Next button
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: SizedBox(
                width: 300,
                height: 50,
                child: OutlinedButton(
                  onPressed: _onNext,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}