// HyperNotify Lab - HyperOS Screen
// Xiaomi HyperOS Super Island / Hyper Island testing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notification/hyperos_notification.dart';
import '../notification/notification_service.dart';
import '../model/notification_task.dart';
import '../utils/tablet_layout.dart';

class HyperOSScreen extends ConsumerStatefulWidget {
  const HyperOSScreen({super.key});

  @override
  ConsumerState<HyperOSScreen> createState() => _HyperOSScreenState();
}

class _HyperOSScreenState extends ConsumerState<HyperOSScreen> {
  final HyperOSNotification _hyperOSNotification = HyperOSNotification();
  
  Map<String, dynamic> _hyperOSSettings = {};
  bool _loading = true;
  bool _isHyperOS = false;
  String _hyperOSVersion = 'Unknown';
  
  // Test controllers
  final _titleController = TextEditingController(text: 'HyperOS Super Island');
  final _bodyController = TextEditingController(text: 'Testing HyperOS Super Island integration');
  int _notificationId = 2001;

  @override
  void initState() {
    super.initState();
    _loadHyperOSInfo();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadHyperOSInfo() async {
    setState(() => _loading = true);
    
    final isHyperOS = await _hyperOSNotification.isHyperOS();
    final settings = await _hyperOSNotification.getHyperOSSettings();
    
    setState(() {
      _isHyperOS = isHyperOS;
      _hyperOSSettings = settings;
      _hyperOSVersion = settings['hyperos_version'] as String? ?? 'Unknown';
      _loading = false;
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
                      'HyperOS Integration',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Test Xiaomi HyperOS Super Island / Hyper Island notifications',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadHyperOSInfo,
                tooltip: 'Refresh',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // HyperOS Status Card
          _buildStatusCard(),
          
          const SizedBox(height: 24),
          
          // Super Island Test
          _buildSuperIslandTestCard(),
          
          const SizedBox(height: 24),
          
          // Live Activity Test
          _buildLiveActivityCard(),
          
          const SizedBox(height: 24),
          
          // Advanced Settings
          _buildAdvancedSettingsCard(),
          
          const SizedBox(height: 24),
          
          // Raw Settings Display
          if (_hyperOSSettings.isNotEmpty) _buildRawSettingsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isHyperOS ? Icons.check_circle : Icons.cancel,
                  color: _isHyperOS ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  _isHyperOS ? 'HyperOS Detected' : 'HyperOS Not Detected',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isHyperOS ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('HyperOS Version', _hyperOSVersion),
            _buildInfoRow('Super Island Available', 
                _hyperOSSettings['super_island_available'] == true ? 'Yes' : 'Unknown'),
            _buildInfoRow('Package', 'com.miui.home'),
            _buildInfoRow('Action', 'com.miui.hyperos.SUPER_ISLAND'),
            
            const SizedBox(height: 16),
            
            if (!_isHyperOS)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This device does not appear to be running Xiaomi HyperOS. '
                        'Super Island notifications will fall back to standard high-priority notifications.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperIslandTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Super Island Notification Test',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                helperText: 'Super Island notification title',
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                helperText: 'Super Island notification body',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _notificationId.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Notification ID',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _notificationId = int.tryParse(v) ?? _notificationId,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send Super Island'),
                    onPressed: _sendSuperIslandNotification,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.update),
                    label: const Text('Update'),
                    onPressed: _updateSuperIslandNotification,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Dismiss'),
                    onPressed: _dismissSuperIslandNotification,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Activity Test',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Live activities are persistent, glanceable notifications that can show real-time updates.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.timer),
                    label: const Text('Start Live Activity (30s)'),
                    onPressed: _startLiveActivity,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced HyperOS Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFeatureChip(
                  'Dynamic Island Style',
                  Icons.circle,
                  () => _testDynamicIsland(),
                ),
                _buildFeatureChip(
                  'Persistent Banner',
                  Icons.view_agenda,
                  () => _testPersistentBanner(),
                ),
                _buildFeatureChip(
                  'Interactive Actions',
                  Icons.touch_app,
                  () => _testInteractiveActions(),
                ),
                _buildFeatureChip(
                  'Media Controls',
                  Icons.media_control,
                  () => _testMediaControls(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildRawSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raw Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              _hyperOSSettings.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
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

  // Action methods
  Future<void> _sendSuperIslandNotification() async {
    try {
      await NotificationService.instance.showHyperOSNotification(
        id: _notificationId,
        title: _titleController.text,
        body: _bodyController.text,
        actions: [
          NotificationActionButton(
            id: 'action_expand',
            title: 'Expand',
          ),
          NotificationActionButton(
            id: 'action_dismiss',
            title: 'Dismiss',
          ),
        ],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Super Island notification sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateSuperIslandNotification() async {
    try {
      await _hyperOSNotification.updateSuperIslandNotification(
        id: _notificationId,
        title: '${_titleController.text} (Updated)',
        body: '${_bodyController.text} - Updated at ${DateTime.now().toString().substring(11, 19)}',
        actions: [
          NotificationActionButton(
            id: 'action_expand',
            title: 'Expand',
          ),
        ],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Super Island notification updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _dismissSuperIslandNotification() async {
    try {
      await _hyperOSNotification.dismissSuperIslandNotification(_notificationId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Super Island notification dismissed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _startLiveActivity() async {
    try {
      await NotificationService.instance.showHyperOSNotification(
        id: _notificationId + 100,
        title: 'Live Activity',
        body: 'This is a live activity test - will auto-dismiss in 30 seconds',
        timeout: const Duration(seconds: 30),
        isLiveActivity: true,
        actions: [
          NotificationActionButton(
            id: 'action_stop',
            title: 'Stop',
          ),
        ],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live activity started (30s timeout)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _testDynamicIsland() async {
    await NotificationService.instance.showHyperOSNotification(
      id: 3001,
      title: 'Dynamic Island',
      body: 'Testing Dynamic Island style notification',
      actions: [
        NotificationActionButton(id: 'left', title: '←'),
        NotificationActionButton(id: 'center', title: '●'),
        NotificationActionButton(id: 'right', title: '→'),
      ],
    );
  }

  Future<void> _testPersistentBanner() async {
    await NotificationService.instance.showNotification(
      id: 3002,
      title: 'Persistent Banner',
      body: 'This notification stays visible as a banner',
      priority: NotificationPriority.high,
      channelId: NotificationService.channelIdHyperOS,
      ongoing: true,
    );
  }

  Future<void> _testInteractiveActions() async {
    await NotificationService.instance.showHyperOSNotification(
      id: 3003,
      title: 'Interactive Actions',
      body: 'Notification with multiple interactive buttons',
      actions: [
        NotificationActionButton(id: 'reply', title: 'Reply', allowGeneratedReplies: true),
        NotificationActionButton(id: 'like', title: '❤️ Like'),
        NotificationActionButton(id: 'share', title: '📤 Share'),
        NotificationActionButton(id: 'settings', title: '⚙️ Settings', requireAuthentication: true),
      ],
    );
  }

  Future<void> _testMediaControls() async {
    await NotificationService.instance.showNotification(
      id: 3004,
      title: 'Media Playback',
      body: 'HyperNotify Lab - Test Track',
      priority: NotificationPriority.high,
      channelId: NotificationService.channelIdHyperOS,
      ongoing: true,
      category: NotificationCategory.status,
      actions: [
        NotificationActionButton(id: 'prev', title: '⏮️ Previous'),
        NotificationActionButton(id: 'play', title: '⏯️ Play/Pause'),
        NotificationActionButton(id: 'next', title: '⏭️ Next'),
        NotificationActionButton(id: 'close', title: '✕ Close'),
      ],
    );
  }
}