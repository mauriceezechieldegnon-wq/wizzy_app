import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';

class LuckyDrawScreen extends StatelessWidget {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          int points = userData['points'] ?? 0;
          bool hasPaid = userData['hasPaidEntry'] ?? false;
          bool isQualified = points >= 1000;

          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const Text("TIRAGE MENSUEL",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                const SizedBox(height: 40),

                // Statut
                _statusIcon(hasPaid, isQualified),

                const SizedBox(height: 30),
                Text(
                  hasPaid
                      ? "INSCRIPTION VALIDÉE !"
                      : (isQualified
                          ? "TU ES ÉLIGIBLE !"
                          : "PAS ENCORE QUALIFIÉ"),
                  style: TextStyle(
                      color:
                          hasPaid ? Colors.greenAccent : AppColors.accentYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                const SizedBox(height: 10),
                Text(
                  hasPaid
                      ? "Bonne chance pour le tirage final."
                      : "Gagne 1000 points pour débloquer ton ticket.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38),
                ),

                const Spacer(),

                // Historique des gagnants
                _buildWinnerHistory(),

                const SizedBox(height: 30),

                if (isQualified && !hasPaid) _payButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusIcon(bool paid, bool qualified) {
    IconData icon = Icons.lock_outline;
    Color col = Colors.white10;
    if (paid) {
      icon = Icons.verified_user;
      col = Colors.greenAccent;
    } else if (qualified) {
      icon = Icons.confirmation_number;
      col = AppColors.accentYellow;
    }

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          shape: BoxShape.circle, color: col.withValues(alpha: 0.1)),
      child: Icon(icon, size: 80, color: col),
    );
  }

  Widget _buildWinnerHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('draw_history')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox();
        var winner = snap.data!.docs.first;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10)),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 15),
              Text("DERNIER GAGNANT : ${winner['winnerName']}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _payButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Redirection vers ton service de paiement FedaPay
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ouverture de FedaPay...")));
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: const Text("PARTICIPER POUR 100F",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
