import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'fcm_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();

  String _statusText = 'Waiting for a cloud message...';
  String _imagePath = 'assets/images/default.png';
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    await _fcmService.initialize(onData: (RemoteMessage message) {
      setState(() {
        // Update status text from notification title or fallback
        _statusText =
            message.notification?.title ?? 'Payload received';

        // Update image from data payload key "asset"
        final asset = message.data['asset'] ?? 'default';
        _imagePath = 'assets/images/$asset.png';
      });
    });

    // Get and display token
    final token = await _fcmService.getToken();
    setState(() {
      _fcmToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 14 – FCM Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status text
            Text(
              _statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Image that changes based on payload
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                _imagePath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Image not found')),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // FCM Token display (for testing)
            const Text(
              'Your FCM Token (copy for Firebase Console):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _fcmToken ?? 'Fetching token...',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}