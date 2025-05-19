import 'package:flutter/material.dart';
import 'package:lifecareplus/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '/utils/colors.dart';
import 'profile_screen.dart'; // Import your existing profile screen for editing

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  bool _isLoading = true;
  bool _showContent = false;
  Map<String, dynamic> _userData = {};
  final AuthService _authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Animation delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }
  
  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUserProfile();
      
      if (user != null) {
        setState(() {
          _userData = {
            'fullName': user.fullName,
            'nickname': user.nickname,
            'email': user.email,
            'phone': user.phone,
            'gender': user.gender,
            'age': user.age.toString(),
            'height': user.height.toString(),
            'weight': user.weight.toString(),
            'profileImageUrl': user.profileImageUrl,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi LifeCare+?'),
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

      // Sign out using your auth service
      await _authService.signOut();

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
  
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) {
      // Reload data when returning from edit profile
      _loadUserData();
    });
  }
  
  String _formatValue(String key, String value) {
    if (value.isEmpty) return 'Tidak ada data';
    
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedOpacity(
              opacity: _showContent ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // Profile header with avatar and stats
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF05606B),
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Avatar
                          _userData['profileImageUrl'] != null && _userData['profileImageUrl']!.isNotEmpty
                              ? CircleAvatar(
                                  radius: 45,
                                  backgroundImage: NetworkImage(_userData['profileImageUrl']!),
                                )
                                .animate(delay: 100.ms)
                                .fadeIn(duration: 400.ms)
                              : CircleAvatar(
                                  radius: 45,
                                  backgroundColor: Colors.white.withOpacity(0.9),
                                  child: Text(
                                    _userData['nickname']?[0].toUpperCase() ?? '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF05606B),
                                    ),
                                  ),
                                )
                                .animate(delay: 100.ms)
                                .fadeIn(duration: 400.ms),
                          const SizedBox(height: 16),
                          // Name
                          Text(
                                _userData['fullName'] ?? 'Tidak ada data',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          // Email
                          Text(
                                _userData['email'] ?? 'Tidak ada data',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              )
                              .animate(delay: 300.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 24),
                          
                          // Health stats
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
                                      _buildStatItem('Tinggi', _formatValue('height', _userData['height'] ?? '')),
                                      _buildStatDivider(),
                                      _buildStatItem('Berat', _formatValue('weight', _userData['weight'] ?? '')),
                                      _buildStatDivider(),
                                      _buildStatItem('Usia', _formatValue('age', _userData['age'] ?? '')),
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
                              )
                              .animate(delay: 500.ms)
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 16),
                          
                          Card(
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              )
                              .animate(delay: 500.ms)
                              .fadeIn(duration: 600.ms),
                          
                          const SizedBox(height: 24),
                          
                          // Edit button
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
                              )
                              .animate(delay: 1100.ms)
                              .fadeIn(duration: 400.ms),
                        ],
                      ),
                    ),
                  ],
                ),
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
                      child: Icon(
                        icon,
                        size: 24,
                        color: Colors.white,
                      ),
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
              if (showDivider) Divider(color: Colors.white.withOpacity(0.1), height: 1),
            ],
          )
          .animate(delay: delay.ms)
          .fadeIn(duration: 400.ms);
  }
}