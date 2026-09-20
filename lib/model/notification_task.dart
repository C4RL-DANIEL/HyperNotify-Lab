// HyperNotify Lab - Notification Task Models
// Defines data structures for notification tasks and scheduling

import 'package:flutter/material.dart';
import '../notification/notification_service.dart';

/// Represents a notification task that can be scheduled or sent immediately
class NotificationTask {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final NotificationPriority priority;
  final NotificationCategory category;
  final bool ongoing;
  final List<NotificationActionButton>? actions;
  final DateTime? scheduledTime;
  final bool isRepeating;
  final RepeatInterval? repeatInterval;
  final String? channelId;
  final BigTextStyleInformation? bigTextStyle;
  final BigPictureStyleInformation? bigPictureStyle;
  final Map<String, dynamic>? metadata;

  const NotificationTask({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.priority = NotificationPriority.defaultPriority,
    this.category = NotificationCategory.defaultCategory,
    this.ongoing = false,
    this.actions,
    this.scheduledTime,
    this.isRepeating = false,
    this.repeatInterval,
    this.channelId,
    this.bigTextStyle,
    this.bigPictureStyle,
    this.metadata,
  });

  /// Create a copy with modified fields
  NotificationTask copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
    NotificationPriority? priority,
    NotificationCategory? category,
    bool? ongoing,
    List<NotificationActionButton>? actions,
    DateTime? scheduledTime,
    bool? isRepeating,
    RepeatInterval? repeatInterval,
    String? channelId,
    BigTextStyleInformation? bigTextStyle,
    BigPictureStyleInformation? bigPictureStyle,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationTask(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      ongoing: ongoing ?? this.ongoing,
      actions: actions ?? this.actions,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      channelId: channelId ?? this.channelId,
      bigTextStyle: bigTextStyle ?? this.bigTextStyle,
      bigPictureStyle: bigPictureStyle ?? this.bigPictureStyle,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'priority': priority.index,
      'category': category.index,
      'ongoing': ongoing,
      'actions': actions?.map((a) => a.toJson()).toList(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'isRepeating': isRepeating,
      'repeatInterval': repeatInterval?.index,
      'channelId': channelId,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory NotificationTask.fromJson(Map<String, dynamic> json) {
    return NotificationTask(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as String?,
      priority: NotificationPriority.values[json['priority'] as int? ?? 1],
      category: NotificationCategory.values[json['category'] as int? ?? 0],
      ongoing: json['ongoing'] as bool? ?? false,
      actions: (json['actions'] as List?)?.map((a) => NotificationActionButton.fromJson(a)).toList(),
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'] as String) 
          : null,
      isRepeating: json['isRepeating'] as bool? ?? false,
      repeatInterval: json['repeatInterval'] != null 
          ? RepeatInterval.values[json['repeatInterval'] as int] 
          : null,
      channelId: json['channelId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body &&
          payload == other.payload &&
          priority == other.priority &&
          category == other.category &&
          ongoing == other.ongoing &&
          scheduledTime == other.scheduledTime &&
          isRepeating == other.isRepeating &&
          repeatInterval == other.repeatInterval;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        body,
        payload,
        priority,
        category,
        ongoing,
        scheduledTime,
        isRepeating,
        repeatInterval,
      );

  @override
  String toString() {
    return 'NotificationTask(id: $id, title: $title, priority: $priority, scheduled: $scheduledTime)';
  }
}

/// Repeat intervals for recurring notifications
enum RepeatInterval {
  everyMinute,
  everyHour,
  everyDay,
  everyWeek,
  everyMonth,
  custom,
}

/// Predefined notification templates for testing
class NotificationTemplates {
  static const List<NotificationTask> testNotifications = [
    // Basic test notification
    NotificationTask(
      id: 1001,
      title: 'HyperNotify Lab - Test',
      body: 'This is a test notification from HyperNotify Lab',
      priority: NotificationPriority.defaultPriority,
      category: NotificationCategory.defaultCategory,
    ),
    
    // High priority notification
    NotificationTask(
      id: 1002,
      title: 'High Priority Alert',
      body: 'This notification uses high priority channel with sound and vibration',
      priority: NotificationPriority.high,
      category: NotificationCategory.status,
      actions: [
        NotificationActionButton(
          id: 'action_view',
          title: 'View Details',
          allowGeneratedReplies: false,
        ),
        NotificationActionButton(
          id: 'action_dismiss',
          title: 'Dismiss',
          allowGeneratedReplies: false,
        ),
      ],
    ),
    
    // Critical notification (bypasses DND)
    NotificationTask(
      id: 1003,
      title: 'CRITICAL: System Alert',
      body: 'This critical notification bypasses Do Not Disturb mode',
      priority: NotificationPriority.critical,
      category: NotificationCategory.system,
      ongoing: true,
      actions: [
        NotificationActionButton(
          id: 'action_acknowledge',
          title: 'Acknowledge',
          allowGeneratedReplies: false,
        ),
      ],
    ),
    
    // HyperOS Super Island notification
    NotificationTask(
      id: 1004,
      title: 'HyperOS Super Island',
      body: 'Testing Xiaomi HyperOS Super Island / Hyper Island integration',
      priority: NotificationPriority.high,
      category: NotificationCategory.status,
      channelId: NotificationService.channelIdHyperOS,
      actions: [
        NotificationActionButton(
          id: 'action_expand',
          title: 'Expand',
          allowGeneratedReplies: false,
        ),
        NotificationActionButton(
          id: 'action_settings',
          title: 'Settings',
          allowGeneratedReplies: false,
        ),
      ],
    ),
    
    // Messaging style notification
    NotificationTask(
      id: 1005,
      title: 'New Message',
      body: 'You have a new message from HyperNotify Lab',
      priority: NotificationPriority.high,
      category: NotificationCategory.message,
      actions: [
        NotificationActionButton(
          id: 'action_reply',
          title: 'Reply',
          allowGeneratedReplies: true,
        ),
        NotificationActionButton(
          id: 'action_mark_read',
          title: 'Mark Read',
          allowGeneratedReplies: false,
        ),
      ],
    ),
    
    // Ongoing/foreground service notification
    NotificationTask(
      id: 1006,
      title: 'Foreground Service Active',
      body: 'HyperNotify Lab is running in the background',
      priority: NotificationPriority.low,
      category: NotificationCategory.service,
      ongoing: true,
    ),
    
    // Big text style notification
    NotificationTask(
      id: 1007,
      title: 'Long Content Notification',
      body: 'Short preview',
      priority: NotificationPriority.defaultPriority,
      category: NotificationCategory.event,
      bigTextStyle: BigTextStyleInformation(
        'This is a very long notification content that demonstrates the big text style. '
        'It can contain multiple lines of text and will expand when the user pulls down on the notification. '
        'This is useful for showing article previews, long messages, or detailed status updates.',
        htmlFormatBigText: true,
        htmlFormatTitle: true,
        contentTitle: 'Expanded Content Title',
        summaryText: 'Summary text shown when collapsed',
      ),
    ),
    
    // Scheduled notification example
    NotificationTask(
      id: 1008,
      title: 'Scheduled Reminder',
      body: 'This notification was scheduled for a specific time',
      priority: NotificationPriority.high,
      category: NotificationCategory.event,
      scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
    ),
    
    // Repeating notification
    NotificationTask(
      id: 1009,
      title: 'Hourly Reminder',
      body: 'This notification repeats every hour',
      priority: NotificationPriority.defaultPriority,
      category: NotificationCategory.event,
      isRepeating: true,
      repeatInterval: RepeatInterval.everyHour,
    ),
    
    // Custom notification with metadata
    NotificationTask(
      id: 1010,
      title: 'Custom Data Notification',
      body: 'This notification carries custom metadata',
      priority: NotificationPriority.defaultPriority,
      category: NotificationCategory.recommendation,
      metadata: {
        'source': 'hypernotify_lab',
        'version': '1.0.0',
        'test_type': 'metadata',
        'custom_field': 'custom_value',
      },
    ),
  ];

  /// Get all test notifications
  static List<NotificationTask> getAllTestNotifications() => List.from(testNotifications);

  /// Get notification by ID
  static NotificationTask? getById(int id) {
    try {
      return testNotifications.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a custom notification task
  static NotificationTask createCustom({
    required int id,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.defaultPriority,
    NotificationCategory category = NotificationCategory.defaultCategory,
    List<NotificationActionButton>? actions,
    DateTime? scheduledTime,
    bool isRepeating = false,
    RepeatInterval? repeatInterval,
  }) {
    return NotificationTask(
      id: id,
      title: title,
      body: body,
      priority: priority,
      category: category,
      actions: actions,
      scheduledTime: scheduledTime,
      isRepeating: isRepeating,
      repeatInterval: repeatInterval,
    );
  }
}

/// Notification action button model
class NotificationActionButton {
  final String id;
  final String title;
  final IconData? icon;
  final bool allowGeneratedReplies;
  final bool requireAuthentication;

  const NotificationActionButton({
    required this.id,
    required this.title,
    this.icon,
    this.allowGeneratedReplies = false,
    this.requireAuthentication = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon?.codePoint,
      'allowGeneratedReplies': allowGeneratedReplies,
      'requireAuthentication': requireAuthentication,
    };
  }

  factory NotificationActionButton.fromJson(Map<String, dynamic> json) {
    return NotificationActionButton(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] != null ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons') : null,
      allowGeneratedReplies: json['allowGeneratedReplies'] as bool? ?? false,
      requireAuthentication: json['requireAuthentication'] as bool? ?? false,
    );
  }

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