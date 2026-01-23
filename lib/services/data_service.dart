import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_init_model.dart';

class DataService {
  static const String apiUrl =
      'https://willowinsurance.ca/wp-json/custom-api/v1/data-init';
      // static const String apiUrl =
      // 'https://willowinsurance.youare.ninja/wp-json/custom-api/v1/data-init';

  // Singleton instance
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Store the loaded data
  DataInit? _cachedData;

  /// Get cached data if available
  DataInit? get cachedData => _cachedData;

  static const String _deviceIdKey = 'device_id';

  /// Get device ID in format DEV-{device_id} (same as LogUtil)
  Future<String> _getDeviceId() async {
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
      print('Error getting device ID: $e');
      return 'DEV-error';
    }
  }

  /// Get platform name
  String _getPlatform() {
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

  /// Get device model
  Future<String> _getDeviceModel() async {
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
      print('Error getting device model: $e');
      return 'Unknown';
    }
    return 'Unknown';
  }

  /// Fetch data from API
  Future<DataInit?> fetchData() async {
    try {
      // Get device information
      final deviceId = await _getDeviceId();
      final platform = _getPlatform();
      final deviceModel = await _getDeviceModel();
      
      // Build URL with query parameters
      final uri = Uri.parse(apiUrl).replace(queryParameters: {
        'device_id': deviceId,
        'event_type': 'Open apps',
        'platform': platform,
        'device_model': deviceModel,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        _cachedData = DataInit.fromJson(jsonData);
        return _cachedData;
      } else {
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  /// Clear cached data
  void clearCache() {
    _cachedData = null;
  }

  /// Check if data is loaded
  bool get isDataLoaded => _cachedData != null;
}



















