import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:wizzy/core/constants/app_colors.dart';
import 'package:wizzy/shared/widgets/dls_card.dart';
import 'package:wizzy/features/quiz/screens/arena_menu_screen.dart';
import 'package:wizzy/features/marketplace/screens/marketplace_screen.dart';
import 'package:wizzy/features/messenger/screens/users_list_screen.dart';
import 'package:wizzy/features/ai_assistant/screens/ai_chat_screen.dart';
import 'package:wizzy/features/profile/screens/settings_screen.dart';
import 'package:wizzy/features/admin/screens/admin_dashboard_screen.dart';
import 'package:wizzy/features/quiz/screens/lucky_draw_screen.dart';
import 'package:wizzy/features/home/screens/ad_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 900 ? 4 : 2;
    double aspectRatio = screenWidth > 900 ? 1.5 : 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          Positioned(top: -50, left: -50, child: _glow(AppColors.primaryPurple)),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("WIZZY", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        _userAvatar(context, user),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildPointsBanner(user?.uid ?? "")),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 24, top: 30, bottom: 15),
                    child: Text("SÉLECTION ÉLITE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: aspectRatio,
                    ),
                    delegate: SliverChildListDelegate([
                      DlsCard(
                        title: "L'ARÈNE", subtitle: "GLORY MODE", rating: "98", icon: FontAwesomeIcons.bolt, color: Colors.amber,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ArenaMenuScreen())),
                      ),
                      DlsCard(
                        title: "LE BAZAR", subtitle: "RARE ITEMS", rating: "94", icon: FontAwesomeIcons.bagShopping, color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketplaceScreen())),
                      ),
                      DlsCard(
                        title: "LE SALON", subtitle: "SOCIAL HUB", rating: "88", icon: FontAwesomeIcons.comments, color: Colors.greenAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersListScreen())),
                      ),
                      DlsCard(
                        title: "LE GÉNIE", subtitle: "AI BRAIN", rating: "99", icon: FontAwesomeIcons.brain, color: Colors.deepPurpleAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AIChatScreen())),
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
                SliverToBoxAdapter(child: _buildAdCard(context)),
                SliverToBoxAdapter(child: _buildLuckyDrawCard(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color c) => Container(
    width: 300, height: 300, 
    decoration: BoxDecoration(
      shape: BoxShape.circle, 
      color: c.withValues(alpha: 0.15), 
      boxShadow: [BoxShadow(color: c.withValues(alpha: 0.1), blurRadius: 100, spreadRadius: 50)]
    )
  );

  Widget _userAvatar(BuildContext context, User? user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        bool isAdmin = data?['isAdmin'] ?? false;
        String? photo = data?['photoUrl'] ?? user?.photoURL;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          onLongPress: isAdmin ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen())) : null,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primaryPurple, AppColors.accentYellow])),
            child: CircleAvatar(
              radius: 18, backgroundColor: Colors.black,
              backgroundImage: NetworkImage(photo ?? "https://ui-avatars.com/api/?name=${data?['username'] ?? 'W'}&background=6200EE&color=fff"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointsBanner(String uid) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        int pts = (snapshot.data?.data() as Map<String, dynamic>?)?['points'] ?? 0;
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
                  const Text("SOLDE WIZZY", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("$pts PTS", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                ]),
                const Icon(FontAwesomeIcons.bolt, color: AppColors.accentYellow, size: 24),
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdPlayerScreen())),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blueAccent.withValues(alpha: 0.2), Colors.transparent]),
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3))
          ),
          child: const Row(children: [
            Icon(Icons.play_circle_fill, color: Colors.blueAccent),
            SizedBox(width: 15),
            Text("REGARDER UNE VIDÉO (+15 PTS)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildLuckyDrawCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LuckyDrawScreen())),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber.withValues(alpha: 0.2), Colors.transparent]),
            borderRadius: BorderRadius.circular(24), 
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3))
          ),
          child: const Row(children: [
            Icon(FontAwesomeIcons.gift, color: Colors.amber, size: 18),
            SizedBox(width: 15),
            Text("TIRAGE AU SORT MENSUEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ]),
        ),
      ),
    );
  }
}
