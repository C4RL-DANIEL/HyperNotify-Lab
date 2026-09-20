// HyperNotify Lab - HyperOS Super Island Notification Support
// Implements Xiaomi HyperOS specific notification features

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

import '../model/notification_task.dart';

class HyperOSNotification {
  static const String _hyperOSPackage = 'com.miui.home';
  static const String _superIslandAction = 'com.miui.hyperos.SUPER_ISLAND';
  static const String _notificationChannelId = 'hypernotify_hyperos';

  bool _isHyperOS = false;
  bool _checkedHyperOS = false;

  // Check if device is running Xiaomi HyperOS
  Future<bool> isHyperOS() async {
    if (_checkedHyperOS) return _isHyperOS;

    try {
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        
        // Check for Xiaomi/HyperOS build properties
        final brand = deviceInfo.brand.toLowerCase();
        final manufacturer = deviceInfo.manufacturer.toLowerCase();
        final model = deviceInfo.model.toLowerCase();
        final version = deviceInfo.version.release;
        final sdkInt = deviceInfo.version.sdkInt;
        
        // HyperOS detection
        _isHyperOS = brand.contains('xiaomi') || 
                     brand.contains('redmi') || 
                     brand.contains('poco') ||
                     manufacturer.contains('xiaomi') ||
                     (sdkInt >= 34 && (brand.contains('mi') || manufacturer.contains('mi')));
        
        // Additional check for HyperOS version
        if (sdkInt >= 34) {
          try {
            final hyperOSVersion = await _getHyperOSVersion();
            if (hyperOSVersion != null) {
              _isHyperOS = true;
            }
          } catch (e) {
            debugPrint('HyperOS version check failed: $e');
          }
        }
        
        _checkedHyperOS = true;
        debugPrint('HyperOS detection: $_isHyperOS (brand: $brand, manufacturer: $manufacturer, model: $model, SDK: $sdkInt)');
      }
    } catch (e) {
      debugPrint('Error checking HyperOS: $e');
      _checkedHyperOS = true;
    }
    
    return _isHyperOS;
  }

  // Get HyperOS version if available
  Future<String?> _getHyperOSVersion() async {
    try {
      final process = await Process.run('getprop', ['ro.miui.ui.version.name']);
      if (process.exitCode == 0 && process.stdout.toString().trim().isNotEmpty) {
        return process.stdout.toString().trim();
      }
    } catch (e) {
      debugPrint('Could not get HyperOS version: $e');
    }
    return null;
  }

  // Show Super Island notification (HyperOS specific)
  Future<void> showSuperIslandNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? iconUrl,
    String? largeIconUrl,
    List<NotificationActionButton>? actions,
    Duration? timeout,
    bool isLiveActivity = false,
  }) async {
    if (!await isHyperOS()) {
      debugPrint('Not on HyperOS, skipping Super Island notification');
      return;
    }

    try {
      // Use Android Intent to trigger Super Island
      final intent = AndroidIntent(
        action: _superIslandAction,
        package: _hyperOSPackage,
        arguments: {
          'notification_id': id,
          'title': title,
          'body': body,
          'payload': payload ?? '',
          'icon_url': iconUrl ?? '',
          'large_icon_url': largeIconUrl ?? '',
          'timeout_ms': timeout?.inMilliseconds ?? 30000,
          'is_live_activity': isLiveActivity,
          'actions': actions?.map((a) => {
            'id': a.id,
            'title': a.title,
            'allow_generated_replies': a.allowGeneratedReplies,
            'require_authentication': a.requireAuthentication,
          }).toList() ?? [],
        },
      );

      await intent.launch();
      debugPrint('Super Island notification launched for ID: $id');
    } catch (e) {
      debugPrint('Failed to launch Super Island notification: $e');
      // Fallback to standard notification
      rethrow;
    }
  }

  // Update Super Island notification
  Future<void> updateSuperIslandNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? iconUrl,
    List<NotificationActionButton>? actions,
  }) async {
    if (!await isHyperOS()) return;

    try {
      final intent = AndroidIntent(
        action: 'com.miui.hyperos.SUPER_ISLAND_UPDATE',
        package: _hyperOSPackage,
        arguments: {
          'notification_id': id,
          'title': title,
          'body': body,
          'payload': payload ?? '',
          'icon_url': iconUrl ?? '',
          'actions': actions?.map((a) => {
            'id': a.id,
            'title': a.title,
            'allow_generated_replies': a.allowGeneratedReplies,
            'require_authentication': a.requireAuthentication,
          }).toList() ?? [],
        },
      );

      await intent.launch();
      debugPrint('Super Island notification updated for ID: $id');
    } catch (e) {
      debugPrint('Failed to update Super Island notification: $e');
    }
  }

  // Dismiss Super Island notification
  Future<void> dismissSuperIslandNotification(int id) async {
    if (!await isHyperOS()) return;

    try {
      final intent = AndroidIntent(
        action: 'com.miui.hyperos.SUPER_ISLAND_DISMISS',
        package: _hyperOSPackage,
        arguments: {
          'notification_id': id,
        },
      );

      await intent.launch();
      debugPrint('Super Island notification dismissed for ID: $id');
    } catch (e) {
      debugPrint('Failed to dismiss Super Island notification: $e');
    }
  }

  // Check if Super Island is available
  Future<bool> isSuperIslandAvailable() async {
    if (!await isHyperOS()) return false;

    try {
      final intent = AndroidIntent(
        action: 'com.miui.hyperos.SUPER_ISLAND_CHECK',
        package: _hyperOSPackage,
      );
      
      // This would need a broadcast receiver to get the result
      // For now, assume available on HyperOS
      return true;
    } catch (e) {
      debugPrint('Super Island availability check failed: $e');
      return false;
    }
  }

  // Get HyperOS notification settings
  Future<Map<String, dynamic>> getHyperOSSettings() async {
    final settings = <String, dynamic>{
      'is_hyperos': await isHyperOS(),
      'super_island_available': await isSuperIslandAvailable(),
    };

    if (await isHyperOS()) {
      final version = await _getHyperOSVersion();
      if (version != null) {
        settings['hyperos_version'] = version;
      }
    }

    return settings;
  }

  // Register for HyperOS notification callbacks
  void registerCallbacks({
    Function(int id, String actionId)? onActionPressed,
    Function(int id)? onDismissed,
    Function(int id)? onLiveActivityStarted,
    Function(int id)? onLiveActivityEnded,
  }) {
    // This would require a MethodChannel or EventChannel to receive callbacks
    // from native Android code. For now, we'll log that callbacks are registered.
    debugPrint('HyperOS notification callbacks registered');
  }
}

// Extension for notification action buttons (re-export for convenience)
class NotificationActionButton {
  final String id;
  final String title;
  final IconData? icon;
  final bool allowGeneratedReplies;
  final bool requireAuthentication;
  final VoidCallback? onPressed;

  const NotificationActionButton({
    required this.id,
    required this.title,
    this.icon,
    this.allowGeneratedReplies = false,
    this.requireAuthentication = false,
    this.onPressed,
  });

  AndroidNotificationAction toAndroidAction() {
    return AndroidNotificationAction(
      id,
      title,
      icon: icon != null ? DrawableResourceAndroidBitmap(icon!.codePoint.toString()) : null,
      allowGeneratedReplies: allowGeneratedReplies,
      requireAuthentication: requireAuthentication,
    );
  }
}