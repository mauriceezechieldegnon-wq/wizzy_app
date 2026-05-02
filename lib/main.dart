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
// On n'importe le service que si on est sur mobile pour éviter que Windows ne le scanne
import 'package:wizzy/features/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Init Firebase (Config Web pour Windows)
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2. Init Notifs UNIQUEMENT sur Android/iOS
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final notificationService = NotificationService();
      await notificationService.init();
    }

    runApp(const WizzyApp());
  } catch (e) {
    // Si Windows râle encore, on affiche l'erreur proprement
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("WIZZY PC - Erreur: $e", style: TextStyle(color: Colors.white))),
      ),
    ));
  }
}

    // 5. Lancement de l'application
    runApp(const WizzyApp());

  } catch (e) {
    // Si l'application échoue à démarrer, on affiche l'erreur à l'écran
    debugPrint("ERREUR FATALE AU BOOT : $e");
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SelectableText(
            "Erreur système : $e", 
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
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
        useMaterial3: true,
        primaryColor: const Color(0xFF6200EE),
        scaffoldBackgroundColor: const Color(0xFF09090B), // Fond noir profond
      ),
      
      // On commence par le Splash Screen animé
      initialRoute: '/splash',
      
      routes: {
        '/splash': (context) => const WizzySplashScreen(),
        '/': (context) => StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // A. Pendant que Firebase cherche la session (Chargement)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF09090B),
                body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
              );
            }
            
            // B. Si l'utilisateur est bien connecté -> Dashboard
            if (snapshot.hasData && snapshot.data != null) {
              return const HomeScreen();
            }
            
            // C. Sinon, redirection vers l'inscription
            return const RegisterScreen();
          },
        ),
      },
    );
  }
}
