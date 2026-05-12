import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wizzy/core/constants/app_colors.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: "AIzaSyCk9922Fpk9ijZj_tE9QX2HoV4Jm7sFSPY", // <--- GUILLEMETS AJOUTÉS
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;
    String userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": userText});
      _isLoading = true;
    });
    _controller.clear();
    try {
      final response = await _model.generateContent([Content.text(userText)]);
      setState(() {
        _messages.add({"role": "ai", "text": response.text ?? "Désolé..."});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai"
