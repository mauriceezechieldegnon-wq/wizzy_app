import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  // 1. TA CLÉ PRIVÉE (À prendre sur ton dashboard FedaPay)
  // Attention: Utilise la clé "Secret" (sk_live... ou sk_sandbox...)
  final String secretKey = "sk_sandbox_XXXXXXXXXXXXXX";

  Future<void> startTransaction(BuildContext context, int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 2. CRÉATION DE LA TRANSACTION CHEZ FEDAPAY
      final response = await http.post(
        Uri.parse('https://api.fedapay.com/v1/transactions'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "description": "Ticket Tirage WIZZY 100F",
          "amount": amount,
          "currency": {"iso": "XOF"},
          "callback_url": "https://wizzy-app.web.app", // Une URL de retour
          "customer": {
            "firstname": user.displayName ?? "Joueur",
            "lastname": "Wizzy",
            "email": user.email,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 3. RÉCUPÉRATION DU LIEN DE PAIEMENT
        final String paymentUrl = data['vpos_url'];

        // 4. OUVERTURE DU LIEN
        if (await canLaunchUrl(Uri.parse(paymentUrl))) {
          await launchUrl(
            Uri.parse(paymentUrl),
            mode: LaunchMode.externalApplication, // Ouvre le navigateur
          );

          // NOTE: Dans une vraie app, on vérifierait le statut après le retour
          // Ici, on valide pour le test :
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'hasPaidEntry': true,
          });
        }
      } else {
        debugPrint("Erreur FedaPay : ${response.body}");
      }
    } catch (e) {
      debugPrint("Erreur de connexion paiement : $e");
    }
  }
}
