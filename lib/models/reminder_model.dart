class Reminder {
  final String id;
  final String title;
  final DateTime renewalDate;
  final DateTime notifyDate;
  final String repeat; // e.g., "None", "Daily", "Weekly", "Monthly", "Yearly"
  final String note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String source; // 'user' or 'web'
  final bool isDeleted; // For web reminders, soft delete flag

  Reminder({
    required this.id,
    required this.title,
    required this.renewalDate,
    required this.notifyDate,
    required this.repeat,
    required this.note,
    required this.createdAt,
    this.updatedAt,
    this.source = 'user', // Default to 'user' for backward compatibility
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'renewalDate': renewalDate.toIso8601String(),
      'notifyDate': notifyDate.toIso8601String(),
      'repeat': repeat,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'source': source,
      'isDeleted': isDeleted,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      renewalDate: DateTime.parse(json['renewalDate'] as String),
      notifyDate: DateTime.parse(json['notifyDate'] as String),
      repeat: json['repeat'] as String? ?? 'None',
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      source: json['source'] as String? ?? 'user',
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? renewalDate,
    DateTime? notifyDate,
    String? repeat,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? source,
    bool? isDeleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      renewalDate: renewalDate ?? this.renewalDate,
      notifyDate: notifyDate ?? this.notifyDate,
      repeat: repeat ?? this.repeat,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      source: source ?? this.source,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}



