import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wizzy/core/constants/app_colors.dart';
import 'package:wizzy/core/services/notification_service.dart';
import 'package:wizzy/features/quiz/models/question_model.dart';
import 'package:wizzy/features/quiz/screens/quiz_result_screen.dart';

class TournamentGameScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentGameScreen({super.key, required this.tournamentId});
  @override
  State<TournamentGameScreen> createState() => _TournamentGameScreenState();
}

class _TournamentGameScreenState extends State<TournamentGameScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  int _myScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var tourneyData = snapshot.data!.data() as Map<String, dynamic>;
          int qIndex = tourneyData['currentQuestionIndex'] ?? 0;
          List qIds = tourneyData['questionIds'] ?? [];
          Map scores = tourneyData['scores'] ?? {};

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(scores, qIndex, qIds.length),
                const Spacer(),
                const Text("TOURNOI EN COURS", style: TextStyle(color: Colors.white)),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Map scores, int current, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("QUESTION ${current + 1}/$total", style: const TextStyle(color: AppColors.accentYellow, fontWeight: FontWeight.bold)),
          Text("SCORE: $_myScore", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
