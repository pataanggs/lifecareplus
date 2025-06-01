import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  String _selectedTheme = 'system'; // Default to system theme

  final List<ThemeOption> _themes = [
    ThemeOption(
      id: 'system',
      name: 'Sistem',
      description: 'Mengikuti pengaturan tema sistem',
      icon: Icons.brightness_auto,
    ),
    ThemeOption(
      id: 'light',
      name: 'Terang',
      description: 'Tema terang untuk penggunaan siang hari',
      icon: Icons.light_mode,
    ),
    ThemeOption(
      id: 'dark',
      name: 'Gelap',
      description: 'Tema gelap untuk penggunaan malam hari',
      icon: Icons.dark_mode,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema Aplikasi')),
      body: Column(
        children: [
          _buildThemePreview(),
          Expanded(
            child: ListView.builder(
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                return _buildThemeTile(theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Pratinjau Tema',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPreviewItem(
                  icon: Icons.home,
                  title: 'Beranda',
                  subtitle: 'Menu utama aplikasi',
                ),
                const Divider(),
                _buildPreviewItem(
                  icon: Icons.notifications,
                  title: 'Notifikasi',
                  subtitle: 'Pemberitahuan terbaru',
                ),
                const Divider(),
                _buildPreviewItem(
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  subtitle: 'Konfigurasi aplikasi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF05606B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF05606B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildThemeTile(ThemeOption theme) {
    final isSelected = theme.id == _selectedTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? BorderSide(color: const Color(0xFF05606B), width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _selectedTheme = theme.id;
          });
          // Implement theme change functionality
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF05606B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  theme.icon,
                  color: const Color(0xFF05606B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF05606B).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF05606B),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeOption {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  ThemeOption({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}
