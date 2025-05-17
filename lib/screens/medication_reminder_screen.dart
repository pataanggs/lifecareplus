import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'add_medication_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  bool _showContent = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _medications = [];
  String _nickname = 'Pengguna';
  String _formattedDate = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    initializeDateFormatting('id_ID').then((_) {
      _setFormattedDate();
      if (mounted) setState(() {});
    });

      _fetchMedications();
    _loadUserData();

  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID'); // Contoh: Sabtu, Des 18
    final formatted = formatter.format(now);

    // Set kapital di awal setiap kata (optional)
    _formattedDate = formatted
        .split(' ')
        .map((word) =>
    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');

    if (mounted) setState(() {});
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _nickname = data['nickname'] ?? 'Pengguna';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _fetchMedications() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medications')
          .where('isActive', isEqualTo: true)
          .get();

      final meds = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      if (mounted) {
        setState(() {
          _medications = meds;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching medications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _createReminder() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    ).then((_) {
      // Refresh meds list after returning from AddMedicationScreen
      _fetchMedications();
    });
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          medication['name'] ?? 'Nama Obat',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          medication['dosage'] ?? 'Dosis tidak tersedia',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Icon(Icons.medication_outlined, color: AppColors.textHighlight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF05606B), // Teal at top
              Color(0xFF88C1D0), // Light blue in middle
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header, back button, etc. (bisa kamu sesuaikan seperti sebelumnya)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Greeting text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $_nickname',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                          const SizedBox(height: 4),
                          Text(
                            _formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                        ],
                      ),

                      // Profile icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back button & title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (route) => false);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Pengobatan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _medications.isEmpty
                      ? Center(
                    child: RoundedButton(
                      text: 'Buat Pengingat Pertama',
                      onPressed: _createReminder,
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      width: 300,
                      height: 50,
                      borderRadius: 25,
                      elevation: 3,
                    )
                        .animate(delay: 700.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                        .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutQuad,
                    ),
                  )
                      : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _medications.length,
                          itemBuilder: (context, index) {
                            final medication = _medications[index];
                            return _buildMedicationCard(medication);
                          },
                        ),
                      ),

                      // Button tambah pengingat di bawah card
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, bottom: 40),
                        child: RoundedButton(
                          text: 'Tambah Pengingat',
                          onPressed: _createReminder,
                          color: AppColors.textHighlight,
                          textColor: Colors.black,
                          width: 300,
                          height: 50,
                          borderRadius: 25,
                          elevation: 3,
                        )
                            .animate(delay: 700.ms)
                            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                            .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
