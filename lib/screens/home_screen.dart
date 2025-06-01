import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import
import '/services/article_service.dart'; // Add this import
import 'article_webview_screen.dart';

import 'medication_reminder_screen.dart';
import '/cubits/home/home_cubit.dart';
import '/screens/notifications/notifications_screen.dart';
import '/screens/settings/settings_screen.dart';
import '/screens/medical_history/medical_history_screen.dart';
import '/screens/consultations/consultations_screen.dart';
import '/screens/vital_signs/vital_signs_screen.dart';
import '/screens/nearby_doctors/nearby_doctors_screen.dart';
import '/screens/chat/chat_screen.dart';

class Article {
  final String title;
  final String imageUrl;
  final String category;
  final String timeToRead;
  final String url;

  Article({
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.timeToRead,
    required this.url,
  });
}

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
  List<Article> _articles = [];
  bool _isLoadingArticles = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    _loadArticles();
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
        _homeCubit = HomeCubit(prefs);
        _homeCubit?.initProceed();

        setState(() {
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

  Future<void> _loadArticles() async {
    try {
      final serviceArticles = await ArticleService.fetchHealthArticles();
      if (mounted) {
        setState(() {
          // Map the service articles to the local Article type
          _articles =
              serviceArticles
                  .map(
                    (article) => Article(
                      title: article.title,
                      imageUrl: article.imageUrl,
                      category: article.category,
                      timeToRead: article.timeToRead,
                      url: article.url,
                    ),
                  )
                  .toList();
          _isLoadingArticles = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading articles: $e");
      }
      if (mounted) {
        setState(() {
          // Map fallback articles to local Article type
          _articles =
              ArticleService.getFallbackArticles()
                  .map(
                    (article) => Article(
                      title: article.title,
                      imageUrl: article.imageUrl,
                      category: article.category,
                      timeToRead: article.timeToRead,
                      url: article.url,
                    ),
                  )
                  .toList();
          _isLoadingArticles = false;
        });
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

    switch (feature) {
      case 'Medical History':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicalHistoryScreen()),
        );
        break;
      case 'Consultations':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
        );
        break;
      case 'Vital Signs':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VitalSignsScreen()),
        );
        break;
      case 'Nearby Doctors':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NearbyDoctorsScreen()),
        );
        break;
      case 'Chat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 'Medications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicationReminderScreen()),
        );
        break;
      case 'Notifications':
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const NotificationsScreen(),
        );
        break;
      case 'Settings':
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const SettingsScreen(),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Navigating to $feature')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_homeCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => _onFeatureButtonTap('Notifications'),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => _onFeatureButtonTap('Settings'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _showSignOutDialog,
                  tooltip: 'Sign Out',
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child:
                    state is HomeStateLoading
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
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
                                                state.data.bmi?.toStringAsFixed(
                                                      1,
                                                    ) ??
                                                    '0.0',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(delay: 200.ms)
                                  .fadeIn(
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
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildFeatureButton(
                                          icon: Icons.medical_information,
                                          label: 'Riwayat Medis',
                                          color: Colors.blue.shade100,
                                          iconColor: Colors.blue.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap(
                                                'Medical History',
                                              ),
                                          delay: 300,
                                        ),
                                        _buildFeatureButton(
                                          icon: Icons.calendar_month,
                                          label: 'Jadwal Konsultasi',
                                          color: Colors.green.shade100,
                                          iconColor: Colors.green.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap(
                                                'Consultations',
                                              ),
                                          delay: 400,
                                        ),
                                        _buildFeatureButton(
                                          icon: Icons.medication,
                                          label: 'Pengingat Obat',
                                          color: Colors.orange.shade100,
                                          iconColor: Colors.orange.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap(
                                                'Medications',
                                              ),
                                          delay: 500,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Second row of feature buttons
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildFeatureButton(
                                          icon: Icons.monitor_heart,
                                          label: 'Pantau Vital',
                                          color: Colors.red.shade100,
                                          iconColor: Colors.red.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap(
                                                'Vital Signs',
                                              ),
                                          delay: 600,
                                        ),
                                        _buildFeatureButton(
                                          icon: Icons.local_hospital,
                                          label: 'Dokter Terdekat',
                                          color: Colors.purple.shade100,
                                          iconColor: Colors.purple.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap(
                                                'Nearby Doctors',
                                              ),
                                          delay: 700,
                                        ),
                                        _buildFeatureButton(
                                          icon: Icons.chat_bubble_outline,
                                          label: 'Konsultasi',
                                          color: Colors.teal.shade100,
                                          iconColor: Colors.teal.shade800,
                                          onTap:
                                              () => _onFeatureButtonTap('Chat'),
                                          delay: 800,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Replace this line:
                              // Articles section with icon placeholders
                              _buildArticlesSection(size),
                            ],
                          ),
                        )
                        : const Center(child: Text('Something went wrong')),
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
        )
        .animate(delay: delay.ms)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildArticlesSection(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header for section title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF05606B), Color(0xFF4FC3F7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Artikel Kesehatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                // Optionally add a "See All" button
                // TextButton(
                //   onPressed: () {},
                //   child: const Text('Lihat Semua', style: TextStyle(color: Colors.white)),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _isLoadingArticles
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: const Color(0xFF4FC3F7),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Memuat artikel...',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF05606B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children:
                    _articles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final article = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: _buildArticleCard(
                              title: article.title,
                              imageUrl: article.imageUrl,
                              category: article.category,
                              timeToRead: article.timeToRead,
                              url: article.url,
                              delay: 900 + (index * 100),
                              size: size,
                            )
                            .animate(delay: (900 + (index * 100)).ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0, duration: 500.ms),
                      );
                    }).toList(),
              ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String imageUrl,
    required String category,
    required String timeToRead,
    required String url,
    required int delay,
    required Size size,
  }) {
    return InkWell(
      onTap: () => _onArticleTap(title, url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size.width,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child:
                  imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  _getCategoryIcon(category),
                                  color: _getCategoryColor(category),
                                  size: 44,
                                ),
                              ),
                        ),
                      )
                      : Container(
                        width: size.width,
                        height: size.height,
                        decoration: BoxDecoration(
                          color: _getCategoryBackground(category),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 44,
                        ),
                      ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withOpacity(0.13),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF05606B),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05606B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 15,
                          color: Color(0xFF4FC3F7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          timeToRead,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
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
    );
  }

  void _onArticleTap(String title, String url) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL artikel tidak tersedia')),
      );
      return;
    }

    if (kDebugMode) {
      print("Opening article: $title with URL: $url");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleWebViewScreen(url: url, title: title),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kesehatan jantung':
        return Icons.favorite;
      case 'nutrisi':
      case 'diet':
      case 'makanan':
        return Icons.restaurant;
      case 'fitness':
      case 'olahraga':
        return Icons.fitness_center;
      case 'covid-19':
      case 'virus':
        return Icons.coronavirus;
      case 'mental':
      case 'psikologi':
        return Icons.psychology;
      case 'hidup sehat':
      case 'pola hidup':
        return Icons.healing;
      default:
        return Icons.health_and_safety;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kesehatan jantung':
        return Colors.red.shade800;
      case 'nutrisi':
      case 'diet':
      case 'makanan':
        return Colors.green.shade800;
      case 'fitness':
      case 'olahraga':
        return Colors.orange.shade800;
      case 'covid-19':
      case 'virus':
        return Colors.purple.shade800;
      case 'mental':
      case 'psikologi':
        return Colors.blue.shade800;
      case 'hidup sehat':
      case 'pola hidup':
        return Colors.teal.shade800;
      default:
        return const Color(0xFF05606B);
    }
  }

  Color _getCategoryBackground(String category) {
    switch (category.toLowerCase()) {
      case 'kesehatan jantung':
        return Colors.red.shade100;
      case 'nutrisi':
      case 'diet':
      case 'makanan':
        return Colors.green.shade100;
      case 'fitness':
      case 'olahraga':
        return Colors.orange.shade100;
      case 'covid-19':
      case 'virus':
        return Colors.purple.shade100;
      case 'mental':
      case 'psikologi':
        return Colors.blue.shade100;
      case 'hidup sehat':
      case 'pola hidup':
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar dari Aplikasi'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi LifeCare+?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: _signOut,
                child: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _signOut() async {
    try {
      // Show loading indicator
      Navigator.of(context).pop(); // Close dialog

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Clear user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      await _auth.signOut();

      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error signing out: $error');
      }

      // Close any open dialogs
      if (mounted) {
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal keluar dari aplikasi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
