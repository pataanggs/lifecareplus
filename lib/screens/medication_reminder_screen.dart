import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/cubits/medication-reminder/medication_reminder_cubit.dart';
import '/cubits/medication-stock/medication_stock_cubit.dart';
import '/widgets/rounded_button.dart';
import 'add_medication_screen.dart';
import '/utils/colors.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() =>
      _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  String _formattedDate = '';
  MedicationReminderCubit? _medicationCubit;
  MedicationStockCubit? _stockCubit;
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });

    initializeDateFormatting('id_ID').then((_) {
      _setFormattedDate();
      if (mounted) setState(() {});
    });

    _medicationCubit = MedicationReminderCubit();
    _stockCubit = MedicationStockCubit();
    _medicationCubit?.initialize();
    _stockCubit?.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _medicationCubit?.close();
    _stockCubit?.close();
    super.dispose();
  }

  void _setFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d', 'id_ID');
    final formatted = formatter.format(now);
    _formattedDate = formatted
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');

    if (mounted) setState(() {});
  }

  void _createReminder() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    ).then((_) {
      if (mounted) {
        _medicationCubit?.fetchMedications();
      }
    });
  }

  void _deleteMedication(String medicationId) async {
    HapticFeedback.mediumImpact();
    await _stockCubit?.deleteMedication(medicationId);
    if (mounted) {
      _medicationCubit?.fetchMedications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat obat berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _filterMedications(
    List<Map<String, dynamic>> medications,
  ) {
    return medications.where((med) {
      final matchesSearch = med['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesFilter =
          _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Stok Rendah' &&
              med['stockReminderEnabled'] == true &&
              (med['currentStock'] ?? 0) <= (med['reminderThreshold'] ?? 0)) ||
          (_selectedFilter == 'Aktif' && med['isActive'] == true);
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_medicationCubit == null || _stockCubit == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _medicationCubit!),
        BlocProvider.value(value: _stockCubit!),
      ],
      child: BlocConsumer<MedicationReminderCubit, MedicationReminderState>(
        listener: (context, state) {
          if (state is MedicationReminderStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.data.errorMessage ?? 'Error')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF05606B), Color(0xFF88C1D0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child:
                      state is MedicationReminderStateLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state is MedicationReminderStateError
                          ? Center(
                            child: Text(
                              state.data.errorMessage ?? 'An error occurred',
                            ),
                          )
                          : state is MedicationReminderStateLoaded
                          ? _buildContent(state.data)
                          : const SizedBox(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(MedicationReminderStateData data) {
    final filteredMedications = _filterMedications(data.medications);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(data),
        _buildSearchAndFilter(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMedicationList(filteredMedications),
              _buildUpcomingReminders(filteredMedications),
              _buildLowStockMedications(filteredMedications),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(MedicationReminderStateData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${data.nickname}',
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
          const SizedBox(height: 24),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Text(
                'Pengingat Obat',
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
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Container(
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
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari obat...',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                _buildFilterChip('Stok Rendah'),
                _buildFilterChip('Aktif'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) => setState(() => _selectedFilter = label),
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: AppColors.textHighlight,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.textHighlight,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Semua'),
          Tab(text: 'Jadwal'),
          Tab(text: 'Stok'),
        ],
      ),
    );
  }

  Widget _buildMedicationList(List<Map<String, dynamic>> medications) {
    if (medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengingat obat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            RoundedButton(
              text: 'Buat Pengingat Pertama',
              onPressed: _createReminder,
              color: AppColors.textHighlight,
              textColor: Colors.black,
              width: 300,
              height: 50,
              borderRadius: 25,
              elevation: 3,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildUpcomingReminders(List<Map<String, dynamic>> medications) {
    final now = DateTime.now();
    final upcomingMedications =
        medications.where((med) {
          final time = med['time']?.toString() ?? '';
          if (time.isEmpty) return false;

          final timeParts = time.split(':');
          if (timeParts.length != 2) return false;

          final reminderTime = DateTime(
            now.year,
            now.month,
            now.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          return reminderTime.isAfter(now);
        }).toList();

    if (upcomingMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal obat hari ini',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: upcomingMedications.length,
      itemBuilder: (context, index) {
        final medication = upcomingMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildLowStockMedications(List<Map<String, dynamic>> medications) {
    final lowStockMedications =
        medications
            .where(
              (med) =>
                  med['stockReminderEnabled'] == true &&
                  (med['currentStock'] ?? 0) <= (med['reminderThreshold'] ?? 0),
            )
            .toList();

    if (lowStockMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada obat dengan stok rendah',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: lowStockMedications.length,
      itemBuilder: (context, index) {
        final medication = lowStockMedications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final bool isLowStock =
        medication['stockReminderEnabled'] == true &&
        (medication['currentStock'] ?? 0) <=
            (medication['reminderThreshold'] ?? 0);

    return Slidable(
      key: ValueKey(medication['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _deleteMedication(medication['id']),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                isLowStock
                    ? Border.all(color: Colors.red.shade300, width: 2)
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'] ?? 'Nama Obat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medication['dosage']} ${medication['unitType']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textHighlight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.textHighlight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medication['time'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    if (medication['stockReminderEnabled'] == true) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color:
                                isLowStock ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stok: ${medication['currentStock']} ${medication['unitType']}',
                            style: TextStyle(
                              color:
                                  isLowStock
                                      ? Colors.red
                                      : Colors.grey.shade600,
                              fontWeight: isLowStock ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 400.ms).fadeIn(duration: 400.ms);
  }
}
