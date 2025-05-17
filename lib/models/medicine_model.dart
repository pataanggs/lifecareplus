class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String timeOfDay;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final String color;
  final String userId;
  final bool reminderEnabled;
  final String? imageUrl;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timeOfDay,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.color,
    required this.userId,
    required this.reminderEnabled,
    this.imageUrl,
  });

  // Create a copy of this Medicine with updated fields
  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? timeOfDay,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? color,
    String? userId,
    bool? reminderEnabled,
    String? imageUrl,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Convert Medicine to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'timeOfDay': timeOfDay,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'notes': notes,
      'color': color,
      'userId': userId,
      'reminderEnabled': reminderEnabled,
      'imageUrl': imageUrl,
    };
  }

  // Create a Medicine from a Map
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      frequency: map['frequency'],
      timeOfDay: map['timeOfDay'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      notes: map['notes'],
      color: map['color'],
      userId: map['userId'],
      reminderEnabled: map['reminderEnabled'],
      imageUrl: map['imageUrl'],
    );
  }

  // Generate a new ID for a medicine
  static String generateId() {
    return 'med_${DateTime.now().millisecondsSinceEpoch}_${(100000 + (DateTime.now().microsecond % 100000))}';
  }
}
