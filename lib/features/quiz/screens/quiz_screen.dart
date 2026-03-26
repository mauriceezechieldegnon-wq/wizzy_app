import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart'; // Import au bon endroit
import '../../core/constants/app_colors.dart';
import '../models/question_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _totalScore = 0;
  bool _isAnswered = false;
  String _selectedAnswer = "";
  final bool _isSaving = false;

  // Gestion du son
  final AudioPlayer _musicPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startMusic();
  }

  void _startMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/quiz_bg.mp3'));
      await _musicPlayer.setVolume(0.4);
    } catch (e) {
      debugPrint("Musique non chargée : $e");
    }
  }

  @override
  void dispose() {
    _musicPlayer.stop();
    _musicPlayer.dispose();
    super.dispose();
  }

  void _checkAnswer(Question q, String selected, int totalCount) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selected;
      if (selected == q.correctAnswer) {
        _totalScore += q.points;
      }
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (_currentIndex < totalCount - 1) {
          setState(() {
            _currentIndex++;
            _isAnswered = false;
            _selectedAnswer = "";
          });
        } else {
          // Si c'est la dernière question, on va vers l'écran de résultat
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(
                score: _totalScore,
                totalQuestions: totalCount,
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.category,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white38,
                letterSpacing: 2)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where('category', isEqualTo: widget.category)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(
                child: Text("Erreur", style: TextStyle(color: Colors.white)));
          if (!snapshot.hasData)
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));

          var questions = snapshot.data!.docs.map((doc) {
            return Question.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          if (questions.isEmpty) return _buildEmptyState();

          // On s'assure que l'index ne dépasse pas la liste au cas où
          if (_currentIndex >= questions.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentQ = questions[_currentIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / questions.length,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    color: AppColors.accentYellow,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "QUESTION ${_currentIndex + 1} / ${questions.length}",
                  style: const TextStyle(
                      color: AppColors.accentYellow,
                      fontWeight: FontWeight.w800,
                      fontSize: 12),
                ),
                const SizedBox(height: 20),
                Text(
                  currentQ.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView(
                    children: currentQ.options
                        .map((option) => _buildOptionCard(
                            option, currentQ.correctAnswer, questions.length))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(String text, String correct, int totalCount) {
    bool isCorrect = text == correct;
    bool isSelected = text == _selectedAnswer;
    Color borderColor = Colors.white.withValues(alpha: 0.1);
    Color bgColor = Colors.white.withValues(alpha: 0.03);

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = Colors.greenAccent;
        bgColor = Colors.greenAccent.withValues(alpha: 0.2);
      } else if (isSelected) {
        borderColor = Colors.redAccent;
        bgColor = Colors.redAccent.withValues(alpha: 0.2);
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(
          Question(
              id: '',
              label: '',
              options: [],
              correctAnswer: correct,
              points: 10),
          text,
          totalCount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600))),
            if (_isAnswered && isCorrect)
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
            if (_isAnswered && isSelected && !isCorrect)
              const Icon(Icons.cancel_rounded, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_motion,
              color: Colors.white10, size: 80),
          const SizedBox(height: 20),
          const Text("Bientôt disponible !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // CORRECTION ICI : Ajout du paramètre child obligatoire
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("RETOUR",
                  style: TextStyle(color: AppColors.accentYellow))),
        ],
      ),
    );
  }
}
