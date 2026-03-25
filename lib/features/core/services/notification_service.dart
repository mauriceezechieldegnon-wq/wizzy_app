import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Demander la permission (Android 13+ et iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Récupérer le Token FCM pour envoyer des notifs depuis le serveur
      String? token = await _fcm.getToken();
      if (token != null) {
        _saveTokenToDatabase(token);
      }
    }

    // 3. Configurer les notifications locales pour le mode "Foreground" (App ouverte)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(initSettings);
  }

  // Enregistre le token dans Firestore sous le profil de l'utilisateur
  void _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  // Affiche une notification de victoire avec un style "Wizzy"
  Future<void> showVictoryNotification(String tournamentName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'wizzy_tournaments', // ID du canal
      'Tournois Wizzy',    // Nom du canal
      channelDescription: 'Notifications de victoires en tournoi',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      1, // ID de la notif
      "🏆 VICTOIRE ÉCLATANTE !",
      "Félicitations ! Tu as gagné le tournoi $tournamentName !",
      platformDetails,
    );
  }
}