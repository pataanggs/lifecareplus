import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../profile/profile_screen.dart';
import '../help/help_support_screen.dart';
import '../about/about_screen.dart';
import '../settings/language_screen.dart';
import '../settings/theme_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _navigateToLanguage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageScreen()),
    );
  }

  void _navigateToTheme() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemeScreen()),
    );
  }

  void _navigateToHelpAndSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _toggleBiometric(bool value) {
    HapticFeedback.lightImpact();
    setState(() => _biometricEnabled = value);
    // TODO: Implement biometric authentication
  }

  Future<void> _downloadData() async {
    HapticFeedback.mediumImpact();
    // TODO: Implement data download logic
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mengunduh data...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDeleteDataConfirmation() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // TODO: Implement data deletion logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            title: 'Akun',
            items: [
              _buildSettingsItem(
                icon: Icons.person_outline,
                title: 'Profil',
                onTap: _navigateToProfile,
              ),
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'Privasi & Keamanan',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                  activeColor: const Color(0xFF05606B),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          _buildSettingsSection(
                title: 'Aplikasi',
                items: [
                  _buildSettingsItem(
                    icon: Icons.language_outlined,
                    title: 'Bahasa',
                    onTap: _navigateToLanguage,
                  ),
                  _buildSettingsItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema',
                    onTap: _navigateToTheme,
                  ),
                  _buildSettingsItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    onTap: _navigateToHelpAndSupport,
                  ),
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'Tentang',
                    onTap: _navigateToAbout,
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 200.ms, delay: 100.ms)
              .slideX(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          _buildSettingsSection(
                title: 'Data',
                items: [
                  _buildSettingsItem(
                    icon: Icons.download_outlined,
                    title: 'Unduh Data',
                    onTap: _downloadData,
                  ),
                  _buildSettingsItem(
                    icon: Icons.delete_outline,
                    title: 'Hapus Data',
                    onTap: _showDeleteDataConfirmation,
                    textColor: Colors.red,
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 200.ms, delay: 200.ms)
              .slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF05606B),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF05606B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor ?? const Color(0xFF05606B),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 8)],
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
