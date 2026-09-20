// HyperNotify Lab - Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:hyper_notify_lab/main.dart';

void main() {
  testWidgets('HyperNotifyLabApp renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HyperNotifyLabApp(
      onThemeToggle: null,
      themeMode: ThemeMode.system,
    ));

    // Verify the app title is displayed
    expect(find.text('HyperNotify Lab'), findsOneWidget);
  });
}