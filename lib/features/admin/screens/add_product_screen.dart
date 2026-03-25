import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();
  final _waController = TextEditingController();

  void _saveProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('products').add({
      'name': _nameController.text,
      'price': int.parse(_priceController.text),
      'imageUrl': _urlController.text,
      'sellerWhatsApp': _waController.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
          title: const Text("NOUVEAU PRODUIT",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _input("Nom de l'article", _nameController),
            _input("Prix (CFA)", _priceController, isNum: true),
            _input("Lien de l'image (URL)", _urlController),
            _input("WhatsApp (ex: 22960000000)", _waController),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProduct,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  minimumSize: const Size(double.infinity, 55)),
              child: const Text("METTRE EN VENTE"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
