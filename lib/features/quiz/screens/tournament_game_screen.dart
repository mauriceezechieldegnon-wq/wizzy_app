import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../models/question_model.dart';
import 'package:audioplayers/audioplayers.dart';
class TournamentGameScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentGameScreen({super.key, required this.tournamentId});

  @override
  State<TournamentGameScreen> createState() => _TournamentGameScreenState();
}

class _TournamentGameScreenState extends State<TournamentGameScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  bool _isAnswered = false;
  String _selectedAnswer = "";
  int _myScore = 0;

  void _submitAnswer(Question q, String selected) async {
    if (_isAnswered) return;
    setState(() {
      _isAnswered = true;
      _selectedAnswer = selected;
      if (selected == q.correctAnswer) _myScore += 10;
      final AudioPlayer _bgMusic = AudioPlayer();

@override
void initState() {
  super.initState();
  _startMusic();
}

void _startMusic() async {
  await _bgMusic.setReleaseMode(ReleaseMode.loop);
  await _bgMusic.play(AssetSource('sounds/quiz_bg.mp3'));
  await _bgMusic.setVolume(0.4); // Musique douce pour ne pas gêner
}

@override
void dispose() {
  _bgMusic.stop();
  _bgMusic.dispose();
  super.dispose();
}
    });

    // Mettre à jour mon score en temps réel dans Firestore pour le Leaderboard
    await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(widget.tournamentId)
        .update({'scores.$currentUid': _myScore});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var data = snapshot.data!.data() as Map<String, dynamic>;
          int qIndex = data['currentQuestionIndex'] ?? 0;
          Map scores = data['scores'] ?? {};
          List qIds = data['questionIds'] ?? [];

          // Si le tournoi est fini
          if (data['status'] == 'finished')
            return _buildFinalLeaderboard(scores);

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(qIds[qIndex])
                .snapshots(),
            builder: (context, qSnapshot) {
              if (!qSnapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              var q = Question.fromFirestore(
                  qSnapshot.data!.data() as Map<String, dynamic>,
                  qSnapshot.data!.id);

              return SafeArea(
                child: Column(
                  children: [
                    _buildSyncHeader(qIndex, qIds.length, scores),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(q.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: q.options
                            .map((opt) => _buildOption(opt, q))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSyncHeader(int current, int total, Map scores) {
    // Trier les scores pour voir qui est premier
    var sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.03),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("QUESTION ${current + 1}/$total",
                  style: const TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.bold)),
              Text("MON SCORE: $_myScore",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          const Text("CLASSEMENT LIVE",
              style: TextStyle(color: Colors.white24, fontSize: 10)),
          const SizedBox(height: 5),
          SizedBox(
            height: 30,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                bool isMe = sortedEntries[index].key == currentUid;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryPurple : Colors.white10,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                          "#${index + 1} : ${sortedEntries[index].value} PTS",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10))),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String text, Question q) {
    Color color = Colors.white.withValues(alpha: 0.05);
    if (_isAnswered) {
      if (text == q.correctAnswer)
        color = Colors.greenAccent.withValues(alpha: 0.3);
      else if (text == _selectedAnswer)
        color = Colors.redAccent.withValues(alpha: 0.3);
    }
    return GestureDetector(
      onTap: () => _submitAnswer(q, text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFinalLeaderboard(Map scores) {
    return Center(
        child: Text("FIN DU TOURNOI", style: TextStyle(color: Colors.white)));
  }
}
void _finishTournament() async {
  // 1. Calculer le gagnant
  var snap = await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).get();
  Map<String, dynamic> scores = snap['scores'];
  
  // Trouver l'UID avec le plus gros score
  String winnerId = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  

  // 2. Mettre à jour Firestore
  await FirebaseFirestore.instance.collection('tournaments').doc(widget.tournamentId).update({
    'status': 'finished',
    'winnerId': winnerId,
  });

  // 3. Si c'est moi le gagnant, je reçois un bonus spécial
  if (currentUid == winnerId) {
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'points': FieldValue.increment(500), // Bonus de 500 points pour le vainqueur
    });
  }
  // Si l'utilisateur a le meilleur score
if (isWinner) {
  NotificationService().showVictoryNotification("Battle Royale #5");
}
}