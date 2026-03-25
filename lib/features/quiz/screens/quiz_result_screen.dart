import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/app_colors.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final bool isTournament;
  final int? rank; // Pour le mode tournoi

  const QuizResultScreen({
    super.key, 
    required this.score, 
    required this.totalQuestions,
    this.isTournament = false,
    this.rank,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // On ne joue les confettis et le son de victoire que si le score est bon
    if (widget.score > 0) {
      _confettiController.play();
      _playWinSound();
    }
  }

  void _playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.amber, AppColors.primaryPurple, AppColors.accentYellow],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isTournament ? "RÉSULTAT TOURNOI" : "SESSION TERMINÉE",
                  style: const TextStyle(color: Colors.white38, letterSpacing: 3, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 10),
                if (widget.isTournament && widget.rank != null)
                  Text("RANG #${widget.rank}", style: const TextStyle(color: AppColors.accentYellow, fontSize: 40, fontWeight: FontWeight.w900)),
                
                Text("${widget.score} PTS", style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900)),
                
                const SizedBox(height: 30),
                _buildBadge(),
                const SizedBox(height: 60),
                
                ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("RETOUR AU MENU", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    String label = "NOVICE";
    Color col = Colors.grey;
    double ratio = widget.score / (widget.totalQuestions * 10);

    if (ratio >= 0.9) { label = "LÉGENDE"; col = Colors.amber; }
    else if (ratio >= 0.7) { label = "EXPERT"; col = Colors.blueAccent; }
    else if (ratio >= 0.5) { label = "PRO"; col = Colors.purpleAccent; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: col, width: 2),
      ),
      child: Text(label, style: TextStyle(color: col, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }
}