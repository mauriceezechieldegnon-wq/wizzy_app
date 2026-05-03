import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; 
import 'dart:io'; 
import 'firebase_options.dart';

// --- TES IMPORTS ---
import 'package:wizzy/features/auth/screens/splash_screen.dart';
import 'package:wizzy/features/auth/screens/register_screen.dart';
import 'package:wizzy/features/home/screens/home_screen.dart';
import 'package:wizzy/features/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialisation Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Configuration Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3. Initialisation des NOTIFICATIONS (Uniquement sur MOBILE)
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final notificationService = NotificationService();
        await notificationService.init();
      } catch (e) {
        debugPrint("Notifs désactivées : $e");
      }
    }

    // 4. LANCEMENT DE L'APP
    runApp(const WizzyApp());

  } catch (e) {
    // Écran de secours en cas d'erreur fatale au boot
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Erreur système : $e", style: const TextStyle(color: Colors.white))),
      ),
    ));
  }
}

// --- LA CLASSE QUI MANQUAIT OU ÉTAIT MAL ÉCRITE ---
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
              );
            }
            // Si connecté -> Home, sinon -> Register
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }
            return const RegisterScreen();
          },
        ),
      },
    );
  }
}
