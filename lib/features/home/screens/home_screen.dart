import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- TES IMPORTS ---
import '../../core/constants/app_colors.dart';
import '../../../shared/widgets/dls_card.dart';
import '../../quiz/screens/arena_menu_screen.dart';
import '../../marketplace/screens/marketplace_screen.dart';
import '../../messenger/screens/users_list_screen.dart';
import '../../ai_assistant/screens/ai_chat_screen.dart';
import '../../profile/screens/settings_screen.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../quiz/screens/lucky_draw_screen.dart'; // Import du Tirage

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fonction pour ajouter les points de récompense pub
  Future<void> _addAdReward(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'points': FieldValue.increment(50),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Récompense : +50 PTS WIZZY ! "),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Effet de halo violet en haut
          Positioned(
              top: -50, left: -50, child: _glow(AppColors.primaryPurple)),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- HEADER & AVATAR ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("WIZZY",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1)),
                        _userAvatar(context, user),
                      ],
                    ),
                  ),
                ),

                // --- BANNIÈRE POINTS ---
                SliverToBoxAdapter(child: _buildPointsBanner(user?.uid ?? "")),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 24, top: 30, bottom: 15),
                    child: Text("SÉLECTION ÉLITE",
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2)),
                  ),
                ),

                // --- GRILLE DLS (4 CARTES) ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildListDelegate([
                      DlsCard(
                        title: "QUIZ",
                        subtitle: "GLORY MODE",
                        rating: "98",
                        icon: FontAwesomeIcons.bolt,
                        color: Colors.amber,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ArenaMenuScreen())),
                      ),
                      DlsCard(
                        title: "MARKETPLACE",
                        subtitle: "RARE ITEMS",
                        rating: "94",
                        icon: FontAwesomeIcons.bagShopping,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MarketplaceScreen())),
                      ),
                      DlsCard(
                        title: "MESSENGER",
                        subtitle: "SOCIAL HUB",
                        rating: "88",
                        icon: FontAwesomeIcons.comments,
                        color: Colors.greenAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UsersListScreen())),
                      ),
                      DlsCard(
                        title: "WIZZY AI",
                        subtitle: "AI BRAIN",
                        rating: "99",
                        icon: FontAwesomeIcons.brain,
                        color: Colors.deepPurpleAccent,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AIChatScreen())),
                      ),
                    ]),
                  ),
                ),

                // --- SECTION MONÉTISATION (PUB + TIRAGE) ---
                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                SliverToBoxAdapter(child: _buildAdCard(context)), // La Pub

                SliverToBoxAdapter(
                    child: _buildLuckyDrawCard(
                        context)), // Le Tirage (C'est lui !)

                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LES WIDGETS INTERNES ---

  Widget _glow(Color c) => Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withValues(alpha: 0.15),
          boxShadow: [
            BoxShadow(
                color: c.withValues(alpha: 0.1),
                blurRadius: 100,
                spreadRadius: 50)
          ]));

  Widget _userAvatar(BuildContext context, User? user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        bool isAdmin = data?['isAdmin'] ?? false;
        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SettingsScreen())),
          onLongPress: isAdmin
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()))
              : null,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.accentYellow])),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black,
              backgroundImage: NetworkImage(data?['photoUrl'] ??
                  "https://ui-avatars.com/api/?name=${data?['username'] ?? 'W'}&background=6200EE&color=fff"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsBanner(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        int pts =
            (snapshot.data?.data() as Map<String, dynamic>?)?['points'] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("POINTS WIZZY",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 5),
                  Text("$pts",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900)),
                ]),
                const Icon(FontAwesomeIcons.boltLightning,
                    color: AppColors.accentYellow, size: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => _addAdReward(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.blueAccent.withValues(alpha: 0.2),
                Colors.transparent
              ]),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: Colors.blueAccent.withValues(alpha: 0.3))),
          child: Row(children: const [
            Icon(Icons.play_circle_fill, color: Colors.blueAccent),
            SizedBox(width: 15),
            Text("VOIR UNE PUB (+50 PTS)",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildLuckyDrawCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LuckyDrawScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.amber.withValues(alpha: 0.2),
                Colors.transparent
              ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3))),
          child: Row(children: const [
            Icon(FontAwesomeIcons.gift, color: Colors.amber),
            SizedBox(width: 15),
            Text("TIRAGE AU SORT MENSUEL",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ]),
        ),
      ),
    );
  }
}
