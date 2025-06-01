import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'Indonesia';
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSettingsSection(
                  title: 'Akun',
                  items: [
                    _buildSettingsItem(
                      icon: Icons.person_outline,
                      title: 'Profil',
                      onTap: () => _navigateToProfile(),
                    ),
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        activeColor: const Color(0xFF05606B),
                      ),
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
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  title: 'Aplikasi',
                  items: [
                    _buildSettingsItem(
                      icon: Icons.language_outlined,
                      title: 'Bahasa',
                      trailing: DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        items:
                            ['Indonesia', 'English']
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                        onChanged: _changeLanguage,
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Tema',
                      trailing: Switch(
                        value: _isDarkMode,
                        onChanged: _toggleTheme,
                        activeColor: const Color(0xFF05606B),
                      ),
                    ),
                    _buildSettingsItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan & Dukungan',
                      onTap: () => _showHelpAndSupport(),
                    ),
                    _buildSettingsItem(
                      icon: Icons.info_outline,
                      title: 'Tentang',
                      onTap: () => _showAbout(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  title: 'Data',
                  items: [
                    _buildSettingsItem(
                      icon: Icons.download_outlined,
                      title: 'Unduh Data',
                      onTap: () => _downloadData(),
                    ),
                    _buildSettingsItem(
                      icon: Icons.delete_outline,
                      title: 'Hapus Data',
                      onTap: () => _showDeleteDataConfirmation(),
                      textColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF05606B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 8)],
            if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.pop(context);
    // Add navigation to profile screen
  }

  void _toggleNotifications(bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _notificationsEnabled = value;
    });
    // Add notification settings logic
  }

  void _toggleBiometric(bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _biometricEnabled = value;
    });
    // Add biometric authentication logic
  }

  void _changeLanguage(String? value) {
    if (value != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _selectedLanguage = value;
      });
      // Add language change logic
    }
  }

  void _toggleTheme(bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      _isDarkMode = value;
    });
    // Add theme change logic
  }

  void _showHelpAndSupport() {
    Navigator.pop(context);
    // Add navigation to help and support screen
  }

  void _showAbout() {
    Navigator.pop(context);
    // Add navigation to about screen
  }

  void _downloadData() {
    HapticFeedback.mediumImpact();
    // Add data download logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mengunduh data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDataConfirmation() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Data'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteData();
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _deleteData() {
    // Add data deletion logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
