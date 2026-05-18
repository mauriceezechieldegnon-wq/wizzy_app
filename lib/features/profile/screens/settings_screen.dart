import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wizzy/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  void _save() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'username': _nameController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OK !")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("SETTINGS")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameController, style: const TextStyle(color: Colors.white)),
            TextField(controller: _whatsappController, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("SAUVEGARDER")),
          ],
        ),
      ),
    );
  }
}
