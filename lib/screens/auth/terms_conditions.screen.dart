import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_button.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _acceptTerms() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context, true);
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
              // Logo and header area
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  children: [
                    // Logo image
                    Image.asset('assets/tc_logo.png', width: 120, height: 120)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 24),

                    // Main title
                    const Text(
                          'Kenyamanan Anda yang utama',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Privacy section
                      _buildSectionTitle(
                        'Menjamin Privasi Anda',
                      ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 12),

                      _buildSectionContent(
                        'Untuk memberikan fungsionalitas penuh dari aplikasi kami, kami memerlukan persetujuan Anda untuk memproses informasi pribadi dan kesehatan yang Anda masukkan secara bertanggung jawab.',
                      ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),

                      // Analytics section
                      _buildSectionTitle(
                        'Meningkatkan aplikasi untuk Anda',
                      ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 12),

                      _buildSectionContent(
                        'Kami menggunakan alat analitik untuk meningkatkan aplikasi dan mempromosikannya kepada pengguna lain berdasarkan penggunaan Anda, seperti yang diuraikan dalam Kebijakan Privasi kami.',
                      ).animate(delay: 800.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),

                      // Withdrawal section
                      _buildSectionContent(
                        'Saya dapat menarik izin yang saya berikan kapan saja di pengaturan aplikasi LifeCare+',
                      ).animate(delay: 900.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),

              // Accept button
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 40,
                  top: 16,
                ),
                child: RoundedButton(
                      text: 'Terima Semua',
                      onPressed: _acceptTerms,
                      color:
                          AppColors
                              .textHighlight, // Using the standard highlight color
                      textColor:
                          Colors
                              .black, // Changed to black for consistency with other screens
                      width: 300, // Using fixed width like other screens
                      height: 50, // Standard height used in other screens
                      borderRadius: 25, // Standard borderRadius used elsewhere
                      elevation: 3, // Standard elevation for shadow consistency
                    )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .slideY(
                      // Added slide animation for consistency
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSectionContent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
    );
  }
}
