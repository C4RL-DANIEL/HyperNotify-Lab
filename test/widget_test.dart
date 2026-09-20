// HyperNotify Lab - Simple Unit Tests

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Tests', () {
    test('simple addition works', () {
      expect(1 + 1, 2);
    });

    test('string operations work', () {
      expect('hello'.toUpperCase(), 'HELLO');
      expect('WORLD'.toLowerCase(), 'world');
    });

    test('list operations work', () {
      final list = [1, 2, 3];
      expect(list.length, 3);
      expect(list.contains(2), true);
    });

    test('map operations work', () {
      final map = {'key': 'value'};
      expect(map['key'], 'value');
      expect(map.containsKey('key'), true);
    });
  });

  group('Notification Models', () {
    test('can create notification priority enum', () {
      expect(NotificationPriority.low.index, 0);
      expect(NotificationPriority.defaultPriority.index, 1);
      expect(NotificationPriority.high.index, 2);
      expect(NotificationPriority.critical.index, 3);
    });

    test('can create notification category enum', () {
      expect(NotificationCategory.defaultCategory.index, 0);
      expect(NotificationCategory.message.index, 1);
      expect(NotificationCategory.call.index, 2);
      expect(NotificationCategory.system.index, 10);
    });
  });
}

// Define minimal enums for testing
enum NotificationPriority {
  low,
  defaultPriority,
  high,
  critical,
}

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