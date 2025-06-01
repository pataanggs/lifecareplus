// ignore_for_file: unnecessary_null_comparison, duplicate_ignore, use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifecareplus/cubits/profile/profile_cubit.dart';
import 'package:lifecareplus/cubits/profile/profile_state.dart';
import 'package:lifecareplus/models/user_profile.dart';
import 'package:lifecareplus/services/auth_service.dart';
import 'package:lifecareplus/utils/colors.dart';
import 'package:lifecareplus/widgets/shimmer_loading.dart';

import 'profile_screen.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin {
  final AuthService _authService = AuthService();
  bool _showContent = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Animation delay for content fade-in
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showContent = true);
    });

    // Load profile data when the screen is created
    Future.microtask(() {
      if (context.mounted) {
        context.read<ProfileCubit>().loadUserProfile();
      }
    });
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    ).then((_) {
      developer.log("Returning from edit profile, reloading data");
      context.read<ProfileCubit>().loadUserProfile();
    });
  }

  Future<void> _onRefresh() async {
    return context.read<ProfileCubit>().loadUserProfile();
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
      Navigator.of(context).pop(); // Close dialog

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _authService.signOut();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (error) {
      developer.log('Error signing out: $error');

      if (mounted) {
        Navigator.of(context).pop(); // Try to close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal keluar dari aplikasi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      body: AnimatedOpacity(
        opacity: _showContent ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF05606B),
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileStateInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF05606B)),
                );
              } else if (state is ProfileStateLoading) {
                return const _ProfileShimmerLoading();
              } else if (state is ProfileStateLoaded) {
                return _ProfileContent(
                  profile: state.profile,
                  onEditProfile: _navigateToEditProfile,
                );
              } else if (state is ProfileStateError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (state).message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            () =>
                                context.read<ProfileCubit>().loadUserProfile(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              // Default fallback
              return const Center(
                child: Text(
                  'Unknown state',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileShimmerLoading extends StatelessWidget {
  const _ProfileShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF05606B),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 16),
                ShimmerLoading(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 16),
                ShimmerLoading(
                  child: Container(
                    height: 24,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  child: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ShimmerLoading(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  child: Container(
                    height: 20,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ShimmerLoading(
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ShimmerLoading(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditProfile;

  const _ProfileContent({required this.profile, required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    // Calculate profile completion percentage
    int filledFields = 0;
    final totalFields =
        8; // fullName, nickname, email, phone, gender, age, height, weight

    if ((profile.fullName).isNotEmpty) filledFields++;
    if ((profile.nickname).isNotEmpty) filledFields++;
    if ((profile.email).isNotEmpty) filledFields++;
    if ((profile.phone).isNotEmpty) filledFields++;
    if ((profile.gender).isNotEmpty) filledFields++;
    filledFields++;
    filledFields++;
    filledFields++;

    final completionPercentage = (filledFields / totalFields * 100).round();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Profile header with avatar, name and email
          Container(
            width: double.infinity,
            color: const Color(0xFF05606B),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _ProfileAvatar(
                  profile: profile,
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Changed from withOpacity
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
                // Profile stats card with health metrics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProfileStatsCard(profile: profile)
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
              ],
            ),
          ),

          // Profile information section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile completion indicator
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10, // Changed from withOpacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kelengkapan Profil',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70, // Changed from withOpacity
                            ),
                          ),
                          Text(
                            '$completionPercentage%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  completionPercentage < 70
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPercentage / 100,
                          backgroundColor: Colors.grey.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionPercentage < 70
                                ? Colors.orange
                                : Colors.green,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      if (completionPercentage < 100) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Lengkapi profil Anda untuk pengalaman yang lebih baik',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70, // Changed from withOpacity
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

                const Text(
                  'Informasi Pribadi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // Profile info card
                _ProfileInfoCard(
                  profile: profile,
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 24),

                // Edit profile button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onEditProfile,
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
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final UserProfile profile;

  const _ProfileAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return (profile.profileImageUrl != null &&
            (profile.profileImageUrl ?? '').isNotEmpty)
        ? Hero(
          tag: 'profile-avatar',
          child: CachedNetworkImage(
            imageUrl: profile.profileImageUrl!,
            imageBuilder:
                (context, imageProvider) =>
                    CircleAvatar(radius: 45, backgroundImage: imageProvider),
            placeholder:
                (context, url) => CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey.shade300,
                  child: const CircularProgressIndicator(),
                ),
            errorWidget: (context, url, error) => _buildInitialsAvatar(),
          ),
        )
        : _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Hero(
      tag: 'profile-avatar',
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          (profile.nickname).isNotEmpty
              ? (profile.nickname)[0].toUpperCase()
              : ((profile.fullName).isNotEmpty
                  ? (profile.fullName)[0].toUpperCase()
                  : '?'),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF05606B),
          ),
        ),
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  final UserProfile profile;

  const _ProfileStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // ignore: unnecessary_null_comparison
            profile.height != null ? '${profile.height} cm' : 'Tidak ada',
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Berat',
            // ignore: unnecessary_null_comparison
            profile.weight != null ? '${profile.weight} kg' : 'Tidak ada',
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Usia',
            profile.age != null ? '${profile.age} tahun' : 'Tidak ada',
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
}

class _ProfileInfoCard extends StatelessWidget {
  final UserProfile profile;

  const _ProfileInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10, // Changed from withOpacity
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
              value: profile.fullName,
              delay: 600,
            ),
            _buildProfileItem(
              icon: Icons.person_pin_outlined,
              title: 'Nama Panggilan',
              value: profile.nickname,
              delay: 700,
            ),
            _buildProfileItem(
              icon: Icons.phone_outlined,
              title: 'Nomor Telepon',
              value: profile.phone,
              delay: 800,
            ),
            _buildProfileItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: profile.email,
              delay: 900,
            ),
            _buildProfileItem(
              icon: Icons.wc_outlined,
              title: 'Jenis Kelamin',
              value: profile.gender,
              delay: 1000,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
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
                  color: Colors.white12, // Changed from withOpacity
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70, // Changed from withOpacity
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
          Divider(color: Colors.white10, height: 1), // Changed from withOpacity
      ],
    ).animate(delay: delay.ms).fadeIn(duration: 400.ms);
  }
}
