import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wizzy/core/constants/app_colors.dart';
import 'package:wizzy/features/quiz/screens/tournament_game_screen.dart';

class TournamentLobbyScreen extends StatefulWidget {
  const TournamentLobbyScreen({super.key});
  @override
  State<TournamentLobbyScreen> createState() => _TournamentLobbyScreenState();
}

class _TournamentLobbyScreenState extends State<TournamentLobbyScreen> {
  final String tourneyId = "battle_royale_01";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('tournaments').doc(tourneyId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          int count = (data['players'] as List).length;
          
          if (data['status'] == 'starting') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TournamentGameScreen(tournamentId: tourneyId)));
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$count / 5 JOUEURS", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: AppColors.accentYellow),
              ],
            ),
          );
        },
      ),
    );
  }
}
