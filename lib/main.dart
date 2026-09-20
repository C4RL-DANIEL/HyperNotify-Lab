// HyperNotify Lab - Xiaomi HyperOS Tablet Hyper Island Notification Tester
// Main entry point

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'notification/notification_service.dart';
import 'notification/hyperos_notification.dart';
import 'ui/main_screen.dart';
import 'ui/settings_screen.dart';
import 'model/notification_task.dart';
import 'service/foreground_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Initialize foreground service
  await ForegroundService.instance.initialize();

  // Check and request permissions
  await _requestPermissions();

  runApp(const HyperNotifyLabApp());
}

Future<void> _requestPermissions() async {
  // Request notification permission (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Request exact alarm permission for scheduled notifications (Android 12+)
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }

  // Request foreground service permissions
  if (await Permission.foregroundService.isDenied) {
    await Permission.foregroundService.request();
  }

  // Request foreground service data sync permission (Android 14+)
  if (await Permission.foregroundServiceDataSync.isDenied) {
    await Permission.foregroundServiceDataSync.request();
  }
}

class HyperNotifyLabApp extends StatefulWidget {
  const HyperNotifyLabApp({super.key});

  @override
  State<HyperNotifyLabApp> createState() => _HyperNotifyLabAppState();
}

class _HyperNotifyLabAppState extends State<HyperNotifyLabApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      _saveThemePreference(_themeMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperNotify Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006EFF),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006EFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: _themeMode,
      home: MainScreen(
        onThemeToggle: _toggleTheme,
        themeMode: _themeMode,
      ),
      routes: {
        '/settings': (context) => SettingsScreen(
              onThemeToggle: _toggleTheme,
              themeMode: _themeMode,
            ),
      },
    );
  }
}