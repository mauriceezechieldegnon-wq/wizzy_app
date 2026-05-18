import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wizzy/core/constants/app_colors.dart';
import 'package:wizzy/core/services/notification_service.dart';
import 'package:wizzy/features/admin/screens/add_product_screen.dart';
import 'package:wizzy/features/admin/screens/add_question_screen.dart';
import 'package:share_plus/share_plus.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("WIZZY ADMIN")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _tile(context, "PRODUIT", FontAwesomeIcons.plus, Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen()))),
          _tile(context, "QUESTION", FontAwesomeIcons.question, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestionScreen()))),
          _tile(context, "EXPORT CSV", FontAwesomeIcons.fileCsv, Colors.green, () async {
             var snap = await FirebaseFirestore.instance.collection('users').get();
             String csv = "User,WhatsApp\n";
             for (var d in snap.docs) { csv += "${d['username']},${d['whatsapp']}\n"; }
             Share.share(csv);
          }),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String t, IconData i, Color c, VoidCallback o) {
    return ListTile(
      onTap: o,
      leading: Icon(i, color: c),
      title: Text(t, style: const TextStyle(color: Colors.white)),
      tileColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
