import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'tournament_game_screen.dart'; // Import de l'écran de jeu synchrone

class TournamentLobbyScreen extends StatefulWidget {
  const TournamentLobbyScreen({super.key});

  @override
  State<TournamentLobbyScreen> createState() => _TournamentLobbyScreenState();
}

class _TournamentLobbyScreenState extends State<TournamentLobbyScreen> {
  final String tourneyId = "battle_royale_01"; // ID unique du tournoi
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _joinLobby();
  }

  // Ajoute l'utilisateur à la liste des joueurs et initialise son score à 0
  void _joinLobby() async {
    await FirebaseFirestore.instance
        .collection('tournaments')
        .doc(tourneyId)
        .set({
      'players': FieldValue.arrayUnion([currentUid]),
      'status': 'waiting',
      'scores.$currentUid': 0, // Initialisation du score du joueur
      'lastUpdate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LOBBY BATTLE ROYALE",
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        leading: const BackButton(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tourneyId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Erreur de connexion"));
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List players = data['players'] ?? [];
          final int count = players.length;
          final String status = data['status'] ?? 'waiting';

          // --- LOGIQUE DE REDIRECTION AUTOMATIQUE ---
          // Dès que le statut passe à 'starting' (changé par l'admin ou auto), on change d'écran
          if (status == 'starting' || status == 'active') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TournamentGameScreen(tournamentId: tourneyId)),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),

                // Radar Central avec décompte
                _buildRadar(count),

                const SizedBox(height: 50),

                Text(
                  "$count / 5 JOUEURS",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text(
                  "En attente de combattants...",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                      fontStyle: FontStyle.italic),
                ),

                const SizedBox(height: 50),

                // Grille visuelle des 5 places
                SizedBox(
                  height: 120,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      bool isFilled = index < count;
                      return CircleAvatar(
                        backgroundColor: isFilled
                            ? AppColors.primaryPurple
                            : Colors.white.withValues(alpha: 0.05),
                        child: Icon(
                          isFilled ? Icons.bolt : Icons.person_outline,
                          color: isFilled
                              ? AppColors.accentYellow
                              : Colors.white10,
                          size: 18,
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Bouton d'action (visible si on est 5)
                if (count >= 5)
                  _buildStartButton()
                else
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    color: AppColors.primaryPurple,
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRadar(int count) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercles animés (statiques ici, mais l'effet est là)
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.2),
                width: 1),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: 0.4),
                width: 2),
          ),
        ),
        // Le Chiffre
        Text(
          "$count",
          style: const TextStyle(
              color: AppColors.accentYellow,
              fontSize: 72,
              fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () async {
        // L'admin ou le 5ème joueur peut déclencher le départ pour tout le monde
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tourneyId)
            .update({
          'status': 'starting',
          'startTime': FieldValue.serverTimestamp(),
        });
      },
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          gradient:
              const LinearGradient(colors: [Colors.greenAccent, Colors.green]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.green.withValues(alpha: 0.3), blurRadius: 20)
          ],
        ),
        child: const Center(
          child: Text(
            "COMMENCER LE TOURNOI",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
