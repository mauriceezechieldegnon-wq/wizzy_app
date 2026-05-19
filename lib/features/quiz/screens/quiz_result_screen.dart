import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:wizzy/core/constants/app_colors.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  const QuizResultScreen({super.key, required this.score, required this.totalQuestions});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(confettiController: _controller, blastDirectionality: BlastDirectionality.explosive),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${widget.score} PTS", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("QUITTER")),
            ],
          ),
        ],
      ),
    );
  }
}
