class MedicineModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String dosage;
  final String frequency;
  final String interval;
  final List<DateTime> scheduledTimes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? imageUrl;
  final List<DateTime>? takenDates;
  final List<DateTime>? missedDates;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicineModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.dosage,
    required this.frequency,
    required this.interval,
    required this.scheduledTimes,
    this.startDate,
    this.endDate,
    this.imageUrl,
    this.takenDates,
    this.missedDates,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map, String id) {
    return MedicineModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      interval: map['interval'] ?? '',
      scheduledTimes: List<DateTime>.from(
        (map['scheduledTimes'] ?? []).map((x) => x.toDate()),
      ),
      startDate: map['startDate']?.toDate(),
      endDate: map['endDate']?.toDate(),
      imageUrl: map['imageUrl'],
      takenDates:
          map['takenDates'] != null
              ? List<DateTime>.from(map['takenDates'].map((x) => x.toDate()))
              : [],
      missedDates:
          map['missedDates'] != null
              ? List<DateTime>.from(map['missedDates'].map((x) => x.toDate()))
              : [],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'dosage': dosage,
      'frequency': frequency,
      'interval': interval,
      'scheduledTimes': scheduledTimes,
      'startDate': startDate,
      'endDate': endDate,
      'imageUrl': imageUrl,
      'takenDates': takenDates,
      'missedDates': missedDates,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': DateTime.now(),
    };
  }

  MedicineModel copyWith({
    String? name,
    String? description,
    String? dosage,
    String? frequency,
    String? interval,
    List<DateTime>? scheduledTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    List<DateTime>? takenDates,
    List<DateTime>? missedDates,
    bool? isActive,
  }) {
    return MedicineModel(
      id: this.id,
      userId: this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      takenDates: takenDates ?? this.takenDates,
      missedDates: missedDates ?? this.missedDates,
      isActive: isActive ?? this.isActive,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Mark medicine as taken
  MedicineModel markAsTaken(DateTime takenDate) {
    final List<DateTime> newTakenDates = [...?takenDates, takenDate];
    return copyWith(takenDates: newTakenDates);
  }

  // Mark medicine as missed
  MedicineModel markAsMissed(DateTime missedDate) {
    final List<DateTime> newMissedDates = [...?missedDates, missedDate];
    return copyWith(missedDates: newMissedDates);
  }
}
