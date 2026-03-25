import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Charger les infos actuelles pour les afficher dans les cases
  void _loadUserData() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
        if (!mounted) return;
    if (doc.exists) {
      setState(() {
        _nameController.text = doc['username'] ?? '';
        _whatsappController.text = doc['whatsapp'] ?? '';
      });
    }
  }

  void _saveChanges() async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'username': _nameController.text,
      'whatsapp': _whatsappController.text,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profil mis à jour ! ✅")));
  }

  // ignore: unused_field
  File? _pickedImage;

// ignore: unused_element
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50); // Qualité réduite pour économiser de l'espace

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        if (!mounted) return;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
          backgroundColor: Colors.transparent, title: const Text("PARAMÈTRES")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildField("Nouveau Pseudo", _nameController),
            _buildField("Nouveau WhatsApp", _whatsappController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  minimumSize: const Size(double.infinity, 55)),
              child: const Text("SAUVEGARDER LES MODIFS"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => FirebaseAuth.instance
                  .sendPasswordResetEmail(email: user!.email!),
              child: const Text("Réinitialiser le mot de passe par email",
                  style: TextStyle(color: AppColors.accentYellow)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
