// HyperNotify Lab - Settings Screen
// App settings and preferences

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notification/notification_service.dart';
import '../service/foreground_service.dart';
import '../utils/tablet_layout.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _foregroundServiceEnabled = false;
  String _defaultPriority = 'default';
  String _themeMode = 'system';
  
  // Permissions status
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  
  // Device info
  String _deviceInfo = '';
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermissions();
    _loadDeviceInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _foregroundServiceEnabled = prefs.getBool('foreground_service_enabled') ?? false;
      _defaultPriority = prefs.getString('default_priority') ?? 'default';
      _themeMode = prefs.getString('theme_mode') ?? 'system';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setBool('foreground_service_enabled', _foregroundServiceEnabled);
    await prefs.setString('default_priority', _defaultPriority);
    await prefs.setString('theme_mode', _themeMode);
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.foregroundService,
      Permission.foregroundServiceDataSync,
    ];
    
    final statuses = await Future.wait(
      permissions.map((p) => p.status),
    );
    
    setState(() {
      _permissionStatuses = Map.fromIterables(permissions, statuses);
    });
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    setState(() {
      _deviceInfo = '${deviceInfo.brand} ${deviceInfo.model}\n'
          'Android ${deviceInfo.version.release} (API ${deviceInfo.version.sdkInt})\n'
          'Manufacturer: ${deviceInfo.manufacturer}\n'
          'Board: ${deviceInfo.board}\n'
          'Hardware: ${deviceInfo.hardware}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: TabletLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Configure HyperNotify Lab behavior and preferences',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _themeMode == 'dark' 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: _toggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Notifications section
          _buildSection(
            'Notifications',
            Icons.notifications,
            [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Allow app to show notifications'),
                value: _notificationsEnabled,
                onChanged: (value) => setState(() {
                  _notificationsEnabled = value;
                  _saveSettings();
                }),
              ),
              SwitchListTile(
                title: const Text('Sound'),
                subtitle: const Text('Play sound with notifications'),
                value: _soundEnabled,
                onChanged: _notificationsEnabled ? (value) => setState(() {
                  _soundEnabled = value;
                  _saveSettings();
                }) : null,
              ),
              SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate on notifications'),
                value: _vibrationEnabled,
                onChanged: _notificationsEnabled ? (value) => setState(() {
                  _vibrationEnabled = value;
                  _saveSettings();
                }) : null,
              ),
              ListTile(
                title: const Text('Default Priority'),
                subtitle: Text(_getPriorityLabel(_defaultPriority)),
                trailing: DropdownButton<String>(
                  value: _defaultPriority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'default', child: Text('Default')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (value) => setState(() {
                    _defaultPriority = value!;
                    _saveSettings();
                  }),
                  underline: const SizedBox(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Foreground Service section
          _buildSection(
            'Foreground Service',
            Icons.play_circle,
            [
              SwitchListTile(
                title: const Text('Enable Foreground Service'),
                subtitle: const Text('Keep service running in background with ongoing notification'),
                value: _foregroundServiceEnabled,
                onChanged: (value) async {
                  if (value) {
                    final success = await ForegroundService.instance.start();
                    if (success) {
                      setState(() {
                        _foregroundServiceEnabled = true;
                      });
                      _saveSettings();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to start foreground service. Check permissions.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    await ForegroundService.instance.stop();
                    setState(() {
                      _foregroundServiceEnabled = false;
                    });
                    _saveSettings();
                  }
                },
              ),
              ListTile(
                title: const Text('Service Status'),
                subtitle: Text(ForegroundService.instance.isRunning ? 'Running' : 'Stopped'),
                trailing: ForegroundService.instance.isRunning
                    ? FilledButton(
                        onPressed: () async {
                          await ForegroundService.instance.stop();
                          setState(() {
                            _foregroundServiceEnabled = false;
                          });
                          _saveSettings();
                        },
                        child: const Text('Stop'),
                      )
                    : FilledButton(
                        onPressed: () async {
                          final success = await ForegroundService.instance.start();
                          if (success) {
                            setState(() {
                              _foregroundServiceEnabled = true;
                            });
                            _saveSettings();
                          }
                        },
                        child: const Text('Start'),
                      ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Theme section
          _buildSection(
            'Appearance',
            Icons.palette,
            [
              ListTile(
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeLabel(_themeMode)),
                trailing: DropdownButton<String>(
                  value: _themeMode,
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  onChanged: (value) => setState(() {
                    _themeMode = value!;
                    _saveSettings();
                  }),
                  underline: const SizedBox(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Permissions section
          _buildSection(
            'Permissions',
            Icons.security,
            [
              ..._permissionStatuses.entries.map((entry) {
                return ListTile(
                  leading: Icon(
                    entry.value.isGranted ? Icons.check_circle : Icons.cancel,
                    color: entry.value.isGranted ? Colors.green : Colors.red,
                  ),
                  title: Text(_getPermissionLabel(entry.key)),
                  subtitle: Text(_getPermissionStatusLabel(entry.value)),
                  trailing: entry.value.isGranted
                      ? null
                      : TextButton(
                          onPressed: () async {
                            await entry.key.request();
                            _checkPermissions();
                          },
                          child: const Text('Grant'),
                        ),
                );
              }),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open App Settings'),
                subtitle: const Text('Manage all permissions in system settings'),
                onTap: () => openAppSettings(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Device Info section
          _buildSection(
            'Device Information',
            Icons.info,
            [
              ListTile(
                title: const Text('Device Details'),
                subtitle: Text(_deviceInfo),
                isThreeLine: true,
              ),
              ListTile(
                title: const Text('App Version'),
                subtitle: Text(_appVersion),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Actions section
          _buildSection(
            'Actions',
            Icons.build,
            [
              ListTile(
                leading: const Icon(Icons.clear_all),
                title: const Text('Clear All Notifications'),
                onTap: () async {
                  await NotificationService.instance.cancelAllNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All notifications cleared')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Send Test Notification'),
                onTap: () async {
                  await NotificationService.instance.showNotification(
                    id: 9999,
                    title: 'Settings Test',
                    body: 'Test notification from settings screen',
                    priority: NotificationPriority.high,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Permissions'),
                onTap: _checkPermissions,
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('View Source Code'),
                onTap: () => _launchUrl('https://github.com/C4RL-DANIEL/HyperNotify-Lab'),
              ),
              ListTile(
                leading: const Icon(Icons.report_problem),
                title: const Text('Report Issue'),
                onTap: () => _launchUrl('https://github.com/C4RL-DANIEL/HyperNotify-Lab/issues'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // About section
          _buildSection(
            'About',
            Icons.info_outline,
            [
              ListTile(
                title: const Text('HyperNotify Lab'),
                subtitle: const Text('Version 1.0.0\nXiaomi HyperOS Tablet Hyper Island Notification Tester'),
                isThreeLine: true,
              ),
              ListTile(
                title: const Text('License'),
                subtitle: const Text('MIT License'),
                onTap: () => _launchUrl('https://opensource.org/licenses/MIT'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'low': return 'Low';
      case 'default': return 'Default';
      case 'high': return 'High';
      case 'critical': return 'Critical (bypasses DND)';
      default: return priority;
    }
  }

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'system': return 'Follow System';
      case 'light': return 'Light';
      case 'dark': return 'Dark';
      default: return mode;
    }
  }

  String _getPermissionLabel(Permission permission) {
    switch (permission) {
      case Permission.notification: return 'Notifications';
      case Permission.scheduleExactAlarm: return 'Exact Alarms (Scheduling)';
      case Permission.foregroundService: return 'Foreground Service';
      case Permission.foregroundServiceDataSync: return 'Foreground Service Data Sync';
      default: return permission.toString().split('.').last;
    }
  }

  String _getPermissionStatusLabel(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted: return 'Granted';
      case PermissionStatus.denied: return 'Denied';
      case PermissionStatus.permanentlyDenied: return 'Permanently Denied';
      case PermissionStatus.restricted: return 'Restricted';
      case PermissionStatus.limited: return 'Limited';
      case PermissionStatus.provisional: return 'Provisional';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == 'dark' ? 'light' : 'dark';
      _saveSettings();
    });
  }
}