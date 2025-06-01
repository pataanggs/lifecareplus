import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '/screens/notifications_permission_screen.dart';
import '/widgets/rounded_button.dart';
import '/services/auth_service.dart';
import '/utils/show_snackbar.dart';
import '/utils/colors.dart';

class ProfileDataScreen extends StatefulWidget {
  final String selectedGender;
  final int selectedAge;
  final int selectedHeight;
  final int selectedWeight;

  const ProfileDataScreen({
    super.key,
    required this.selectedGender,
    required this.selectedAge,
    required this.selectedHeight,
    required this.selectedWeight,
  });

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen>
    with SingleTickerProviderStateMixin {
  final fullNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  File? _profileImage;
  bool _showContent = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _showContent = true);
        _animationController.forward();
      }
    });

    // Pre-fill email and phone if available
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_authService.currentUser == null) {
      // User not authenticated, redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (_authService.currentUser != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        emailController.text = _authService.currentUser!.email ?? '';

        // Load saved profile data
        fullNameController.text = prefs.getString('user_full_name') ?? '';
        nicknameController.text = prefs.getString('user_nickname') ?? '';
        phoneController.text = prefs.getString('user_phone') ?? '';
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user data: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        setState(() {
          _profileImage = File(pickedImage.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _onNext() async {
    // Validate fields
    if (fullNameController.text.isEmpty ||
        nicknameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      showSnackBar(context, 'Semua data harus diisi');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save all user data to SharedPreferences
      await prefs.setString('user_full_name', fullNameController.text);
      await prefs.setString('user_nickname', nicknameController.text);
      await prefs.setString('user_email', emailController.text);
      await prefs.setString('user_phone', phoneController.text);

      // Save profile image path if selected
      if (_profileImage != null) {
        await prefs.setString('user_profile_image', _profileImage!.path);
      }

      // Mark onboarding as complete
      await prefs.setBool('onboarding_complete', true);

      // Call the new method to mark this user's onboarding as complete
      await _completeOnboarding();

      // Navigate to notification permission screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationPermissionScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Terjadi kesalahan saat menyimpan data');
      }
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        // Mark this user as having completed onboarding
        await prefs.setBool('${user.uid}_onboarding_completed', true);

        // Save all the user profile data to your database
        // You can add code here to save profile data to Firebase or other database

        // Note: We're not navigating here since we want to show the notification permission screen first
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error completing onboarding: $e");
      }
      // Don't show error message here, let the parent function handle it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                          child: const Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFFD6E56C),
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Color(0xFFD6E56C),
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
                    // Title
                    const Center(
                          child: Text(
                            'Isi Data Diri Anda',
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
              // Main content - scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Profile picture section
                      Center(
                            child: Stack(
                              children: [
                                // Profile image container
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    image:
                                        _profileImage != null
                                            ? DecorationImage(
                                              image: FileImage(_profileImage!),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                  child:
                                      _profileImage == null
                                          ? const Center(
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 60,
                                            ),
                                          )
                                          : null,
                                ),
                                // Edit button
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD6E56C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      const SizedBox(height: 40),
                      // Form fields
                      _buildInputField(
                        label: 'Nama Lengkap',
                        controller: fullNameController,
                        hint: 'Masukkan nama lengkap anda',
                        delay: 600,
                      ),
                      _buildInputField(
                        label: 'Nama Panggilan',
                        controller: nicknameController,
                        hint: 'Masukkan nama panggilan anda',
                        delay: 700,
                      ),
                      _buildInputField(
                        label: 'Email',
                        controller: emailController,
                        hint: 'contoh@email.com',
                        keyboardType: TextInputType.emailAddress,
                        delay: 800,
                      ),
                      _buildInputField(
                        label: 'Nomor Handphone',
                        controller: phoneController,
                        hint: '+628 1234 5678 90',
                        keyboardType: TextInputType.phone,
                        delay: 900,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Next button
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
                child: RoundedButton(
                      text: 'Selanjutnya',
                      onPressed: _onNext,
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: double.infinity,
                      height: 50,
                      elevation: 3,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required int delay,
  }) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
