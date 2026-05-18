import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:wizzy/firebase_options.dart';

// Imports conditionnels pour éviter le crash Windows
import 'package:wizzy/features/auth/screens/splash_screen.dart';
import 'package:wizzy/features/auth/screens/register_screen.dart';
import 'package:wizzy/features/home/screens/home_screen.dart';
import 'package:wizzy/features/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 1. Init Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2. Logique Mobile (Android/iOS)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      // On initialise les notifs seulement ici
      await NotificationService().init();
    }
  } catch (e) {
    debugPrint("Erreur démarrage : $e");
  }

  runApp(const WizzyApp());
}

class WizzyApp extends StatelessWidget {
  const WizzyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wizzy',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const WizzySplashScreen(),
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) return const HomeScreen();
            return const RegisterScreen();
          },
        ),
      },
    );
  }
}
