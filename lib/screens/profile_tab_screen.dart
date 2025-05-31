import 'package:flutter/material.dart';
import 'package:lifecareplus/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import '/models/user_profile.dart';
import '/utils/colors.dart';
import 'profile_screen.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  bool _isLoading = true;
  bool _showContent = false;
  Map<String, dynamic> _userData = {};
  String? _loadingError;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserDataWithRetry();

    // Animation delay for content fade-in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  Future<void> _loadUserDataWithRetry() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      if (kDebugMode) {
        print('[ProfileTabScreen] Fetching user profile...');
      }

      final UserProfile? userProfile = (await _authService
          .getCurrentUserProfile()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Gagal memuat data profil (timeout).');
            },
          )) as UserProfile?;

      if (!mounted) return;

      if (userProfile != null) {
        if (kDebugMode) {
          print(
            '[ProfileTabScreen] User profile loaded: ${userProfile.fullName}',
          );
        }
        setState(() {
          _userData = {
            'fullName': userProfile.fullName,
            'nickname': userProfile.nickname,
            'email': userProfile.email,
            'phone': userProfile.phone,
            'gender': userProfile.gender,
            'age': userProfile.age?.toString(),
            'height': userProfile.height?.toString(),
            'weight': userProfile.weight?.toString(),
            'profileImageUrl': userProfile.profileImageUrl,
          };
          _isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('[ProfileTabScreen] No user profile data returned.');
        }
        setState(() {
          _userData = {};
          _isLoading = false;
          _loadingError =
              'Tidak dapat memuat data profil. Pastikan Anda telah masuk.';
        });
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('[ProfileTabScreen] Timeout loading user data: $e');
      }
      if (mounted) {
        setState(() {
          _userData = {};
          _isLoading = false;
          _loadingError = e.message ?? 'Waktu pemuatan habis.';
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('[ProfileTabScreen] Error loading user data: $e');
        print('[ProfileTabScreen] Stack trace: $stackTrace');
      }
      if (mounted) {
        setState(() {
          _userData = {};
          _isLoading = false;
          _loadingError = 'Terjadi kesalahan saat memuat profil.';
        });
      }
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
    final BuildContext dialogContext = context;

    try {
      Navigator.of(dialogContext).pop();

      // Show loading overlay
      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _authService.signOut();

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (error) {
      if (kDebugMode) {
        print('[ProfileTabScreen] Error signing out: $error');
      }

      if (mounted) {
        // Try to close the loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal keluar dari aplikasi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) {
      if (kDebugMode) {
        print(
          "[ProfileTabScreen] Returning from edit profile, reloading data.",
        );
      }
      _loadUserDataWithRetry();
    });
  }

  String _formatValue(String key, String? value) {
    if (value == null || value.isEmpty) return 'Tidak ada data';

    switch (key) {
      case 'height':
        return '$value cm';
      case 'weight':
        return '$value kg';
      case 'age':
        return '$value tahun';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF05606B),
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _showSignOutDialog,
            tooltip: 'Keluar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF05606B)),
      );
    }

    if (_loadingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
              const SizedBox(height: 16),
              Text(
                _loadingError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserDataWithRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF05606B),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Main content if no error and not loading
    return AnimatedOpacity(
      opacity: _showContent ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: const Color(0xFF05606B),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _userData['profileImageUrl'] != null &&
                          _userData['profileImageUrl']!.isNotEmpty
                      ? CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(
                          _userData['profileImageUrl']!,
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms)
                      : CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Text(
                          _userData['nickname']?[0].toUpperCase() ??
                              (_userData['fullName']?[0].toUpperCase() ?? '?'),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05606B),
                          ),
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    _userData['fullName'] ?? 'Nama Pengguna',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    _userData['email'] ?? 'Email tidak tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Tinggi',
                                _formatValue('height', _userData['height']),
                              ),
                              _buildStatDivider(),
                              _buildStatItem(
                                'Berat',
                                _formatValue('weight', _userData['weight']),
                              ),
                              _buildStatDivider(),
                              _buildStatItem(
                                'Usia',
                                _formatValue('age', _userData['age']),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                  ),
                ],
              ),
            ),

            // Profile information
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pribadi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            icon: Icons.person_outline,
                            title: 'Nama Lengkap',
                            value: _userData['fullName'] ?? '',
                            delay: 600,
                          ),
                          _buildProfileItem(
                            icon: Icons.person_pin_outlined,
                            title: 'Nama Panggilan',
                            value: _userData['nickname'] ?? '',
                            delay: 700,
                          ),
                          _buildProfileItem(
                            icon: Icons.phone_outlined,
                            title: 'Nomor Telepon',
                            value: _userData['phone'] ?? '',
                            delay: 800,
                          ),
                          _buildProfileItem(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: _userData['email'] ?? '',
                            delay: 900,
                          ),
                          _buildProfileItem(
                            icon: Icons.wc_outlined,
                            title: 'Jenis Kelamin',
                            value: _userData['gender'] ?? '',
                            delay: 1000,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF05606B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate(delay: 1100.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    required int delay,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value.isEmpty ? 'Tidak ada data' : value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms);
  }
}
