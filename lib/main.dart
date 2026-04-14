import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'dart:io'; // Pour Platform
import 'firebase_options.dart';

// Mes screens 
import 'package:wizzy/features/auth/screens/splash_screen.dart';
import 'package:wizzy/features/auth/screens/register_screen.dart';
import 'package:wizzy/features/home/screens/home_screen.dart';
import 'package:wizzy/features/core/services/notification_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Initialisation Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. Initialisation des NOTIFICATIONS (Uniquement sur MOBILE)
    // On évite d'appeler le service sur Windows car la v17 peut faire crash le PC
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final notificationService = NotificationService();
        await notificationService.init();
      } catch (e) {
        debugPrint("Notifs désactivées sur ce support : $e");
      }
    }

    // 3. Paramètres Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    runApp(const WizzyApp());
  } catch (e) {
    // Si ça crash au boot sur Windows, on pourra voir l'erreur
    debugPrint("ERREUR FATALE AU DÉMARRAGE : $e");
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Erreur : $e")))));
  }
}

class WizzyApp extends StatelessWidget {
  const WizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wizzy',
      theme: ThemeData.dark(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const WizzySplashScreen(),
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return (snapshot.hasData && snapshot.data != null) 
                ? const HomeScreen() 
                : const RegisterScreen();
          },
        ),
      },
    );
  }
}
