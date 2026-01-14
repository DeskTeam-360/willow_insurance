import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for logging events to the server
/// 
/// Usage:
/// ```dart
/// await LogUtil.saveLog('button_clicked');
/// await LogUtil.saveLog('page_viewed');
/// ```
class LogUtil {
  /// API endpoint for logging
  static const String _apiUrl =
      'https://willowinsurance.ca/wp-json/gf-custom/v1/device-location';
  
  static const String _deviceIdKey = 'device_id';

  /// Get device ID in format DEV-{device_id} (same as DataService)
  static Future<String> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedDeviceId = prefs.getString(_deviceIdKey);
      
      if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
        return savedDeviceId;
      }
      
      // Get device ID from device info
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = 'DEV-${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = 'DEV-${iosInfo.identifierForVendor ?? "unknown"}';
      } else {
        deviceId = 'DEV-unknown';
      }
      
      // Save the device ID for future use
      await prefs.setString(_deviceIdKey, deviceId);
      return deviceId;
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      return 'DEV-error';
    }
  }

  /// Get platform name
  static String _getPlatform() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    }
    return 'Unknown';
  }

  /// Get device model (same as DataService)
  static Future<String> _getDeviceModel() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.model;
      }
    } catch (e) {
      debugPrint('Error getting device model: $e');
      return 'Unknown';
    }
    return 'Unknown';
  }

  /// Save log to server
  /// 
  /// [eventType] - The type of event to log (required)
  /// 
  /// This function automatically includes device_id, platform, and device_model.
  /// It can be called from anywhere in the app.
  /// Only sends log if device is online, fails silently if offline.
  /// 
  /// Example:
  /// ```dart
  /// await LogUtil.saveLog('user_login');
  /// await LogUtil.saveLog('button_pressed');
  /// ```
  static Future<void> saveLog(String eventType) async {
    try {
      final deviceId = await _getDeviceId();
      final platform = _getPlatform();
      final deviceModel = await _getDeviceModel();

      final body = json.encode({
        'device_id': deviceId,
        'platform': platform,
        'device_model': deviceModel,
        'event_type': eventType,
      });

      // Debug: print data yang akan dikirim (untuk troubleshooting)
      debugPrint('[LogUtil] Sending log: $eventType | Device: $deviceId | Platform: $platform | Model: $deviceModel');

      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[LogUtil] ✅ Log saved successfully: $eventType');
      } else {
        debugPrint(
          '[LogUtil] ❌ Failed to save log: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      // Timeout, fail silently tanpa error log
      debugPrint('[LogUtil] ⏱️ Timeout sending log: $eventType (offline/slow connection)');
      return;
    } on SocketException {
      // Offline atau network error, fail silently tanpa error log
      debugPrint('[LogUtil] 📡 Network error (offline): $eventType');
      return;
    } on HttpException {
      // HTTP error, fail silently
      debugPrint('[LogUtil] 🌐 HTTP error: $eventType');
      return;
    } on FormatException {
      // Format/parsing error, fail silently
      debugPrint('[LogUtil] 📝 Format error: $eventType');
      return;
    } catch (e) {
      // Catch-all untuk error yang tidak terduga, tetap fail silently
      debugPrint('[LogUtil] ⚠️ Unexpected error: $eventType - ${e.toString()}');
      return;
    }
  }
}

