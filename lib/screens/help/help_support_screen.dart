import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Bagaimana cara menambahkan pengingat obat?',
      answer:
          'Untuk menambahkan pengingat obat, buka menu "Pengingat Obat" dan tekan tombol "+" di pojok kanan atas. Isi detail obat dan waktu pengingat yang diinginkan.',
    ),
    FAQItem(
      question: 'Bagaimana cara mengubah profil saya?',
      answer:
          'Untuk mengubah profil, buka menu "Pengaturan" dan pilih "Profil". Anda dapat mengubah informasi pribadi dan medis Anda di sana.',
    ),
    FAQItem(
      question: 'Bagaimana cara menghubungi dokter?',
      answer:
          'Anda dapat menghubungi dokter melalui fitur "Konsultasi" di menu utama. Pilih dokter yang tersedia dan mulai percakapan.',
    ),
    FAQItem(
      question: 'Bagaimana cara mengunduh data medis saya?',
      answer:
          'Untuk mengunduh data medis, buka menu "Pengaturan" dan pilih "Unduh Data". Data akan diunduh dalam format PDF.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & Dukungan')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildContactSection(),
            _buildFAQsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari bantuan...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hubungi Kami',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            title: 'Layanan Pelanggan',
            subtitle: 'Senin - Jumat, 08:00 - 17:00',
            icon: Icons.support_agent,
            onTap: () => _contactCustomerService(),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            title: 'Email Support',
            subtitle: 'support@lifecareplus.com',
            icon: Icons.email_outlined,
            onTap: () => _sendEmail(),
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            title: 'WhatsApp',
            subtitle: '+62 812-3456-7890',
            icon: Icons.chat_outlined,
            onTap: () => _openWhatsApp(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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
                child: Icon(icon, color: const Color(0xFF05606B), size: 24),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._faqs.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _contactCustomerService() {
    // Implement customer service contact
    HapticFeedback.mediumImpact();
    // Add phone call functionality
  }

  void _sendEmail() {
    // Implement email functionality
    HapticFeedback.mediumImpact();
    // Add email sending functionality
  }

  void _openWhatsApp() {
    // Implement WhatsApp functionality
    HapticFeedback.mediumImpact();
    // Add WhatsApp opening functionality
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
