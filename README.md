# HyperNotify Lab

Xiaomi HyperOS Tablet Hyper Island Notification Tester

## Overview

HyperNotify Lab is a comprehensive notification testing application designed for Xiaomi HyperOS tablets. It provides a complete test suite for Android 16 notification features, HyperOS Super Island / Hyper Island integration, and foreground service management.

## Features

- **Android 16 Notification Support**: Full support for Android 16 (API 34) notification APIs including critical notifications, live activities, and enhanced notification channels
- **Xiaomi HyperOS Integration**: Super Island / Hyper Island notification testing with dynamic updates and interactive actions
- **Tablet-Optimized UI**: Responsive layout that adapts from phone to tablet to desktop
- **Foreground Service**: Background execution with ongoing notification and WorkManager integration
- **Comprehensive Testing**: Multiple notification types, priorities, categories, and action buttons
- **Scheduled Notifications**: Exact and inexact scheduling with repeat intervals
- **Permission Management**: Runtime permission handling for all Android versions
- **Material 3 Design**: Modern UI with light/dark theme support

## Requirements

- Flutter 3.22+
- Dart 3.4+
- Android Studio / VS Code with Flutter plugin
- Android SDK 34 (Android 14)
- Java 17
- Xiaomi HyperOS device for Super Island testing (optional)

## Getting Started

### Installation

```bash
# Clone the repository
git clone https://github.com/C4RL-DANIEL/HyperNotify-Lab.git
cd HyperNotify-Lab

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Building APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires keystore)
flutter build apk --release
```

The debug APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

### GitHub Actions

The project includes a GitHub Actions workflow (`.github/workflows/android-build.yml`) that:
1. Checks out the code
2. Sets up JDK 17, Flutter, and Android SDK
3. Builds the debug APK
4. Runs lint checks
5. Runs unit tests
6. Uploads the APK as an artifact

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── notification/
│   ├── notification_service.dart    # Core notification service
│   └── hyperos_notification.dart    # HyperOS Super Island integration
├── service/
│   └── foreground_service.dart      # Foreground service management
├── model/
│   └── notification_task.dart       # Notification data models
├── ui/
│   ├── main_screen.dart             # Main dashboard
│   ├── notification_test_screen.dart # Notification testing UI
│   ├── hyperos_screen.dart          # HyperOS specific tests
│   └── settings_screen.dart         # App settings
└── utils/
    └── tablet_layout.dart           # Responsive layout utilities

android/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/hypernotify/lab/
│   │   │   ├── MainActivity.kt              # Main Flutter activity
│   │   │   └── notification/
│   │   │       ├── NotificationForegroundService.kt  # Foreground service
│   │   │       ├── NotificationActionReceiver.kt     # Action handling
│   │   │       └── BootReceiver.kt                   # Boot completion
│   │   ├── res/
│   │   │   ├── values/              # Strings, colors, themes
│   │   │   ├── drawable/            # Launch background
│   │   │   └── xml/                 # Network security config
│   │   └── AndroidManifest.xml      # App manifest with permissions
│   └── build.gradle.kts             # App Gradle config
└── build.gradle.kts                 # Project Gradle config
```

## Notification Types Supported

| Type | Priority | Channel | Use Case |
|------|----------|---------|----------|
| Default | Default | hypernotify_default | Standard notifications |
| High Priority | High | hypernotify_high | Important alerts with sound/vibration |
| Critical | Critical | hypernotify_critical | Bypasses Do Not Disturb |
| HyperOS | High | hypernotify_hyperos | Super Island integration |
| Test | Low | hypernotify_test | Development testing |
| Foreground | Low | hypernotify_foreground | Ongoing service notification |

## Android Permissions

| Permission | API Level | Purpose |
|------------|-----------|---------|
| POST_NOTIFICATIONS | 33+ | Show notifications |
| SCHEDULE_EXACT_ALARM | 31+ | Schedule exact notifications |
| FOREGROUND_SERVICE | 31+ | Run foreground service |
| FOREGROUND_SERVICE_DATA_SYNC | 34+ | Data sync foreground service |
| ACCESS_NOTIFICATION_POLICY | 24+ | Bypass Do Not Disturb |
| RECEIVE_BOOT_COMPLETED | 1+ | Auto-start after boot |
| VIBRATE | 1+ | Vibration feedback |
| WAKE_LOCK | 1+ | Keep CPU awake |

## HyperOS Super Island Features

- **Super Island Notifications**: Send notifications to Xiaomi's Super Island
- **Live Activities**: Persistent, glanceable notifications with timeout
- **Dynamic Updates**: Update notification content in real-time
- **Interactive Actions**: Buttons with replies, authentication, and deep links
- **Media Controls**: Playback controls in notification shade

## Testing Checklist

- [ ] Basic notifications (all priorities)
- [ ] Notification actions (tap, reply, dismiss)
- [ ] Scheduled notifications (exact/inexact)
- [ ] Repeating notifications
- [ ] Big text/picture styles
- [ ] Ongoing/foreground service notifications
- [ ] HyperOS Super Island (on Xiaomi device)
- [ ] Live activities with timeout
- [ ] Permission handling (grant/deny)
- [ ] Boot completion auto-start
- [ ] Theme switching (light/dark/system)
- [ ] Tablet/phone layout adaptation
- [ ] Foreground service start/stop
- [ ] Clear all notifications

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and lint
5. Submit a pull request

## Support

- Issues: [GitHub Issues](https://github.com/C4RL-DANIEL/HyperNotify-Lab/issues)
- Discussions: [GitHub Discussions](https://github.com/C4RL-DANIEL/HyperNotify-Lab/discussions)