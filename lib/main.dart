import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// --- IMPORTS DES FEATURES ---
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

    // 2. Configuration Hors-ligne Firestore
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // 3. Initialisation des notifications (Sécurisée pour éviter le crash au démarrage)
    try {
      final notificationService = NotificationService();
      await notificationService.init();
    } catch (e) {
      debugPrint("Erreur d'initialisation des notifications : $e");
    }

    runApp(const WizzyApp());
  } catch (e) {
    // Si une erreur grave survient au boot
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Erreur de démarrage : $e")),
      ),
    ));
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
        primaryColor: const Color(0xFF6200EE),
        useMaterial3: true,
      ),
      
      // On commence toujours par le Splash Screen
      initialRoute: '/splash',
      
      routes: {
        '/splash': (context) => const WizzySplashScreen(),
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Pendant que Firebase vérifie si on est connecté
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Color(0xFF6200EE))),
              );
            }
            
            // Si l'utilisateur est trouvé dans la session -> Dashboard
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }
            
            // Sinon -> Écran d'inscription
            return const RegisterScreen();
          },
        ),
      },
    );
  }
}
