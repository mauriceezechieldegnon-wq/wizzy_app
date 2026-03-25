import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../models/question_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
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
  bool _isSaving = false;

  // Vérification de la réponse avec feedback visuel
  void _checkAnswer(Question q, String selected) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswer = selected;
      if (selected == q.correctAnswer) {
        _totalScore += q.points;
      }
      final AudioPlayer _bgMusic = AudioPlayer();

@override
void initState() {
  super.initState();
  _startMusic();
}

void _startMusic() async {
  await _bgMusic.setReleaseMode(ReleaseMode.loop);
  await _bgMusic.play(AssetSource('sounds/quiz_bg.mp3'));
  await _bgMusic.setVolume(0.4); 
}

@override
void dispose() {
  _bgMusic.stop();
  _bgMusic.dispose();
  super.dispose();
}
    });

    // On attend 1.5s pour que le joueur voit s'il a eu bon (Vert/Rouge)
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswer = "";
        });
      }
    });
  }

  // Sauvegarde des points (Fonctionne même en Offline grâce à la persistance Firestore)
  Future<void> _finishAndSave() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // On utilise FieldValue.increment pour que Firestore gère l'addition
      // tout seul dès que la connexion revient.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'points': FieldValue.increment(_totalScore),
      });

      if (mounted) {
        // Retour à l'accueil
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("Erreur sauvegarde : $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
        // On active l'écoute des changements de métadonnées pour le mode hors-ligne
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where('category', isEqualTo: widget.category)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(
                child: Text("Erreur de chargement",
                    style: TextStyle(color: Colors.white)));

          // Pendant le premier chargement (si le cache est vide)
          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          var questions = snapshot.data!.docs.map((doc) {
            return Question.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          // Cas où la catégorie est vide
          if (questions.isEmpty) {
            return _buildEmptyState();
          }

          // Si le joueur a fini toutes les questions de la liste
          if (_currentIndex >= questions.length) {
            return _buildResultScreen();
          }

          final currentQ = questions[_currentIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Barre de progression style "DLS"
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
                      fontSize: 12,
                      letterSpacing: 1),
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

                // Liste des réponses
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: currentQ.options
                        .map((option) =>
                            _buildOptionCard(option, currentQ.correctAnswer))
                        .toList(),
                  ),
                ),

                // Indicateur de mode Hors-Ligne
                if (snapshot.data!.metadata.isFromCache)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text("Mode Hors-Ligne Actif 📡",
                        style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(String text, String correct) {
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
          text),
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
                      fontWeight: FontWeight.w600)),
            ),
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
          const Text("Catégorie en préparation...",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuizResultScreen(score: _totalScore, totalQuestions: questions.length)));
              child: const Text("RETOUR",
                  style: TextStyle(color: AppColors.accentYellow))),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SESSION TERMINÉE",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const SizedBox(height: 10),
            Text("+$_totalScore PTS",
                style: const TextStyle(
                    color: AppColors.accentYellow,
                    fontSize: 48,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text("Bien joué, champion !",
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _isSaving ? null : _finishAndSave,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryPurple, Color(0xFF9D50BB)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.3),
                        blurRadius: 20)
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("RÉCUPÉRER MES POINTS",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

final AudioPlayer _musicPlayer = AudioPlayer();

@override
void initState() {
  super.initState();
  _playMusic();
}

void _playMusic() async {
  await _musicPlayer.setReleaseMode(ReleaseMode.loop); // Boucle
  await _musicPlayer.play(AssetSource('sounds/quiz_bg.mp3'));
}

@override
void dispose() {
  _musicPlayer.stop(); // Arrête la musique quand on quitte
  super.dispose();
}
}
