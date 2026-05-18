import 'package:flutter/foundation.dart';
import 'dart:io';
// On garde les imports, mais on ne les utilise que sous conditions strictes
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // --- AUCUNE VARIABLE ICI AU SOMMET ---

  Future<void> init() async {
    // 1. BARRIÈRE DE SÉCURITÉ ABSOLUE
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      debugPrint("WIZZY Desktop : Les services mobiles ne seront pas chargés.");
      return; 
    }

    // 2. Initialisation UNIQUEMENT si on est sur Mobile
    try {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final FlutterLocalNotificationsPlugin localNotif = FlutterLocalNotificationsPlugin();

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit, iOS: DarwinInitializationSettings());
      
      await localNotif.initialize(initSettings);
      debugPrint("Services mobiles chargés avec succès.");
    } catch (e) {
      debugPrint("Erreur lors du chargement mobile : $e");
    }
  }

  Future<void> showVictoryNotification(String title) async {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) return;
    
    final FlutterLocalNotificationsPlugin localNotif = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails('wizzy_channel', 'Wizzy Alerts');
    await localNotif.show(0, "🏆 VICTOIRE !", title, const NotificationDetails(android: androidDetails));
  }
}
