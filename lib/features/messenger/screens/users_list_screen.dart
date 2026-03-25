import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import '../../core/constants/app_colors.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  String searchQuery = ""; // Stocke le texte de recherche

  @override
  Widget build(BuildContext context) {
    final currentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        // --- BARRE DE RECHERCHE DANS L'APPBAR ---
        title: TextField(
          autofocus: false,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: "Rechercher un champion...",
            hintStyle: TextStyle(color: Colors.white24, fontSize: 16),
            border: InputBorder.none,
            prefixIcon:
                Icon(Icons.search, color: AppColors.accentYellow, size: 20),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery =
                  value.toLowerCase(); // Met à jour la liste en temps réel
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Aucun utilisateur sur WIZZY",
                    style: TextStyle(color: Colors.white24)));
          }

          // --- LOGIQUE DE FILTRAGE ---
          final users = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['username'] ?? "").toString().toLowerCase();

            // On exclut soi-même ET on vérifie si le nom contient la recherche
            return doc.id != currentId && name.contains(searchQuery);
          }).toList();

          if (users.isEmpty) {
            return const Center(
              child: Text("Aucun résultat pour cette recherche.",
                  style: TextStyle(color: Colors.white24)),
            );
          }

          // --- LA LISTVIEW STYLE "WIZZY" ---
          return ListView.builder(
            itemCount: users.length,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        AppColors.primaryPurple.withValues(alpha: 0.2),
                    backgroundImage: NetworkImage(
                      userData['photoUrl'] ??
                          "https://ui-avatars.com/api/?name=${userData['username']}&background=random",
                    ),
                  ),
                  title: Text(
                    userData['username'] ?? "Champion",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: const Text(
                    "Disponible pour un duel ⚡️",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.white24, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: userId,
                          receiverName: userData['username'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
