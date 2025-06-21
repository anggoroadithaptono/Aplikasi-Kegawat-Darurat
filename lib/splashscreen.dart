import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart'; 
import 'pilih_user_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _requestNotificationPermission(); 

    // Inisialisasi animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Inisialisasi plugin notifikasi
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Tampilkan notifikasi setelah setengah detik
    Future.delayed(const Duration(milliseconds: 500), () {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'splash_channel_id', 
        'Splash Notifications', 
        channelDescription: 'Notifikasi yang muncul saat splash screen',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      flutterLocalNotificationsPlugin.show(
        0,
        'Selamat Datang',
        'Aplikasi emergency siap membantu Anda!',
        platformDetails,
      );
    });

    // Timer ke layar PilihUserScreen
    Timer(const Duration(seconds: 11), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PilihUserScreen()),
      );
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC71811),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 450,
                height: 450,
                decoration: const BoxDecoration(
                  color: Color(0xFFC71811),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/robotgerak.gif',
                    width: 600,
                    height: 600,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                "EMERGENCY APP",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animation,
              child: const Text(
                "Bantuan Cepat & Tanggap",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
