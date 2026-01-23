import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

class NotificationDatabase {
  static final NotificationDatabase _instance = NotificationDatabase._internal();
  factory NotificationDatabase() => _instance;
  NotificationDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        publish_date TEXT NOT NULL,
        end_publish_date TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create notification_state table
    await db.execute('''
      CREATE TABLE notification_state (
        notification_id INTEGER PRIMARY KEY,
        is_read INTEGER NOT NULL DEFAULT 0,
        is_hidden INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (notification_id) REFERENCES notifications (id)
      )
    ''');
  }

  // Save or update notification
  Future<void> saveNotification(Notification notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Check if notification_state exists, if not create it
    final existingState = await db.query(
      'notification_state',
      where: 'notification_id = ?',
      whereArgs: [notification.id],
    );

    if (existingState.isEmpty) {
      await db.insert(
        'notification_state',
        {
          'notification_id': notification.id,
          'is_read': 0,
          'is_hidden': 0,
        },
      );
    }
  }

  // Save multiple notifications
  Future<void> saveNotifications(List<Notification> notifications) async {
    final db = await database;
    
    // First, get all existing notification states
    final existingStates = await db.query('notification_state');
    final existingIds = existingStates.map((row) => row['notification_id'] as int).toSet();
    
    final batch = db.batch();

    for (var notification in notifications) {
      batch.insert(
        'notifications',
        notification.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Only insert notification_state if it doesn't exist
      if (!existingIds.contains(notification.id)) {
        batch.insert(
          'notification_state',
          {
            'notification_id': notification.id,
            'is_read': 0,
            'is_hidden': 0,
          },
        );
      }
    }

    await batch.commit(noResult: true);
  }

  // Get all notifications that are not hidden
  Future<List<NotificationWithState>> getVisibleNotifications() async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT 
        n.*,
        COALESCE(ns.is_read, 0) as is_read,
        COALESCE(ns.is_hidden, 0) as is_hidden
      FROM notifications n
      LEFT JOIN notification_state ns ON n.id = ns.notification_id
      WHERE COALESCE(ns.is_hidden, 0) = 0
        AND n.status = 'active'
        AND datetime(n.publish_date) <= datetime('now')
        AND (n.end_publish_date IS NULL OR datetime(n.end_publish_date) >= datetime('now'))
      ORDER BY n.publish_date DESC
    ''');

    return results.map((row) {
      final notification = Notification.fromMap({
        'id': row['id'] as int,
        'title': row['title'] as String,
        'content': row['content'] as String,
        'type': row['type'] as String,
        'publish_date': row['publish_date'] as String,
        'end_publish_date': row['end_publish_date'] as String?,
        'status': row['status'] as String,
        'created_at': row['created_at'] as String,
        'updated_at': row['updated_at'] as String,
      });

      final state = NotificationState(
        notificationId: notification.id,
        isRead: (row['is_read'] as int) == 1,
        isHidden: (row['is_hidden'] as int) == 1,
      );

      return NotificationWithState(notification: notification, state: state);
    }).toList();
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final db = await database;
    
    // Ensure notification_state exists
    final existingState = await db.query(
      'notification_state',
      where: 'notification_id = ?',
      whereArgs: [notificationId],
    );

    if (existingState.isEmpty) {
      await db.insert(
        'notification_state',
        {
          'notification_id': notificationId,
          'is_read': 1,
          'is_hidden': 0,
        },
      );
    } else {
      await db.update(
        'notification_state',
        {'is_read': 1},
        where: 'notification_id = ?',
        whereArgs: [notificationId],
      );
    }
  }

  // Mark notification as hidden (delete)
  Future<void> markAsHidden(int notificationId) async {
    final db = await database;
    
    // Ensure notification_state exists
    final existingState = await db.query(
      'notification_state',
      where: 'notification_id = ?',
      whereArgs: [notificationId],
    );

    if (existingState.isEmpty) {
      await db.insert(
        'notification_state',
        {
          'notification_id': notificationId,
          'is_read': 0,
          'is_hidden': 1,
        },
      );
    } else {
      await db.update(
        'notification_state',
        {'is_hidden': 1},
        where: 'notification_id = ?',
        whereArgs: [notificationId],
      );
    }
  }

  // Get count of unread notifications
  Future<int> getUnreadCount() async {
    final db = await database;
    
    final results = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM notifications n
      LEFT JOIN notification_state ns ON n.id = ns.notification_id
      WHERE COALESCE(ns.is_hidden, 0) = 0
        AND COALESCE(ns.is_read, 0) = 0
        AND n.status = 'active'
        AND datetime(n.publish_date) <= datetime('now')
        AND (n.end_publish_date IS NULL OR datetime(n.end_publish_date) >= datetime('now'))
    ''');

    return Sqflite.firstIntValue(results) ?? 0;
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    // Get all visible notification IDs
    final notifications = await getVisibleNotifications();
    
    for (var notifWithState in notifications) {
      await markAsRead(notifWithState.notification.id);
    }
  }

  // Mark all notifications as hidden (delete all)
  Future<void> markAllAsHidden() async {
    // Get all visible notification IDs
    final notifications = await getVisibleNotifications();
    
    for (var notifWithState in notifications) {
      await markAsHidden(notifWithState.notification.id);
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
