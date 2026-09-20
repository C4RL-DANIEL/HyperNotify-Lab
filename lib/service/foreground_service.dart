// HyperNotify Lab - Foreground Service
// Manages background execution and ongoing notifications

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:workmanager/workmanager.dart';

import '../notification/notification_service.dart';
import '../model/notification_task.dart';

class ForegroundService {
  ForegroundService._internal();
  static final ForegroundService _instance = ForegroundService._internal();
  static ForegroundService get instance => _instance;

  static const String _serviceChannelId = 'hypernotify_foreground';
  static const int _serviceNotificationId = 9999;

  bool _isRunning = false;
  bool _initialized = false;
  StreamController<ForegroundServiceStatus>? _statusController;
  Timer? _keepAliveTimer;

  bool get isRunning => _isRunning;
  bool get isInitialized => _initialized;

  Stream<ForegroundServiceStatus> get statusStream {
    _statusController ??= StreamController<ForegroundServiceStatus>.broadcast();
    return _statusController!.stream;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Create foreground service notification channel
    await _createForegroundChannel();

    // Initialize WorkManager for background tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    _initialized = true;
    debugPrint('ForegroundService initialized');
  }

  Future<void> _createForegroundChannel() async {
    final androidPlugin = 
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _serviceChannelId,
          'Foreground Service',
          description: 'Ongoing notification for HyperNotify Lab foreground service',
          importance: Importance.low,
          priority: Priority.low,
          enableVibration: false,
          playSound: false,
          ongoing: true,
          lockscreenVisibility: NotificationVisibility.secret,
        ),
      );
    }
  }

  // Start the foreground service
  Future<bool> start({
    String title = 'HyperNotify Lab',
    String body = 'Running in background',
    String? payload,
  }) async {
    if (_isRunning) {
      debugPrint('Foreground service already running');
      return true;
    }

    // Request foreground service permissions
    final hasPermissions = await _requestPermissions();
    if (!hasPermissions) {
      debugPrint('Foreground service permissions not granted');
      _statusController?.add(ForegroundServiceStatus.permissionDenied);
      return false;
    }

    try {
      // Show the ongoing notification
      await _showServiceNotification(title, body, payload);

      // Register periodic task for keep-alive
      await _registerKeepAliveTask();

      _isRunning = true;
      _statusController?.add(ForegroundServiceStatus.running);
      debugPrint('Foreground service started');
      return true;
    } catch (e) {
      debugPrint('Failed to start foreground service: $e');
      _statusController?.add(ForegroundServiceStatus.error(e.toString()));
      return false;
    }
  }

  // Stop the foreground service
  Future<void> stop() async {
    if (!_isRunning) return;

    try {
      // Cancel the service notification
      await flutterLocalNotificationsPlugin.cancel(_serviceNotificationId);

      // Cancel periodic tasks
      await Workmanager().cancelAll();

      // Cancel keep-alive timer
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;

      _isRunning = false;
      _statusController?.add(ForegroundServiceStatus.stopped);
      debugPrint('Foreground service stopped');
    } catch (e) {
      debugPrint('Error stopping foreground service: $e');
      _statusController?.add(ForegroundServiceStatus.error(e.toString()));
    }
  }

  // Update the service notification
  Future<void> updateNotification({
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_isRunning) return;

    await _showServiceNotification(
      title ?? 'HyperNotify Lab',
      body ?? 'Running in background',
      payload,
    );
  }

  Future<void> _showServiceNotification(String title, String body, String? payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _serviceChannelId,
      'Foreground Service',
      channelDescription: 'Ongoing notification for HyperNotify Lab foreground service',
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
      playSound: false,
      ongoing: true,
      autoCancel: false,
      lockscreenVisibility: NotificationVisibility.secret,
      category: AndroidNotificationCategory.service,
      color: Color(0xFF006EFF),
      colorized: true,
      showWhen: false,
      usesChronometer: true,
      chronometerCountDown: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      _serviceNotificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Android 14+ requires specific foreground service permissions
    if (sdkInt >= 34) {
      final status = await Permission.foregroundServiceDataSync.request();
      if (!status.isGranted) {
        debugPrint('Foreground service data sync permission denied');
        return false;
      }
    }

    // Android 12+ requires foreground service permission
    if (sdkInt >= 31) {
      final status = await Permission.foregroundService.request();
      if (!status.isGranted) {
        debugPrint('Foreground service permission denied');
        return false;
      }
    }

    // Notification permission (Android 13+)
    if (sdkInt >= 33) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        debugPrint('Notification permission denied');
        return false;
      }
    }

    return true;
  }

  Future<void> _registerKeepAliveTask() async {
    // Register a periodic task to keep the service alive
    await Workmanager().registerPeriodicTask(
      'hypernotify_keep_alive',
      'keepAliveTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
    );
  }

  // Schedule a notification via WorkManager
  Future<void> scheduleNotificationTask(NotificationTask task) async {
    if (task.scheduledTime == null) return;

    final delay = task.scheduledTime!.difference(DateTime.now());
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      'hypernotify_scheduled_${task.id}',
      'scheduledNotificationTask',
      initialDelay: delay,
      inputData: task.toJson(),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );
  }

  // Cancel a scheduled notification task
  Future<void> cancelScheduledTask(int taskId) async {
    await Workmanager().cancelByUniqueName('hypernotify_scheduled_$taskId');
  }
}

// Foreground service status enum
enum ForegroundServiceStatus {
  stopped,
  running,
  permissionDenied,
  error,
}

// WorkManager callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background task executed: $task');
    
    switch (task) {
      case 'keepAliveTask':
        // Keep-alive task - just ping to keep service alive
        debugPrint('Keep-alive task executed');
        break;
        
      case 'scheduledNotificationTask':
        // Show scheduled notification
        if (inputData != null) {
          final task = NotificationTask.fromJson(Map<String, dynamic>.from(inputData));
          await NotificationService.instance.showNotification(
            id: task.id,
            title: task.title,
            body: task.body,
            payload: task.payload,
            priority: task.priority,
            category: task.category,
            ongoing: task.ongoing,
            actions: task.actions,
          );
          
          // Re-schedule if repeating
          if (task.isRepeating && task.repeatInterval != null) {
            await _rescheduleRepeatingTask(task);
          }
        }
        break;
    }
    
    return Future.value(true);
  });
}

// Reschedule repeating task
Future<void> _rescheduleRepeatingTask(NotificationTask task) async {
  Duration delay;
  switch (task.repeatInterval) {
    case RepeatInterval.everyMinute:
      delay = const Duration(minutes: 1);
      break;
    case RepeatInterval.everyHour:
      delay = const Duration(hours: 1);
      break;
    case RepeatInterval.everyDay:
      delay = const Duration(days: 1);
      break;
    case RepeatInterval.everyWeek:
      delay = const Duration(days: 7);
      break;
    case RepeatInterval.everyMonth:
      delay = const Duration(days: 30);
      break;
    case RepeatInterval.custom:
      delay = const Duration(hours: 1);
      break;
    default:
      delay = const Duration(hours: 1);
  }

  final nextTime = DateTime.now().add(delay);
  final nextTask = task.copyWith(scheduledTime: nextTime);
  
  await Workmanager().registerOneOffTask(
    'hypernotify_scheduled_${task.id}',
    'scheduledNotificationTask',
    initialDelay: delay,
    inputData: nextTask.toJson(),
  );
}