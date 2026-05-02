import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class NotificationService {
  Future<void> init() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux) return;

    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

    await fcm.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit, iOS: DarwinInitializationSettings());
    
    await localNotifications.initialize(initSettings);
  }

  // CETTE MÉTHODE MANQUAIT OU ÉTAIT MAL NOMMÉE
  Future<void> showVictoryNotification(String title) async {
    if (kIsWeb || Platform.isWindows) return;
    
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails(
      'wizzy_channel', 
      'Wizzy Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await localNotifications.show(
      0, 
      "🏆 VICTOIRE !", 
      title, 
      const NotificationDetails(android: androidDetails)
    );
  }
}
