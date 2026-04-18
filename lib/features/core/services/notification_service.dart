import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'dart:io'; // Pour Platform
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  // On ne crée pas les instances ici au sommet pour éviter le crash Windows
  
  Future<void> init() async {
    // 1. VERIFICATION DE SECURITE : On arrête tout si on est sur Windows/Web
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;

    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

    // 2. Demander les permissions (Mobile uniquement)
    NotificationSettings settings = await fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await fcm.getToken();
      if (token != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'fcmToken': token,
          });
        }
      }
    }

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    await localNotifications.initialize(initSettings);
  }

  Future<void> showVictoryNotification(String title) async {
    if (kIsWeb || Platform.isWindows) return; // Sécurité Windows

    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'wizzy_channel', 'Wizzy Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await localNotifications.show(0, "🏆 FÉLICITATIONS !", title, const NotificationDetails(android: androidDetails));
  }
}
