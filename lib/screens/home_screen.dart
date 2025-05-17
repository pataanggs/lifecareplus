import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'medication_reminder_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showContent = false;
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  Future<void> _initializeData() async {
    try {
      // Ensure auth service is initialized
      await _authService.ensureInitialized();
      // Then load user data
      await _loadUserData();
    } catch (e) {
      debugPrint('HomeScreen: Error initializing: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('HomeScreen: Loading user data...');

      // Get current user ID from storage first
      final userId = await _storageService.getCurrentUserId();
      debugPrint('HomeScreen: User ID from storage: $userId');

      // Get current user from AuthService
      final currentUser = _authService.currentUser;
      debugPrint(
        'HomeScreen: Current user from auth service: ${currentUser?.uid}',
      );

      // Double check for consistency between storage and auth service
      if (userId != null && currentUser == null) {
        debugPrint(
          'HomeScreen: Inconsistent state - user ID in storage but not in auth service',
        );
        await _authService.signOut(); // Sign out to clear invalid state
        _handleLogout();
        return;
      } else if (userId == null && currentUser != null) {
        debugPrint(
          'HomeScreen: Inconsistent state - user in auth service but not in storage',
        );
        await _storageService.setCurrentUserId(currentUser.uid);
      }

      if (currentUser != null) {
        // Fetch user profile from storage
        final userData = await _authService.getUserProfile(currentUser.uid);
        debugPrint('HomeScreen: User profile fetched: ${userData != null}');

        if (userData != null) {
          // Check if profile is complete
          if (userData.gender.isEmpty ||
              userData.age == 0 ||
              userData.height == 0 ||
              userData.weight == 0) {
            debugPrint(
              'HomeScreen: User profile incomplete, redirecting to onboarding',
            );

            if (mounted && !_isNavigating) {
              _isNavigating = true;
              Navigator.pushReplacementNamed(context, '/onboarding');
              return;
            }
          }

          // Profile is complete, update UI
          if (mounted) {
            setState(() {
              _currentUser = userData;
              _isLoading = false;
            });
          }
        } else {
          // No user profile found despite having auth user
          debugPrint('HomeScreen: No user profile found, redirecting to login');
          _handleLogout();
        }
      } else {
        // No authenticated user
        debugPrint('HomeScreen: No authenticated user, redirecting to login');
        _handleLogout();
      }
    } catch (e) {
      debugPrint('HomeScreen: Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleLogout() {
    if (mounted && !_isNavigating) {
      _isNavigating = true;
      Future.microtask(() async {
        try {
          await _authService.signOut();
        } catch (e) {
          debugPrint('Error during logout: $e');
        }
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
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

  double _calculateBMI() {
    if (_currentUser == null ||
        _currentUser!.height <= 0 ||
        _currentUser!.weight <= 0) {
      return 0;
    }

    // BMI = weight(kg) / height(m)²
    final heightInMeters = _currentUser!.height / 100;
    return _currentUser!.weight / (heightInMeters * heightInMeters);
  }

  void _onNavItemTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFeatureButtonTap(String feature) {
    HapticFeedback.lightImpact();

    // Navigate to appropriate screen based on the feature
    if (feature == 'Medications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MedicationReminderScreen()),
      );
    } else {
      // For other features, just show a snackbar for now
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigating to $feature')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF05606B), // Teal app bar
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
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                                    _currentUser?.fullName ?? 'User',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(
                                          'Berat',
                                          '${_currentUser?.weight ?? 0} kg',
                                        ),
                                        _buildStatDivider(),
                                        _buildStatItem(
                                          'Tinggi',
                                          '${_currentUser?.height ?? 0} cm',
                                        ),
                                        _buildStatDivider(),
                                        _buildStatItem(
                                          'BMI',
                                          _calculateBMI().toStringAsFixed(1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 600.ms, curve: Curves.easeOut),

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
                                        () =>
                                            _onFeatureButtonTap('Medications'),
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
                                        () =>
                                            _onFeatureButtonTap('Vital Signs'),
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
                              ),

                              const SizedBox(height: 16),

                              _buildArticleCardWithIcon(
                                title: 'Makanan untuk Meningkatkan Imunitas',
                                icon: Icons.restaurant,
                                iconBackground: Colors.green.shade100,
                                iconColor: Colors.green.shade800,
                                category: 'Nutrisi',
                                delay: 1000,
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF05606B),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Kesehatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
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

  // New method using icons instead of images
  Widget _buildArticleCardWithIcon({
    required String title,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String category,
    required int delay,
  }) {
    return InkWell(
      onTap: () => _onFeatureButtonTap('Article: $title'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 40),
            ),
            Expanded(
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
                    const SizedBox(height: 8),
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
