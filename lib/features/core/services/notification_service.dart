import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class NotificationService {
  Future<void> init() async {
    // SÉCURITÉ : On arrête tout si on est sur Windows, Web ou Linux
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint("Notifications ignorées sur ce support.");
      return;
    }

    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

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
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: DarwinInitializationSettings());
    await localNotifications.initialize(initSettings);
  }

  Future<void> showVictoryNotification(String title) async {
    if (kIsWeb || Platform.isWindows) return;
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails('wizzy_channel', 'Wizzy Alerts', importance: Importance.max, priority: Priority.high);
    await localNotifications.show(0, "🏆 FÉLICITATIONS !", title, const NotificationDetails(android: androidDetails));
  }
}
