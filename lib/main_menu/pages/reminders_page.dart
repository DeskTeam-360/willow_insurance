import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../models/reminder_model.dart';
import '../../services/notification_database.dart';
import '../../models/notification_model.dart';

class RemindersPage extends StatefulWidget {
  RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _renewalDate;
  DateTime? _notifyDate;
  String _repeat = 'None';
  List<Reminder> _reminders = [];
  List<Reminder> _allReminders = []; // Store all reminders including deleted ones
  String? _editingReminderId;
  final String _storageKey = 'saved_reminders';

  final List<String> _repeatOptions = [
    'None',
    'Daily',
    // 'Weekly',
    'Monthly',
    // 'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'DEVC-${androidInfo.id}'; // ANDROID_ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'DEVC-${iosInfo.identifierForVendor ?? "unknown"}';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'DEVC-error';
    }
    return 'DEVC-unknown';
  }

  // Create notification from reminder
  Future<void> _createNotificationFromReminder(Reminder reminder) async {
    try {
      final notificationDb = NotificationDatabase();
      
      // Generate unique notification ID from reminder ID
      // Use hash of reminder ID to ensure it's a valid integer
      final notificationId = reminder.id.hashCode.abs();
      
      // Create notification content
      final content = reminder.note.isNotEmpty 
          ? reminder.note 
          : 'Reminder: ${reminder.title}';
      
      // Set publish date: if notifyDate is today or earlier, use current time
      // Otherwise use notifyDate
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final notifyDateOnly = DateTime(
        reminder.notifyDate.year,
        reminder.notifyDate.month,
        reminder.notifyDate.day,
      );
      
      DateTime publishDate;
      if (notifyDateOnly.isAtSameMomentAs(today) || notifyDateOnly.isBefore(today)) {
        // If notify date is today or earlier, publish immediately
        publishDate = now;
      } else {
        // If notify date is in the future, use notifyDate
        publishDate = reminder.notifyDate;
      }
      
      // Set end publish date based on repeat type
      DateTime? endPublishDate;
      if (reminder.repeat == 'Daily') {
        endPublishDate = null; // Daily reminders don't expire
      } else if (reminder.repeat == 'Monthly') {
        endPublishDate = reminder.renewalDate; // Monthly expires on renewal date
      } else {
        // For 'None' or other types, set end date to renewal date
        endPublishDate = reminder.renewalDate;
      }
      
      final notification = Notification(
        id: notificationId,
        title: reminder.title,
        content: content,
        type: 'reminder',
        publishDate: publishDate,
        endPublishDate: endPublishDate,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await notificationDb.saveNotification(notification);
      debugPrint('Notification created for reminder: ${reminder.title} (repeat: ${reminder.repeat}, publishDate: $publishDate)');
    } catch (e) {
      debugPrint('Error creating notification from reminder: $e');
      // Don't show error to user, just log it
    }
  }

  Future<void> _submitReminderToAPI(Reminder reminder) async {
    try {
      final deviceId = await _getDeviceId();
      final apiUrl = 'https://willowinsurance.youare.ninja/wp-json/gf-custom/v1/submit';
      
      // Format dates as YYYY-MM-DD
      final renewalDateStr = DateFormat('yyyy-MM-dd').format(reminder.renewalDate);
      final notifyDateStr = DateFormat('yyyy-MM-dd').format(reminder.notifyDate);
      
      // Convert repeat to lowercase for API
      final repeatStr = reminder.repeat.toLowerCase();
      
      final body = json.encode({
        'title': reminder.title,
        'renewal_date': renewalDateStr,
        'notify_me_on': notifyDateStr,
        'repeat': repeatStr,
        'note': reminder.note,
        'device_id': deviceId,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Reminder submitted successfully to API');
      } else {
        debugPrint('Failed to submit reminder: ${response.statusCode} - ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sync reminder to server'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error submitting reminder to API: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing reminder: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(_storageKey);
      if (remindersJson != null && remindersJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(remindersJson) as List<dynamic>;
        // Load ALL reminders including deleted ones
        _allReminders = decoded
            .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
            .toList();

        // Filter out deleted web reminders for display
        List<Reminder> loadedReminders = _allReminders.where((r) => !r.isDeleted).toList();

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        List<Reminder> processedReminders = [];

        // Track Daily reminders by title+source to avoid duplicates
        final Map<String, Reminder> dailyRemindersMap = {};
        
        for (var reminder in loadedReminders) {
          if (reminder.repeat == 'Daily') {
            // For Daily: always show reminder for today or later
            final renewalDateOnly = DateTime(
              reminder.renewalDate.year,
              reminder.renewalDate.month,
              reminder.renewalDate.day,
            );
            
            // Create unique key for this daily reminder (title + source)
            final reminderKey = '${reminder.title}_${reminder.source}';
            
            // If reminder is for today or later, always show it
            if (renewalDateOnly.isAtSameMomentAs(today) || renewalDateOnly.isAfter(today)) {
              // Keep the one with earliest date, or replace if this one is earlier
              if (!dailyRemindersMap.containsKey(reminderKey) ||
                  dailyRemindersMap[reminderKey]!.renewalDate.isAfter(renewalDateOnly)) {
                dailyRemindersMap[reminderKey] = reminder;
              }
            } else {
              // If reminder date has passed, create one for today if not exists
              if (!dailyRemindersMap.containsKey(reminderKey)) {
                final newReminder = Reminder(
                  id: '${reminder.id}_${today.millisecondsSinceEpoch}',
                  title: reminder.title,
                  renewalDate: today,
                  notifyDate: today,
                  repeat: 'Daily',
                  note: reminder.note,
                  createdAt: DateTime.now(),
                  source: reminder.source,
                );
                dailyRemindersMap[reminderKey] = newReminder;
                // Also add to _allReminders (will be saved later)
                _allReminders.add(newReminder);
                // Create notification for this daily reminder
                _createNotificationFromReminder(newReminder);
              }
            }
          } else if (reminder.repeat == 'Monthly') {
            // For Monthly: only show if renewal date hasn't passed
            final renewalDateOnly = DateTime(
              reminder.renewalDate.year,
              reminder.renewalDate.month,
              reminder.renewalDate.day,
            );
            
            if (renewalDateOnly.isAtSameMomentAs(today) || renewalDateOnly.isAfter(today)) {
              processedReminders.add(reminder);
            }
            // If renewal date has passed, don't add it (it will be removed)
          } else {
            // For 'None' or other types, keep as is
            processedReminders.add(reminder);
          }
        }
        
        // Add all Daily reminders from map to processed list
        processedReminders.addAll(dailyRemindersMap.values);

        if (mounted) {
          setState(() {
            _reminders = processedReminders;
            // Sort by renewal date, earliest first
            _reminders.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));
            
            // Update _allReminders: keep deleted ones, update/remove others
            // Remove old non-deleted reminders and add new processed ones
            _allReminders = _allReminders.where((r) => r.isDeleted).toList();
            _allReminders.addAll(processedReminders);
          });
          // Save all reminders (including deleted) back
          _saveReminders();
          
          // Create notifications for all reminders that should be notified today or earlier
          // This applies to all repeat types: None, Daily, Monthly
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          for (var reminder in processedReminders) {
            final notifyDateOnly = DateTime(
              reminder.notifyDate.year,
              reminder.notifyDate.month,
              reminder.notifyDate.day,
            );
            
            // Create notification if notify date is today or earlier
            // This works for all repeat types: None, Daily, Monthly
            if (notifyDateOnly.isAtSameMomentAs(today) || notifyDateOnly.isBefore(today)) {
              _createNotificationFromReminder(reminder);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  Future<void> _saveReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Save ALL reminders including deleted ones
      final remindersJson = json.encode(
        _allReminders.map((reminder) => reminder.toJson()).toList(),
      );
      await prefs.setString(_storageKey, remindersJson);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reminders: $e')),
        );
      }
    }
  }

  Future<void> _selectRenewalDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _renewalDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF71A33F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _renewalDate) {
      setState(() {
        _renewalDate = picked;
        // If notify date is not set or is after renewal date, set it to renewal date
        if (_notifyDate == null || _notifyDate!.isAfter(picked)) {
          _notifyDate = picked;
        }
      });
    }
  }

  Future<void> _selectNotifyDate() async {
    if (_renewalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select Renewal Date first')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _notifyDate ?? _renewalDate!,
      firstDate: DateTime.now(),
      lastDate: _renewalDate!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF71A33F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _notifyDate) {
      setState(() {
        _notifyDate = picked;
      });
    }
  }

  void _addOrUpdateReminder() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    if (_renewalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select Renewal Date')),
      );
      return;
    }

    if (_notifyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select Notify Date')),
      );
      return;
    }

    setState(() {
      if (_editingReminderId != null) {
        // Update existing reminder
        final index = _reminders.indexWhere((reminder) => reminder.id == _editingReminderId);
        if (index != -1) {
          final updatedReminder = _reminders[index].copyWith(
            title: _titleController.text.trim(),
            renewalDate: _renewalDate!,
            notifyDate: _notifyDate!,
            repeat: _repeat,
            note: _noteController.text.trim(),
            updatedAt: DateTime.now(),
          );
          _reminders[index] = updatedReminder;
          
          // Also update in _allReminders
          final allIndex = _allReminders.indexWhere((r) => r.id == _editingReminderId);
          if (allIndex != -1) {
            _allReminders[allIndex] = updatedReminder;
          }
        }
        _editingReminderId = null;
      } else {
        // Add new reminder
        final newReminder = Reminder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          renewalDate: _renewalDate!,
          notifyDate: _notifyDate!,
          repeat: _repeat,
          note: _noteController.text.trim(),
          createdAt: DateTime.now(),
          source: 'user', // Explicitly set as user-created
        );
        _reminders.insert(0, newReminder);
        _allReminders.insert(0, newReminder); // Also add to all reminders list
        
        // Create notification for this reminder
        _createNotificationFromReminder(newReminder);
        
        // Submit to API
        _submitReminderToAPI(newReminder);
      }
      _reminders.sort((a, b) => a.renewalDate.compareTo(b.renewalDate));
    });

    _titleController.clear();
    _noteController.clear();
    setState(() {
      _renewalDate = null;
      _notifyDate = null;
      _repeat = 'None';
    });
    _saveReminders();
  }

  void _deleteReminder(String reminderId) {
    setState(() {
      final index = _reminders.indexWhere((reminder) => reminder.id == reminderId);
      if (index != -1) {
        final reminder = _reminders[index];
        if (reminder.source == 'web') {
          // For web reminders: soft delete (mark as deleted but keep in storage)
          final allIndex = _allReminders.indexWhere((r) => r.id == reminderId);
          if (allIndex != -1) {
            _allReminders[allIndex] = reminder.copyWith(isDeleted: true);
          }
          // Remove from display list
          _reminders.removeAt(index);
        } else {
          // For user reminders: hard delete (remove completely from both lists)
          _reminders.removeAt(index);
          _allReminders.removeWhere((r) => r.id == reminderId);
        }
      }
    });
    _saveReminders();
  }

  void _editReminder(Reminder reminder) {
    setState(() {
      _editingReminderId = reminder.id;
      _titleController.text = reminder.title;
      _noteController.text = reminder.note;
      _renewalDate = reminder.renewalDate;
      _notifyDate = reminder.notifyDate;
      _repeat = reminder.repeat;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingReminderId = null;
      _titleController.clear();
      _noteController.clear();
      _renewalDate = null;
      _notifyDate = null;
      _repeat = 'None';
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header like about_us page
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 60, 30, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
              color: Color(0xFF71A33F),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/images/back_button.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      Color(0xFFFFFFFF),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/willow_logo_white.png',
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.35,
                    child: SvgPicture.asset(
                      'assets/images/willow_splashscreen.svg',
                      width: MediaQuery.of(context).size.width * 2,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Title "Reminders"
                      Center(
                        child: Text(
                          'Reminders',
                          style: TextStyle(
                            color: Color(0xFF497844),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Input fields
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFFffffff),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title field
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Renewal Date field
                            InkWell(
                              onTap: _selectRenewalDate,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xffe0e0e0),
                                    width: 1,
                                  ),
                                ),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Renewal Date',
                                    floatingLabelAlignment: FloatingLabelAlignment.start,
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 2,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.calendar_today,
                                      color: Color(0xFF497844),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _renewalDate != null
                                        ? _formatDate(_renewalDate!)
                                        : 'Select Renewal Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: _renewalDate != null
                                          ? Colors.black
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Notify me on field
                            InkWell(
                              onTap: _selectNotifyDate,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xffe0e0e0),
                                    width: 1,
                                  ),
                                ),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Notify me on',
                                    floatingLabelAlignment: FloatingLabelAlignment.start,
                                    floatingLabelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 2,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.notifications,
                                      color: Color(0xFF497844),
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    _notifyDate != null
                                        ? _formatDate(_notifyDate!)
                                        : 'Select Notify Date',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: _notifyDate != null
                                          ? Colors.black
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Repeat field
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Color(0xffe0e0e0),
                                  width: 1,
                                ),
                              ),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Repeat',
                                  floatingLabelAlignment: FloatingLabelAlignment.start,
                                  floatingLabelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    height: 2,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    height: 1.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.repeat,
                                    color: Color(0xFF497844),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _repeat,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                    items: _repeatOptions.map((String option) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _repeat = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Note field
                            TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                labelText: 'Note',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.note,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 3,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      // Save/Update button
                      Row(
                        children: [
                          if (_editingReminderId != null)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cancelEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          if (_editingReminderId != null) SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _addOrUpdateReminder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF71A33F),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _editingReminderId != null
                                    ? 'Update Reminder'
                                    : 'Save Reminder',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      // Reminders list
                      if (_reminders.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              'No reminders yet. Create your first reminder above!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._reminders.map(
                          (reminder) => _ReminderItem(
                            reminder: reminder,
                            onTap: () {
                              setState(() {
                                // Toggle expansion handled in _ReminderItem
                              });
                            },
                            onDelete: () => _deleteReminder(reminder.id),
                            onEdit: () => _editReminder(reminder),
                            formatDate: _formatDate,
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderItem extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String Function(DateTime) formatDate;

  const _ReminderItem({
    required this.reminder,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.formatDate,
  });

  @override
  State<_ReminderItem> createState() => _ReminderItemState();
}

class _ReminderItemState extends State<_ReminderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.reminder.renewalDate.isBefore(DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isOverdue
            ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reminder.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E3E3E),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Renewal: ${widget.formatDate(widget.reminder.renewalDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue ? Colors.red : Colors.grey[600],
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (widget.reminder.repeat != 'None')
                          Text(
                            'Repeat: ${widget.reminder.repeat}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFFDFFEB9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        _isExpanded ? Icons.south_west : Icons.north_east,
                        color: Color(0xFF497844),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications, size: 16, color: Color(0xFF497844)),
                      SizedBox(width: 5),
                      Text(
                        'Notify: ${widget.formatDate(widget.reminder.notifyDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF497844),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (widget.reminder.note.isNotEmpty) ...[
                    SizedBox(height: 10),
                    Text(
                      widget.reminder.note,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3E3E3E),
                        height: 1.5,
                      ),
                    ),
                  ],
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF497844),
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(color: Color(0xFF497844)),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Reminder'),
                              content: Text(
                                'Are you sure you want to delete this reminder?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onDelete();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.delete, size: 18, color: Colors.red),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

