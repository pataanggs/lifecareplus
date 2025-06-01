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
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _setSystemUI();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
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
          child: Stack(
            children: [
              _buildBackgroundElements(),
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          if (!_hasScrolled &&
                              notification.metrics.pixels > 0) {
                            setState(() => _hasScrolled = true);
                          }
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPrivacySection(),
                            const SizedBox(height: 32),
                            _buildAnalyticsSection(),
                            const SizedBox(height: 32),
                            _buildWithdrawalSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildAcceptButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Top gradient overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        // Bottom gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 800.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                  ),
              Image.asset('assets/tc_logo.png', width: 120, height: 120)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
                'Kenyamanan Anda yang utama',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Keamanan dan Privasi Anda adalah Prioritas Kami',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.privacy_tip_outlined,
                color: Colors.teal.shade300,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            _buildSectionTitle('Menjamin Privasi Anda'),
          ],
        ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        _buildSectionContent(
          'Untuk memberikan fungsionalitas penuh dari aplikasi kami, kami memerlukan persetujuan Anda untuk memproses informasi pribadi dan kesehatan yang Anda masukkan secara bertanggung jawab.',
        ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: Colors.blue.shade300,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            _buildSectionTitle('Meningkatkan aplikasi untuk Anda'),
          ],
        ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        _buildSectionContent(
          'Kami menggunakan alat analitik untuk meningkatkan aplikasi dan mempromosikannya kepada pengguna lain berdasarkan penggunaan Anda, seperti yang diuraikan dalam Kebijakan Privasi kami.',
        ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildWithdrawalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: Colors.purple.shade300,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSectionContent(
              'Saya dapat menarik izin yang saya berikan kapan saja di pengaturan aplikasi LifeCare+',
            ),
          ),
        ],
      ),
    ).animate(delay: 900.ms).fadeIn(duration: 400.ms);
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
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildAcceptButton() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background.withOpacity(0), AppColors.background],
        ),
      ),
      child: RoundedButton(
            text: 'Terima Semua',
            onPressed: _acceptTerms,
            color: AppColors.textHighlight,
            textColor: Colors.black,
            width: 300,
            height: 50,
            borderRadius: 25,
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
    );
  }
}
