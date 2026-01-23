import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/notification_database.dart';
import '../../models/notification_model.dart';
import 'reminders_page.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationWithState notificationWithState;

  NotificationDetailPage({required this.notificationWithState});

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {

  IconData _getIconForType(String type) {
    switch (type) {
      case 'reminder':
        return Icons.schedule;
      case 'claim':
        return Icons.description;
      case 'payment':
        return Icons.payment;
      case 'action':
        return Icons.info;
      case 'blog':
        return Icons.article;
      default:
        return Icons.article;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'reminder':
        return Color(0xFF497844);
      case 'claim':
        return Color(0xFF6DA544);
      case 'payment':
        return Colors.green;
      case 'action':
        return Colors.orange;
      default:
        return Color(0xFF497844);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • hh:mm a').format(date);
  }

  Future<void> _deleteNotification() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Notification'),
        content: Text('Are you sure you want to delete this notification? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final notificationDb = NotificationDatabase();
        await notificationDb.markAsHidden(widget.notificationWithState.notification.id);
        
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Error deleting notification: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting notification'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notification = widget.notificationWithState.notification;
    final state = widget.notificationWithState.state;
    final isRead = state.isRead;
    final type = notification.type;

    // Mark as read when opened
    if (!isRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final notificationDb = NotificationDatabase();
          await notificationDb.markAsRead(notification.id);
        } catch (e) {
          print('Error marking as read: $e');
        }
      });
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF497844)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            color: Color(0xFF497844),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteNotification,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getColorForType(type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getIconForType(type),
                      color: _getColorForType(type),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF497844),
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(notification.publishDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getColorForType(type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForType(type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                notification.content,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.6,
                ),
              ),
              // Add "View Reminder" button for reminder type
              if (type == 'reminder') ...[
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RemindersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF497844),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'View Reminder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
    )
    );
  }
}
