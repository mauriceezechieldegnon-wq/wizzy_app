import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Demander les permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Récupérer le token unique
      String? token = await _fcm.getToken();
      if (token != null) {
        _saveTokenToDatabase(token);
      }
    }

    // 3. Configurer les notifications locales
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    // FIX : Dans la v17, on passe l'objet directement (argument positionnel)
    await _localNotifications.initialize(initSettings);

    // Canal pour Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'wizzy_channel',
      'Wizzy Alerts',
      description: 'Notifications pour les tournois et tirages',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': token,
      });
    }
  }

  Future<void> showVictoryNotification(String title) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'wizzy_channel',
      'Wizzy Alerts',
      channelDescription: 'Notifications de victoires',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // FIX : Dans la v17, les 4 premiers arguments sont positionnels (pas de id:, title:, etc.)
    await _localNotifications.show(
      0, // id
      "🏆 FÉLICITATIONS !", // title
      title, // body
      platformDetails, // notificationDetails
    );
  }
}
