import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/payment_service.dart';

class LuckyDrawScreen extends StatelessWidget {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("TIRAGE AU SORT")),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          int points = data['points'] ?? 0;
          bool hasPaid = data['hasPaidEntry'] ?? false;

          // Règle : Il faut au moins 1000 points pour être dans la course (exemple)
          bool isQualified = points >= 1000;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number,
                    size: 80,
                    color:
                        hasPaid ? Colors.greenAccent : AppColors.accentYellow),
                const SizedBox(height: 20),
                Text(
                  hasPaid
                      ? "TICKET VALIDÉ"
                      : (isQualified
                          ? "TU ES QUALIFIÉ !"
                          : "PAS ENCORE QUALIFIÉ"),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  hasPaid
                      ? "Rendez-vous le 30 mars pour le résultat."
                      : (isQualified
                          ? "Paie 100F pour participer au tirage mensuel."
                          : "Gagne encore ${1000 - points} points pour te qualifier."),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38),
                ),
                const SizedBox(height: 40),
                if (isQualified && !hasPaid)
                  GestureDetector(
                    onTap: () =>
                        PaymentService().startTransaction(context, 100),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.redAccent]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                          child: Text("PAYER 100F (MOBILE MONEY)",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('draw_history').orderBy('timestamp', descending: true).limit(1).snapshots(),
  builder: (context, snap) {
    if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox();
    var lastWinner = snap.data!.docs.first;
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15)),
      child: Text(
        "Dernier gagnant : ${lastWinner['winnerName']} 🏆",
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  },
),