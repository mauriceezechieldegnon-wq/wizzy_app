import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _qController = TextEditingController();
  final _aController = TextEditingController(); // Juste
  final _w1Controller = TextEditingController(); // Faux 1
  final _w2Controller = TextEditingController(); // Faux 2
  final _w3Controller = TextEditingController(); // Faux 3
  String _selectedCat = "SPORT";

  void _saveQuestion() async {
    await FirebaseFirestore.instance.collection('questions').add({
      'label': _qController.text,
      'correctAnswer': _aController.text,
      'options': [
        _aController.text,
        _w1Controller.text,
        _w2Controller.text,
        _w3Controller.text
      ]..shuffle(),
      'category': _selectedCat,
      'points': 10,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(title: const Text("NOUVELLE QUESTION")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCat,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              items: ["SPORT", "TECH", "CULTURE G", "HISTOIRE"]
                  .map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCat = val!),
            ),
            const SizedBox(height: 20),
            _input("La question", _qController),
            _input("Bonne réponse", _aController),
            _input("Fausse réponse 1", _w1Controller),
            _input("Fausse réponse 2", _w2Controller),
            _input("Fausse réponse 3", _w3Controller),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _saveQuestion, child: const Text("AJOUTER AU QUIZ")),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label)),
    );
  }
}
