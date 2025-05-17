import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/mock_medication_service.dart';
import '../utils/colors.dart';
import '../widgets/rounded_button.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  bool _showContent = false;
  final MockMedicationService _medicationService = MockMedicationService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  void _addNewMedication() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    ).then((value) {
      // Refresh the list when returning from add screen
      setState(() {});
    });
  }

  void _viewMedicationDetails(String medicationId) {
    HapticFeedback.selectionClick();
    // Navigate to details screen
  }

  void _deleteMedication(String medicationId) async {
    try {
      await _medicationService.deleteMedication(medicationId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus obat')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05606B), Color(0xFF88C1D0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header UI code...
                const SizedBox(height: 40),

                // Medications list heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Pengingat Obat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // Medications list from local storage
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _medicationService.getMedications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];

                          return _buildMedicationCard(
                            id: data['id'] ?? '',
                            name: data['name'] ?? '',
                            schedule: data['frequency'] ?? '',
                            time: data['time'] ?? '',
                            remaining: data['currentStock'] ?? 0,
                            unit: data['unitType'] ?? 'tablet',
                            isActive: data['isActive'] ?? true,
                            delay: 500 + (index * 100),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Add new medication button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: RoundedButton(
                      text: 'Tambahkan',
                      onPressed: _addNewMedication,
                      color: AppColors.textHighlight,
                      textColor: Colors.black,
                      icon: Icons.add,
                      width: 200,
                      height: 56,
                      borderRadius: 28,
                      elevation: 3,
                    ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard({
    required String id,
    required String name,
    required String schedule,
    required String time,
    required int remaining,
    required String unit,
    required bool isActive,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Hapus Pengingat?'),
                  content: const Text(
                    'Anda yakin ingin menghapus pengingat obat ini?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
          );
        },
        onDismissed: (direction) => _deleteMedication(id),
        child: InkWell(
          onTap: () => _viewMedicationDetails(id),
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medication name and icon
                  Row(
                    children: [
                      const Icon(
                        Icons.medication_rounded,
                        color: Color(0xFF05606B),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05606B),
                          ),
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeColor: const Color(0xFF05606B),
                        onChanged: (value) {
                          _medicationService.toggleMedicationStatus(id, value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Schedule info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$schedule - $time',
                        style: TextStyle(
                          fontSize: 16,
                          color: isActive ? Colors.black87 : Colors.grey,
                        ),
                      ),

                      // Remaining pills
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? Colors.grey.shade200
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$remaining $unit Tersisa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isActive
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 600.ms);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_liquid_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada pengingat obat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol tambah untuk membuat pengingat obat baru.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 600.ms);
  }
}
