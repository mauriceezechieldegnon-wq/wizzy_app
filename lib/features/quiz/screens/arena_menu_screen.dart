import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wizzy/features/home/screens/category_picker_screen.dart';
import '../../core/constants/app_colors.dart';
// ignore: unused_import
import 'quiz_screen.dart';
import 'matchmaking_screen.dart';
import 'tournament_lobby_screen.dart';

class ArenaMenuScreen extends StatelessWidget {
  const ArenaMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("L'ARÈNE",
                style: TextStyle(
                    color: AppColors.accentYellow,
                    fontSize: 36,
                    fontWeight: FontWeight.w900)),
            const Text("Choisis ton mode de combat.",
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 40),
            _buildArenaOption(
              context,
              title: "ENTRAÎNEMENT SOLO",
              subtitle: "Gagne des points pour le tirage",
              icon: FontAwesomeIcons.user,
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const CategoryPickerScreen())), // Point vers le Picker
            ),
            const SizedBox(height: 20),
            _buildArenaOption(
              context,
              title: "DUEL À PARIS",
              subtitle: "Mise tes points contre un rival",
              icon: FontAwesomeIcons.bolt,
              color: AppColors.primaryPurple,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MatchmakingScreen())),
            ),
            _buildArenaOption(
              context,
              title: "GRAND TOURNOI",
              subtitle: "10 joueurs - Le dernier gagne tout",
              icon: FontAwesomeIcons.crown,
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TournamentLobbyScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArenaOption(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: color,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                      const Text("Clique pour commencer",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white24, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
