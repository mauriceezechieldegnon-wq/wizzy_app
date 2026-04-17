import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'firebase_options.dart';

import 'package:wizzy/features/auth/screens/splash_screen.dart';
import 'package:wizzy/features/auth/screens/register_screen.dart';
import 'package:wizzy/features/home/screens/home_screen.dart';
import 'package:wizzy/features/core/services/notification_service.dart';

void main() async {
  // Capture les erreurs pour éviter le "ferme tout seul"
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("CRASH DETECTÉ : ${details.exception}");
  };

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final notificationService = NotificationService();
      await notificationService.init();
    }

    runApp(const WizzyApp());
  } catch (e) {
    debugPrint("ERREUR FATALE BOOT : $e");
  }
}

class WizzyApp extends StatelessWidget {
  const WizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wizzy',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF09090B),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const WizzySplashScreen(),
        '/': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
                return snapshot.hasData
                    ? const HomeScreen()
                    : const RegisterScreen();
              },
            ),
      },
    );
  }
}
