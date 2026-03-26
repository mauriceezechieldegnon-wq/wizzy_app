import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import '../../core/services/notification_service.dart';
import 'add_product_screen.dart';
import 'add_question_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("ADMIN PANEL",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _adminCard(
              context,
              "AJOUTER PRODUIT",
              FontAwesomeIcons.plus,
              Colors.orangeAccent,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddProductScreen()))),
          _adminCard(
              context,
              "AJOUTER QUESTION",
              FontAwesomeIcons.question,
              Colors.blueAccent,
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddQuestionScreen()))),
          _adminCard(context, "EXPORTER CONTACTS", FontAwesomeIcons.fileCsv,
              Colors.greenAccent, () => _exportUsers(context)),
          const Divider(height: 50, color: Colors.white10),
          _adminCard(context, "LANCER LE TIRAGE", FontAwesomeIcons.dice,
              Colors.pinkAccent, () => _confirmLuckyDraw(context)),
        ],
      ),
    );
  }

  Widget _adminCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // LOGIQUE EXPORT CSV
  void _exportUsers(BuildContext context) async {
    var snap = await FirebaseFirestore.instance.collection('users').get();
    String csv = "Pseudo,Email,WhatsApp,Points\n";
    for (var doc in snap.docs) {
      var d = doc.data();
      csv += "${d['username']},${d['email']},${d['whatsapp']},${d['points']}\n";
    }
    await Share.share(csv, subject: 'Wizzy_Users_Export');
  }

  // LOGIQUE DU TIRAGE AU SORT
  void _confirmLuckyDraw(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title:
            const Text("Tirage au Sort", style: TextStyle(color: Colors.white)),
        content: const Text("Choisir un gagnant parmi les payeurs ?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("ANNULER")),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _runDraw(context);
              },
              child: const Text("LANCER")),
        ],
      ),
    );
  }

  void _runDraw(BuildContext context) async {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .where('hasPaidEntry', isEqualTo: true)
        .get();
    if (snap.docs.isEmpty) return;

    final winner = snap.docs[Random().nextInt(snap.docs.length)];
    String winnerName = winner['username'];

    // Sauvegarder l'historique
    await FirebaseFirestore.instance.collection('draw_history').add({
      'winnerName': winnerName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notification
    await NotificationService()
        .showVictoryNotification("Le gagnant du mois est $winnerName ! 🎉");

    // Reset des paiements pour le mois prochain
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snap.docs) {
      batch.update(doc.reference, {'hasPaidEntry': false});
    }
    await batch.commit();
  }
}
