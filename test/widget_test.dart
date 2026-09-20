// HyperNotify Lab - Simple Unit Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_notify_lab/model/notification_task.dart';
import 'package:hyper_notify_lab/notification/notification_service.dart';

void main() {
  group('NotificationTask', () {
    test('can create a basic notification task', () {
      final task = NotificationTask(
        id: 1,
        title: 'Test',
        body: 'Test body',
        priority: NotificationPriority.high,
        category: NotificationCategory.message,
      );

      expect(task.id, 1);
      expect(task.title, 'Test');
      expect(task.body, 'Test body');
      expect(task.priority, NotificationPriority.high);
      expect(task.category, NotificationCategory.message);
    });

    test('can create task from JSON', () {
      final json = {
        'id': 2,
        'title': 'JSON Task',
        'body': 'From JSON',
        'priority': 2,
        'category': 1,
        'ongoing': false,
        'isRepeating': false,
      };

      final task = NotificationTask.fromJson(json);

      expect(task.id, 2);
      expect(task.title, 'JSON Task');
      expect(task.priority, NotificationPriority.high);
      expect(task.category, NotificationCategory.call);
    });

    test('can convert task to JSON', () {
      final task = NotificationTask(
        id: 3,
        title: 'To JSON',
        body: 'Convert me',
        priority: NotificationPriority.critical,
        category: NotificationCategory.system,
      );

      final json = task.toJson();

      expect(json['id'], 3);
      expect(json['title'], 'To JSON');
      expect(json['priority'], 3);
      expect(json['category'], 10);
    });

    test('copyWith creates modified copy', () {
      final original = NotificationTask(
        id: 4,
        title: 'Original',
        body: 'Original body',
      );

      final modified = original.copyWith(
        title: 'Modified',
        priority: NotificationPriority.low,
      );

      expect(modified.id, 4);
      expect(modified.title, 'Modified');
      expect(modified.body, 'Original body');
      expect(modified.priority, NotificationPriority.low);
    });
  });

  group('NotificationTemplates', () {
    test('has predefined templates', () {
      final templates = NotificationTemplates.getAllTestNotifications();
      expect(templates, isNotEmpty);
      expect(templates.length, 10);
    });

    test('can get template by ID', () {
      final template = NotificationTemplates.getById(1001);
      expect(template, isNotNull);
      expect(template!.title, 'HyperNotify Lab - Test');
    });

    test('returns null for unknown ID', () {
      final template = NotificationTemplates.getById(9999);
      expect(template, isNull);
    });

    test('can create custom notification', () {
      final custom = NotificationTemplates.createCustom(
        id: 5000,
        title: 'Custom',
        body: 'Custom body',
        priority: NotificationPriority.high,
        category: NotificationCategory.event,
      );

      expect(custom.id, 5000);
      expect(custom.title, 'Custom');
      expect(custom.priority, NotificationPriority.high);
      expect(custom.category, NotificationCategory.event);
    });
  });

  group('NotificationActionButton', () {
    test('can create action button', () {
      const action = NotificationActionButton(
        id: 'test_action',
        title: 'Test Action',
        allowGeneratedReplies: true,
        requireAuthentication: false,
      );

      expect(action.id, 'test_action');
      expect(action.title, 'Test Action');
      expect(action.allowGeneratedReplies, true);
      expect(action.requireAuthentication, false);
    });

    test('can convert to Android action', () {
      const action = NotificationActionButton(
        id: 'android_action',
        title: 'Android Action',
      );

      final androidAction = action.toAndroidAction();
      expect(androidAction.actionId, 'android_action');
      expect(androidAction.title, 'Android Action');
    });
  });
}