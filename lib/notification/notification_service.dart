// HyperNotify Lab - Core Notification Service
// Handles all notification operations with Android 16 and HyperOS support

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'hyperos_notification.dart';
import '../model/notification_task.dart';

// Initialize timezone data
void initializeTimeZones() {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final HyperOSNotification _hyperOSNotification = HyperOSNotification();

  bool _initialized = false;
  bool _channelsCreated = false;

  // Notification channel IDs
  static const String channelIdDefault = 'hypernotify_default';
  static const String channelIdHigh = 'hypernotify_high';
  static const String channelIdCritical = 'hypernotify_critical';
  static const String channelIdHyperOS = 'hypernotify_hyperos';
  static const String channelIdTest = 'hypernotify_test';

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    initializeTimeZones();

    // Initialize Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  Future<void> _createNotificationChannels() async {
    if (_channelsCreated) return;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Default channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIdDefault,
        'Default Notifications',
        description: 'Standard notifications for HyperNotify Lab',
        importance: Importance.defaultImportance,
        enableVibration: true,
        playSound: true,
      ),
    );

    // High priority channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIdHigh,
        'High Priority Notifications',
        description: 'High priority notifications with sound and vibration',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Color(0xFF006EFF),
      ),
    );

    // Critical channel (for Android 16+)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIdCritical,
        'Critical Notifications',
        description: 'Critical notifications that bypass Do Not Disturb',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Color(0xFFFF0000),
        lockscreenVisibility: NotificationVisibility.public,
        bypassDnd: true,
      ),
    );

    // HyperOS specific channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIdHyperOS,
        'HyperOS Island Notifications',
        description: 'Notifications optimized for Xiaomi HyperOS Super Island',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: Color(0xFF006EFF),
        lockscreenVisibility: NotificationVisibility.public,
      ),
    );

    // Test channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        channelIdTest,
        'Test Notifications',
        description: 'Test notifications for development',
        importance: Importance.defaultImportance,
        enableVibration: false,
        playSound: false,
      ),
    );

    _channelsCreated = true;
    debugPrint('Notification channels created');
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to relevant screen
  }

  // Show a standard notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    NotificationCategory category = NotificationCategory.defaultCategory,
    String? channelId,
    bool ongoing = false,
    List<NotificationActionButton>? actions,
    BigTextStyleInformation? bigTextStyle,
    BigPictureStyleInformation? bigPictureStyle,
  }) async {
    if (!_initialized) await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId ?? _getChannelIdForPriority(priority),
      _getChannelNameForPriority(priority),
      channelDescription: _getChannelDescriptionForPriority(priority),
      importance: _getImportanceForPriority(priority),
      priority: _getPriorityForPriority(priority),
      enableVibration: priority != NotificationPriority.low,
      playSound: priority != NotificationPriority.low,
      ongoing: ongoing,
      autoCancel: !ongoing,
      actions: actions?.map((a) => a.toAndroidAction()).toList(),
      styleInformation: bigTextStyle ?? bigPictureStyle,
      category: _getCategoryForCategory(category),
      visibility: priority == NotificationPriority.critical
          ? NotificationVisibility.public
          : NotificationVisibility.private,
      // Android 16+ features
      showWhen: true,
      useChronometer: false,
      chronometerCountDown: false,
      // HyperOS specific
      color: const Color(0xFF006EFF),
      colorized: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show a HyperOS Super Island notification
  Future<void> showHyperOSNotification({
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
    if (!_initialized) await initialize();

    // Check if running on Xiaomi HyperOS
    final isHyperOS = await _hyperOSNotification.isHyperOS();
    
    if (isHyperOS) {
      await _hyperOSNotification.showSuperIslandNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        iconUrl: iconUrl,
        largeIconUrl: largeIconUrl,
        actions: actions,
        timeout: timeout,
        isLiveActivity: isLiveActivity,
      );
    } else {
      // Fallback to standard high priority notification
      await showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        priority: NotificationPriority.high,
        channelId: channelIdHyperOS,
        actions: actions,
      );
    }
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    String? channelId,
    bool exact = true,
  }) async {
    if (!_initialized) await initialize();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId ?? _getChannelIdForPriority(priority),
      _getChannelNameForPriority(priority),
      channelDescription: _getChannelDescriptionForPriority(priority),
      importance: _getImportanceForPriority(priority),
      priority: _getPriorityForPriority(priority),
      enableVibration: priority != NotificationPriority.low,
      playSound: priority != NotificationPriority.low,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: null,
    );
  }

  // Show multiple notifications at once (for testing)
  Future<void> showMultipleNotifications({
    required List<NotificationTask> tasks,
  }) async {
    for (final task in tasks) {
      await Future.delayed(const Duration(milliseconds: 100));
      await showNotification(
        id: task.id,
        title: task.title,
        body: task.body,
        payload: task.payload,
        priority: task.priority,
        category: task.category,
        ongoing: task.ongoing,
        actions: task.actions,
      );
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get active notifications (Android 16+)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return [];

    try {
      final List<ActiveNotification>? notifications =
          await androidPlugin.getActiveNotifications();
      return notifications ?? [];
    } catch (e) {
      debugPrint('Error getting active notifications: $e');
      return [];
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    // Android 13+
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
    }
    return true;
  }

  // Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      return status.isGranted;
    }
    return true;
  }

  // Check if we can schedule exact alarms
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 31) {
        return await Permission.scheduleExactAlarm.isGranted;
      }
      return true;
    }
    return true;
  }

  // Get channel ID for priority
  String _getChannelIdForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return channelIdCritical;
      case NotificationPriority.high:
        return channelIdHigh;
      case NotificationPriority.low:
        return channelIdTest;
      default:
        return channelIdDefault;
    }
  }

  String _getChannelNameForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'Critical Notifications';
      case NotificationPriority.high:
        return 'High Priority Notifications';
      case NotificationPriority.low:
        return 'Test Notifications';
      default:
        return 'Default Notifications';
    }
  }

  String _getChannelDescriptionForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'Critical notifications that bypass Do Not Disturb';
      case NotificationPriority.high:
        return 'High priority notifications with sound and vibration';
      case NotificationPriority.low:
        return 'Test notifications for development';
      default:
        return 'Standard notifications for HyperNotify Lab';
    }
  }

  Importance _getImportanceForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriorityForPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  AndroidNotificationCategory _getCategoryForCategory(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.message:
        return AndroidNotificationCategory.msg;
      case NotificationCategory.call:
        return AndroidNotificationCategory.call;
      case NotificationCategory.email:
        return AndroidNotificationCategory.email;
      case NotificationCategory.event:
        return AndroidNotificationCategory.event;
      case NotificationCategory.promo:
        return AndroidNotificationCategory.promo;
      case NotificationCategory.recommendation:
        return AndroidNotificationCategory.recommendation;
      case NotificationCategory.service:
        return AndroidNotificationCategory.service;
      case NotificationCategory.social:
        return AndroidNotificationCategory.social;
      case NotificationCategory.status:
        return AndroidNotificationCategory.status;
      case NotificationCategory.system:
        return AndroidNotificationCategory.sys;
      case NotificationCategory.transport:
        return AndroidNotificationCategory.transport;
      default:
        return AndroidNotificationCategory.uncategorized;
    }
  }
}

// Extension for notification action buttons
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

// Notification priority enum
enum NotificationPriority {
  low,
  defaultPriority,
  high,
  critical,
}

// Notification category enum
enum NotificationCategory {
  defaultCategory,
  message,
  call,
  email,
  event,
  promo,
  recommendation,
  service,
  social,
  status,
  system,
  transport,
}

// Active notification model
class ActiveNotification {
  final int id;
  final String? title;
  final String? body;
  final String? packageName;
  final DateTime? postedTime;

  ActiveNotification({
    required this.id,
    this.title,
    this.body,
    this.packageName,
    this.postedTime,
  });
}