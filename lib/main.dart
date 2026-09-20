// HyperNotify Lab - Minimal working Flutter app
import 'package:flutter/material.dart';

void main() {
  runApp(const HyperNotifyLabApp());
}

class HyperNotifyLabApp extends StatelessWidget {
  const HyperNotifyLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperNotify Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006EFF)),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HyperNotify Lab'),
        centerTitle: true,
        backgroundColor: const Color(0xFF006EFF),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_active, size: 80, color: Color(0xFF006EFF)),
              SizedBox(height: 24),
              Text(
                'HyperNotify Lab',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Xiaomi HyperOS Tablet\nHyper Island Notification Tester',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 32),
              Text(
                '✅ APK Built Successfully!',
                style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Build locally for full features:\nflutter build apk --debug',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}