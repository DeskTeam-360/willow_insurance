class Notification {
  final int id;
  final String title;
  final String content;
  final String type;
  final DateTime publishDate;
  final DateTime? endPublishDate;
  final String status; // draft, active, stop
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.publishDate,
    this.endPublishDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? '',
      publishDate: json['publish_date'] != null
          ? DateTime.parse(json['publish_date'] as String)
          : DateTime.now(),
      endPublishDate: json['end_publish_date'] != null
          ? DateTime.parse(json['end_publish_date'] as String)
          : null,
      status: json['status'] as String? ?? 'draft',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'publish_date': publishDate.toIso8601String(),
      'end_publish_date': endPublishDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'publish_date': publishDate.toIso8601String(),
      'end_publish_date': endPublishDate?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      publishDate: DateTime.parse(map['publish_date'] as String),
      endPublishDate: map['end_publish_date'] != null
          ? DateTime.parse(map['end_publish_date'] as String)
          : null,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class NotificationState {
  final int notificationId;
  final bool isRead;
  final bool isHidden;

  NotificationState({
    required this.notificationId,
    required this.isRead,
    required this.isHidden,
  });

  Map<String, dynamic> toMap() {
    return {
      'notification_id': notificationId,
      'is_read': isRead ? 1 : 0,
      'is_hidden': isHidden ? 1 : 0,
    };
  }

  factory NotificationState.fromMap(Map<String, dynamic> map) {
    return NotificationState(
      notificationId: map['notification_id'] as int,
      isRead: (map['is_read'] as int) == 1,
      isHidden: (map['is_hidden'] as int) == 1,
    );
  }
}

class NotificationWithState {
  final Notification notification;
  final NotificationState state;

  NotificationWithState({
    required this.notification,
    required this.state,
  });
}
