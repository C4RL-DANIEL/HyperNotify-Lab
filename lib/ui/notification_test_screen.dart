// HyperNotify Lab - Notification Test Screen
// Comprehensive notification testing interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notification/notification_service.dart';
import '../model/notification_task.dart';
import '../utils/tablet_layout.dart';

class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends ConsumerState<NotificationTestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController(text: 'Test Notification');
  final _bodyController = TextEditingController(text: 'This is a test notification body');
  final _payloadController = TextEditingController();
  
  // Selected values
  NotificationPriority _selectedPriority = NotificationPriority.defaultPriority;
  NotificationCategory _selectedCategory = NotificationCategory.defaultCategory;
  String _selectedChannelId = NotificationService.channelIdDefault;
  bool _ongoing = false;
  bool _bigTextStyle = false;
  int _notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  
  // Action controllers
  final List<NotificationActionButton> _actions = [];
  final _actionIdController = TextEditingController();
  final _actionTitleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _payloadController.dispose();
    _actionIdController.dispose();
    _actionTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: TabletLayout.getResponsivePadding(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Notification Test Lab',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create and send custom notifications with full Android 16 / HyperOS support',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Basic settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notification ID
                    TextFormField(
                      initialValue: _notificationId.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Notification ID',
                        helperText: 'Unique identifier for the notification',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a notification ID';
                        }
                        return null;
                      },
                      onSaved: (value) => _notificationId = int.tryParse(value!) ?? _notificationId,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        helperText: 'Notification title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Body
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Body *',
                        helperText: 'Notification body text',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a body';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Payload
                    TextFormField(
                      controller: _payloadController,
                      decoration: const InputDecoration(
                        labelText: 'Payload (Optional)',
                        helperText: 'Data passed when notification is tapped',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Priority & Category
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority & Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Priority
                    DropdownButtonFormField<NotificationPriority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        helperText: 'Determines importance and behavior',
                      ),
                      items: NotificationPriority.values.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(_getPriorityLabel(p)),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedPriority = value!),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category
                    DropdownButtonFormField<NotificationCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        helperText: 'Notification category for system sorting',
                      ),
                      items: NotificationCategory.values.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_getCategoryLabel(c)),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Channel
                    DropdownButtonFormField<String>(
                      value: _selectedChannelId,
                      decoration: const InputDecoration(
                        labelText: 'Channel',
                        helperText: 'Notification channel to use',
                      ),
                      items: [
                        NotificationService.channelIdDefault,
                        NotificationService.channelIdHigh,
                        NotificationService.channelIdCritical,
                        NotificationService.channelIdHyperOS,
                        NotificationService.channelIdTest,
                      ].map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(_getChannelLabel(c)),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedChannelId = value!),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ongoing toggle
                    SwitchListTile(
                      title: const Text('Ongoing Notification'),
                      subtitle: const Text('Cannot be dismissed by user (foreground service style)'),
                      value: _ongoing,
                      onChanged: (value) => setState(() => _ongoing = value),
                    ),
                    
                    // Big text style toggle
                    SwitchListTile(
                      title: const Text('Big Text Style'),
                      subtitle: const Text('Expandable long text content'),
                      value: _bigTextStyle,
                      onChanged: (value) => setState(() => _bigTextStyle = value),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Action Buttons',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addAction,
                          tooltip: 'Add Action',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    if (_actions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No actions added. Tap + to add action buttons.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _actions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final action = _actions[index];
                          return Card(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: ListTile(
                              leading: const Icon(Icons.touch_app),
                              title: Text(action.title),
                              subtitle: Text('ID: ${action.id}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (action.allowGeneratedReplies)
                                    Chip(
                                      label: const Text('Reply'),
                                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    ),
                                  if (action.requireAuthentication)
                                    Chip(
                                      label: const Text('Auth'),
                                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _removeAction(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    
                    // Add action form
                    if (_showAddActionForm)
                      _buildAddActionForm(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick templates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Templates',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: NotificationTemplates.getAllTestNotifications().map((task) {
                        return ActionChip(
                          label: Text(task.title),
                          onPressed: () => _loadTemplate(task),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Send buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Send Now'),
                    onPressed: _sendNotification,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule (1 min)'),
                    onPressed: _scheduleNotification,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.notifications),
                    label: const Text('Send All Templates'),
                    onPressed: _sendAllTemplates,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    onPressed: _clearAllNotifications,
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

  bool _showAddActionForm = false;

  Widget _buildAddActionForm() {
    return Column(
      children: [
        const Divider(),
        TextFormField(
          controller: _actionIdController,
          decoration: const InputDecoration(
            labelText: 'Action ID *',
            helperText: 'Unique identifier for this action',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _actionTitleController,
          decoration: const InputDecoration(
            labelText: 'Action Title *',
            helperText: 'Text shown on the button',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Allow Generated Replies'),
                value: _allowGeneratedReplies,
                onChanged: (v) => setState(() => _allowGeneratedReplies = v ?? false),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Require Authentication'),
                value: _requireAuthentication,
                onChanged: (v) => setState(() => _requireAuthentication = v ?? false),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _confirmAddAction,
                child: const Text('Add Action'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _showAddActionForm = false),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _allowGeneratedReplies = false;
  bool _requireAuthentication = false;

  void _addAction() {
    setState(() {
      _showAddActionForm = true;
      _actionIdController.clear();
      _actionTitleController.clear();
      _allowGeneratedReplies = false;
      _requireAuthentication = false;
    });
  }

  void _confirmAddAction() {
    if (_actionIdController.text.isEmpty || _actionTitleController.text.isEmpty) return;
    
    setState(() {
      _actions.add(NotificationActionButton(
        id: _actionIdController.text,
        title: _actionTitleController.text,
        allowGeneratedReplies: _allowGeneratedReplies,
        requireAuthentication: _requireAuthentication,
      ));
      _showAddActionForm = false;
      _actionIdController.clear();
      _actionTitleController.clear();
    });
  }

  void _removeAction(int index) {
    setState(() => _actions.removeAt(index));
  }

  void _loadTemplate(NotificationTask task) {
    setState(() {
      _notificationId = task.id;
      _titleController.text = task.title;
      _bodyController.text = task.body;
      _payloadController.text = task.payload ?? '';
      _selectedPriority = task.priority;
      _selectedCategory = task.category;
      _selectedChannelId = task.channelId ?? NotificationService.channelIdDefault;
      _ongoing = task.ongoing;
      _bigTextStyle = task.bigTextStyle != null;
      _actions.clear();
      if (task.actions != null) {
        _actions.addAll(task.actions!);
      }
    });
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    BigTextStyleInformation? bigText;
    if (_bigTextStyle) {
      bigText = BigTextStyleInformation(
        _bodyController.text,
        htmlFormatBigText: true,
        htmlFormatTitle: true,
        contentTitle: _titleController.text,
        summaryText: 'Tap to expand',
      );
    }

    await NotificationService.instance.showNotification(
      id: _notificationId,
      title: _titleController.text,
      body: _bodyController.text,
      payload: _payloadController.text.isEmpty ? null : _payloadController.text,
      priority: _selectedPriority,
      category: _selectedCategory,
      channelId: _selectedChannelId,
      ongoing: _ongoing,
      actions: _actions.isEmpty ? null : _actions,
      bigTextStyle: bigText,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent!')),
      );
    }
  }

  Future<void> _scheduleNotification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await NotificationService.instance.scheduleNotification(
      id: _notificationId,
      title: _titleController.text,
      body: _bodyController.text,
      scheduledDate: DateTime.now().add(const Duration(minutes: 1)),
      payload: _payloadController.text.isEmpty ? null : _payloadController.text,
      priority: _selectedPriority,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification scheduled for 1 minute')),
      );
    }
  }

  Future<void> _sendAllTemplates() async {
    final tasks = NotificationTemplates.getAllTestNotifications();
    await NotificationService.instance.showMultipleNotifications(tasks: tasks);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tasks.length} template notifications sent')),
      );
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

  String _getPriorityLabel(NotificationPriority p) {
    switch (p) {
      case NotificationPriority.low: return 'Low';
      case NotificationPriority.defaultPriority: return 'Default';
      case NotificationPriority.high: return 'High';
      case NotificationPriority.critical: return 'Critical (bypasses DND)';
    }
  }

  String _getCategoryLabel(NotificationCategory c) {
    switch (c) {
      case NotificationCategory.defaultCategory: return 'Default';
      case NotificationCategory.message: return 'Message';
      case NotificationCategory.call: return 'Call';
      case NotificationCategory.email: return 'Email';
      case NotificationCategory.event: return 'Event';
      case NotificationCategory.promo: return 'Promo';
      case NotificationCategory.recommendation: return 'Recommendation';
      case NotificationCategory.service: return 'Service';
      case NotificationCategory.social: return 'Social';
      case NotificationCategory.status: return 'Status';
      case NotificationCategory.system: return 'System';
      case NotificationCategory.transport: return 'Transport';
    }
  }

  String _getChannelLabel(String c) {
    switch (c) {
      case NotificationService.channelIdDefault: return 'Default';
      case NotificationService.channelIdHigh: return 'High Priority';
      case NotificationService.channelIdCritical: return 'Critical';
      case NotificationService.channelIdHyperOS: return 'HyperOS';
      case NotificationService.channelIdTest: return 'Test';
      default: return c;
    }
  }
}