// HyperNotify Lab - Main Screen
// Tablet-optimized UI for notification testing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../notification/notification_service.dart';
import '../notification/hyperos_notification.dart'
import '../model/notification_task.dart';
import '../service/foreground_service.dart';
import '../utils/tablet_layout.dart';
import 'settings_screen.dart';
import 'notification_test_screen.dart';
import 'hyperos_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const MainScreen({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  
  // Device info
  String _deviceInfo = 'Loading...';
  bool _isTablet = false;
  bool _isHyperOS = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final isHyperOS = await HyperOSNotification().isHyperOS();
    final isTablet = TabletLayout.isTablet(context);
    
    setState(() {
      _deviceInfo = '${deviceInfo.brand} ${deviceInfo.model} (Android ${deviceInfo.version.release}, API ${deviceInfo.version.sdkInt})';
      _isTablet = isTablet;
      _isHyperOS = isHyperOS;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = TabletLayout.isTablet(context);
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for tablet, bottom nav for phone
          if (isTablet)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              extended: MediaQuery.of(context).size.width > 800,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Test Notifications'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.developer_mode_outlined),
                  selectedIcon: Icon(Icons.developer_mode),
                  label: Text('HyperOS'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          
          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedIndex = index),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDashboard(),
                const NotificationTestScreen(),
                const HyperOSScreen(),
                SettingsScreen(
                  onThemeToggle: widget.onThemeToggle,
                  themeMode: widget.themeMode,
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Bottom navigation for phone
      bottomNavigationBar: isTablet ? null : NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Test',
          ),
          NavigationDestination(
            icon: Icon(Icons.developer_mode_outlined),
            selectedIcon: Icon(Icons.developer_mode),
            label: 'HyperOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: TabletLayout.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Device info card
          _buildDeviceInfoCard(),
          
          const SizedBox(height: 24),
          
          // Quick actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Recent notifications
          _buildRecentNotifications(),
          
          const SizedBox(height: 24),
          
          // Foreground service status
          _buildServiceStatus(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HyperNotify Lab',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Xiaomi HyperOS Tablet Hyper Island Notification Tester',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            widget.themeMode == ThemeMode.dark 
                ? Icons.light_mode 
                : Icons.dark_mode,
          ),
          onPressed: widget.onThemeToggle,
          tooltip: 'Toggle Theme',
        ),
      ],
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTablet ? Icons.tablet_mac : Icons.phone_android,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Device Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Device', _deviceInfo),
            _buildInfoRow('Form Factor', _isTablet ? 'Tablet' : 'Phone'),
            _buildInfoRow('HyperOS', _isHyperOS ? 'Detected ✓' : 'Not Detected'),
            _buildInfoRow('Foreground Service', 
                ForegroundService.instance.isRunning ? 'Running' : 'Stopped'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionCard(
              'Show Test Notification',
              Icons.notifications_active,
              () => _showQuickNotification(),
            ),
            _buildActionCard(
              'HyperOS Super Island',
              Icons.developer_mode,
              () => _showHyperOSNotification(),
            ),
            _buildActionCard(
              'Multiple Notifications',
              Icons.notifications,
              () => _showMultipleNotifications(),
            ),
            _buildActionCard(
              'Scheduled (1 min)',
              Icons.schedule,
              () => _scheduleNotification(),
            ),
            _buildActionCard(
              'Start Foreground Service',
              Icons.play_circle,
              () => _toggleForegroundService(true),
            ),
            _buildActionCard(
              'Stop Foreground Service',
              Icons.stop_circle,
              () => _toggleForegroundService(false),
            ),
            _buildActionCard(
              'Clear All',
              Icons.clear_all,
              () => _clearAllNotifications(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: TabletLayout.isTablet(context) ? 200 : double.infinity,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _refreshActiveNotifications,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<ActiveNotification>>(
          future: NotificationService.instance.getActiveNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            
            final notifications = snapshot.data ?? [];
            
            if (notifications.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No active notifications',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${n.id}'),
                    ),
                    title: Text(n.title ?? 'No title'),
                    subtitle: Text(n.body ?? 'No body'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => NotificationService.instance.cancelNotification(n.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceStatus() {
    return StreamBuilder<ForegroundServiceStatus>(
      stream: ForegroundService.instance.statusStream,
      initialData: ForegroundServiceStatus.stopped,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ForegroundServiceStatus.stopped;
        final isRunning = status == ForegroundServiceStatus.running;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isRunning ? Icons.play_circle_filled : Icons.stop_circle,
                      color: isRunning ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Foreground Service',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRunning ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.name.toUpperCase(),
                        style: TextStyle(
                          color: isRunning ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isRunning ? null : () => _toggleForegroundService(true),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: !isRunning ? null : () => _toggleForegroundService(false),
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Action methods
  Future<void> _showQuickNotification() async {
    await NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notification',
      body: 'This is a test notification from HyperNotify Lab',
      priority: NotificationPriority.high,
      actions: [
        NotificationActionButton(
          id: 'action_view',
          title: 'View',
        ),
        NotificationActionButton(
          id: 'action_dismiss',
          title: 'Dismiss',
        ),
      ],
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent')),
      );
    }
  }

  Future<void> _showHyperOSNotification() async {
    await NotificationService.instance.showHyperOSNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'HyperOS Super Island',
      body: 'Testing Xiaomi HyperOS Super Island integration',
      actions: [
        NotificationActionButton(
          id: 'action_expand',
          title: 'Expand',
        ),
        NotificationActionButton(
          id: 'action_settings',
          title: 'Settings',
        ),
      ],
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HyperOS notification sent')),
      );
    }
  }

  Future<void> _showMultipleNotifications() async {
    final tasks = NotificationTemplates.getAllTestNotifications();
    await NotificationService.instance.showMultipleNotifications(tasks: tasks);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tasks.length} notifications sent')),
      );
    }
  }

  Future<void> _scheduleNotification() async {
    await NotificationService.instance.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Scheduled Notification',
      body: 'This notification was scheduled for 1 minute from now',
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
      priority: NotificationPriority.high,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification scheduled for 1 minute')),
      );
    }
  }

  Future<void> _toggleForegroundService(bool start) async {
    if (start) {
      final success = await ForegroundService.instance.start();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Foreground service started' : 'Failed to start service'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } else {
      await ForegroundService.instance.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foreground service stopped')),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    await NotificationService.instance.cancelAllNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    }
  }

  Future<void> _refreshActiveNotifications() async {
    setState(() {});
  }
}