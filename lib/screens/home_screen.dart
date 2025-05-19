import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'medication_reminder_screen.dart';
import '/cubits/home/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeCubit? _homeCubit;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showContent = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      // Check if user is still logged in
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print("No user found in HomeScreen, redirecting to login");
        }
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      }

      // Initialize HomeCubit
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _homeCubit = HomeCubit(prefs);
          _homeCubit?.initProceed();
          _isInitialized = true;
        });
      }

      // Show content with animation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _showContent = true);
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing HomeScreen: $e");
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _homeCubit?.close();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi,';
    } else if (hour < 17) {
      return 'Selamat Siang,';
    } else if (hour < 20) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  void _onFeatureButtonTap(String feature) {
    HapticFeedback.mediumImpact();

    if (feature == 'Medications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicationReminderScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to $feature')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_homeCubit == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: _homeCubit!,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F7),
            appBar: AppBar(
              backgroundColor: const Color(0xFF05606B),
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color(0xFF05606B),
                statusBarIconBrightness: Brightness.light,
              ),
              title: const Text(
                'LifeCare+',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => _onFeatureButtonTap('Notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () => _onFeatureButtonTap('Settings'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: state is HomeStateLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state is HomeStateLoaded
                        ? SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome section with user info
                                Container(
                                  width: double.infinity,
                                  color: const Color(0xFF05606B),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getGreeting(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.data.displayName ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Health stats summary card
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildStatItem(
                                              'Berat',
                                              '${state.data.weight ?? 0} kg',
                                            ),
                                            _buildStatDivider(),
                                            _buildStatItem(
                                              'Tinggi',
                                              '${state.data.height ?? 0} cm',
                                            ),
                                            _buildStatDivider(),
                                            _buildStatItem(
                                              'BMI',
                                              state.data.bmi?.toStringAsFixed(1) ?? '0.0',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate(delay: 200.ms).fadeIn(
                                      duration: 600.ms,
                                      curve: Curves.easeOut,
                                    ),

                                // Feature buttons grid
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'Fitur LifeCare+',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // First row of feature buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildFeatureButton(
                                            icon: Icons.medical_information,
                                            label: 'Riwayat Medis',
                                            color: Colors.blue.shade100,
                                            iconColor: Colors.blue.shade800,
                                            onTap: () => _onFeatureButtonTap('Medical History'),
                                            delay: 300,
                                          ),
                                          _buildFeatureButton(
                                            icon: Icons.calendar_month,
                                            label: 'Jadwal Konsultasi',
                                            color: Colors.green.shade100,
                                            iconColor: Colors.green.shade800,
                                            onTap: () => _onFeatureButtonTap('Consultations'),
                                            delay: 400,
                                          ),
                                          _buildFeatureButton(
                                            icon: Icons.medication,
                                            label: 'Pengingat Obat',
                                            color: Colors.orange.shade100,
                                            iconColor: Colors.orange.shade800,
                                            onTap: () => _onFeatureButtonTap('Medications'),
                                            delay: 500,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      // Second row of feature buttons
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildFeatureButton(
                                            icon: Icons.monitor_heart,
                                            label: 'Pantau Vital',
                                            color: Colors.red.shade100,
                                            iconColor: Colors.red.shade800,
                                            onTap: () => _onFeatureButtonTap('Vital Signs'),
                                            delay: 600,
                                          ),
                                          _buildFeatureButton(
                                            icon: Icons.local_hospital,
                                            label: 'Dokter Terdekat',
                                            color: Colors.purple.shade100,
                                            iconColor: Colors.purple.shade800,
                                            onTap: () => _onFeatureButtonTap('Nearby Doctors'),
                                            delay: 700,
                                          ),
                                          _buildFeatureButton(
                                            icon: Icons.chat_bubble_outline,
                                            label: 'Konsultasi',
                                            color: Colors.teal.shade100,
                                            iconColor: Colors.teal.shade800,
                                            onTap: () => _onFeatureButtonTap('Chat'),
                                            delay: 800,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Articles section with icon placeholders
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          'Artikel Kesehatan',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Using icons instead of images
                                      _buildArticleCardWithIcon(
                                        title: 'Tips Menjaga Kesehatan Jantung',
                                        icon: Icons.favorite,
                                        iconBackground: Colors.red.shade100,
                                        iconColor: Colors.red.shade800,
                                        category: 'Kesehatan Jantung',
                                        delay: 900,
                                        size: size,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildArticleCardWithIcon(
                                        title: 'Makanan untuk Meningkatkan Imunitas',
                                        icon: Icons.restaurant,
                                        iconBackground: Colors.green.shade100,
                                        iconColor: Colors.green.shade800,
                                        category: 'Nutrisi',
                                        delay: 1000,
                                        size: size,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Text('Something went wrong'),
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF05606B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    required int delay,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildArticleCardWithIcon({
    required String title,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String category,
    required int delay,
    required Size size,
  }) {
    return InkWell(
      onTap: () => _onFeatureButtonTap('Article: $title'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size.width,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 40),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF05606B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF05606B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '5 menit membaca',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms, curve: Curves.easeOut);
  }
}
