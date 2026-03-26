import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../models/question_model.dart';
import '../../core/services/notification_service.dart';
import 'quiz_result_screen.dart';

class TournamentGameScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentGameScreen({super.key, required this.tournamentId});

  @override
  State<TournamentGameScreen> createState() => _TournamentGameScreenState();
}

class _TournamentGameScreenState extends State<TournamentGameScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _isAnswered = false;
  String _selectedAnswer = "";
  int _myScore = 0;
  bool _hasFinishedFired = false;

  @override
  void initState() {
    super.initState();
    _startMusic();
  }

  void _startMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/quiz_bg.mp3'));
      await _musicPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint("Erreur musique tournoi : $e");
    }
  }

  @override
  void dispose() {
    _musicPlayer.stop();
    _musicPlayer.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE RÉPONSE ---
  void _submitAnswer(
      Question q, String selected, int currentIndex, int totalQuestions) async {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selected;
      if (selected == q.correctAnswer) {
        _myScore += 10;
      }
    });

    // Mise à jour du score dans Firestore pour le classement en direct
    await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(widget.tournamentId)
        .update({'scores.$currentUid': _myScore});

    // Attendre 2 secondes et passer à la suite
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;

      if (currentIndex < totalQuestions - 1) {
        // L'admin change l'index de question dans Firestore (ou on le fait auto ici pour le test)
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentId)
            .update({'currentQuestionIndex': FieldValue.increment(1)});

        setState(() {
          _isAnswered = false;
          _selectedAnswer = "";
        });
      } else {
        // C'est la fin du tournoi
        _handleTournamentEnd();
      }
    });
  }

  // --- FIN DU TOURNOI ---
  void _handleTournamentEnd() async {
    if (_hasFinishedFired) return;
    _hasFinishedFired = true;

    var doc = await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(widget.tournamentId)
        .get();
    Map<String, dynamic> scores = doc['scores'] ?? {};

    // Trier pour trouver le gagnant
    var sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    String winnerId = sorted.first.key;
    int myRank = sorted.indexWhere((e) => e.key == currentUid) + 1;

    // Si je suis le gagnant, je reçois une notification et des points bonus
    if (currentUid == winnerId) {
      await NotificationService().showVictoryNotification("Battle Royale");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .update({
        'points': FieldValue.increment(200), // Bonus vainqueur
      });
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            score: _myScore,
            totalQuestions: (doc['questionIds'] as List).length,
            isTournament: true,
            rank: myRank,
          ),
        ),
      );
    }
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
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          var tourneyData = snapshot.data!.data() as Map<String, dynamic>;
          int qIndex = tourneyData['currentQuestionIndex'] ?? 0;
          List qIds = tourneyData['questionIds'] ?? [];
          Map scores = tourneyData['scores'] ?? {};

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('questions')
                .doc(qIds[qIndex])
                .snapshots(),
            builder: (context, qSnapshot) {
              if (!qSnapshot.hasData || !qSnapshot.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              var q = Question.fromFirestore(
                  qSnapshot.data!.data() as Map<String, dynamic>,
                  qSnapshot.data!.id);

              return SafeArea(
                child: Column(
                  children: [
                    // Header de synchronisation et Leaderboard Live
                    _buildLiveLeaderboard(scores, qIndex, qIds.length),

                    const SizedBox(height: 30),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        q.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: q.options
                            .map((opt) =>
                                _buildOption(opt, q, qIndex, qIds.length))
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

  Widget _buildLiveLeaderboard(Map scores, int current, int total) {
    var sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("QUESTION ${current + 1}/$total",
                  style: const TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
              const Icon(Icons.bolt, color: AppColors.accentYellow, size: 16),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedEntries.length,
              itemBuilder: (context, index) {
                bool isMe = sortedEntries[index].key == currentUid;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryPurple
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isMe ? AppColors.accentYellow : Colors.white10),
                  ),
                  child: Center(
                    child: Text(
                      "#${index + 1} : ${sortedEntries[index].value} PTS",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(String text, Question q, int index, int total) {
    Color color = Colors.white.withValues(alpha: 0.05);
    Color border = Colors.white10;

    if (_isAnswered) {
      if (text == q.correctAnswer) {
        color = Colors.greenAccent.withValues(alpha: 0.2);
        border = Colors.greenAccent;
      } else if (text == _selectedAnswer) {
        color = Colors.redAccent.withValues(alpha: 0.2);
        border = Colors.redAccent;
      }
    }

    return GestureDetector(
      onTap: () => _submitAnswer(q, text, index, total),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
