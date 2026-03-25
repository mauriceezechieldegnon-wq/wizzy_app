import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          title: const Text("WIZZY ADMIN")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAdminCard(context, "AJOUTER UN PRODUIT", FontAwesomeIcons.plus,
              Colors.orangeAccent, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()));
          }),
          _buildAdminCard(context, "AJOUTER UNE QUESTION",
              FontAwesomeIcons.question, Colors.blueAccent, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddQuestionScreen()));
          }),
          _buildAdminCard(context, "EXPORTER CONTACTS (CSV)",
              FontAwesomeIcons.fileCsv, Colors.greenAccent, () async {
            // LOGIQUE DU TUNNEL D'ACQUISITION
            var snap =
                await FirebaseFirestore.instance.collection('users').get();
            String csv = "Pseudo,Email,WhatsApp,Points\n";
            for (var doc in snap.docs) {
              csv +=
                  "${doc['username']},${doc['email']},${doc['whatsapp']},${doc['points']}\n";
            }
            Share.share(csv, subject: "Export_Wizzy_Utilisateurs");
          }),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
import 'dart:math'; // Pour le hasard
import 'package:myapp/features/core/services/notification_service.dart';

// ... Dans ton ListView de AdminDashboardScreen ...

_adminTile(
  context,
  title: "LANCER LE TIRAGE AU SORT",
  icon: FontAwesomeIcons.dice,
  color: Colors.pinkAccent,
  onTap: () => _confirmDraw(context),
),

// --- LA LOGIQUE DU TIRAGE ---

void _confirmDraw(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text("Tirage au Sort", style: TextStyle(color: Colors.white)),
      content: const Text("Es-tu prêt à désigner le grand gagnant de ce mois ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER")),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _executeLuckyDraw(context);
          },
          child: const Text("LANCER !"),
        ),
      ],
    ),
  );
}

Future<void> _executeLuckyDraw(BuildContext context) async {
  try {
    // 1. Récupérer les candidats (Ceux qui ont payé 100f)
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('hasPaidEntry', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Personne n'a payé pour le moment... 🧐"))
      );
      return;
    }

    // 2. Choisir un gagnant au hasard
    final random = Random();
    final winnerIndex = random.nextInt(snapshot.docs.length);
    final winnerDoc = snapshot.docs[winnerIndex];
    final winnerName = winnerDoc['username'];
    final winnerUid = winnerDoc.id;

    // 3. Enregistrer l'historique du mois
    await FirebaseFirestore.instance.collection('draw_history').add({
      'winnerName': winnerName,
      'winnerUid': winnerUid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 4. Envoyer une notification (On simule ici, mais on pourra l'envoyer à TOUS)
    await NotificationService().showVictoryNotification("DU TIRAGE AU SORT ! Le gagnant est $winnerName");

    // 5. Afficher le résultat à l'Admin (Toi)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎉 GAGNANT DÉSIGNÉ 🎉", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Text(winnerName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.accentYellow)),
          ],
        ),
      ),
    );

    // 6. RÉINITIALISATION pour le mois suivant (Important !)
    // On repasse tout le monde à false pour qu'ils doivent repayer le mois prochain
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'hasPaidEntry': false});
    }
    await batch.commit();

  } catch (e) {
    debugPrint("Erreur Tirage : $e");
  }
}