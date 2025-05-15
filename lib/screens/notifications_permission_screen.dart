import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/colors.dart';
import '../../widgets/rounded_button.dart';
import 'home_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    HapticFeedback.mediumImpact();

    // Request notification permission using the permission_handler package
    await Permission.notification.request();

    // Navigate to home screen after permission request is complete
    // regardless of whether permission was granted or not
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05606B), // Teal at top
              Color(0xFF9CFFDE), // Light mint green at bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Alarm clock icon
                Icon(
                      Icons.access_alarm,
                      size: 80,
                      color: Colors.black.withOpacity(0.8),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 40),

                // Title text
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Pastikan Anda menerima pengingat Anda!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Subtitle text
                Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Nyalakan notifikasi agar kami dapat mengingatkan Anda di waktu yang tepat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 600.ms, curve: Curves.easeOut),

                const Spacer(flex: 2),

                // Allow notification button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: RoundedButton(
                        text: 'Izinkan Notifikasi',
                        onPressed: _requestNotificationPermission,
                        color:
                            AppColors
                                .textHighlight, // Changed to match other screens
                        textColor:
                            Colors.black, // Changed to match other screens
                        width: 300, // Fixed width like other screens
                        height: 50, // Standard height used in other screens
                        borderRadius:
                            25, // Standard borderRadius used elsewhere
                        elevation:
                            3, // Standard elevation for shadow consistency
                      )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutQuad,
                      ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
