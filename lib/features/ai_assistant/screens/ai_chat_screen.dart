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
      apiKey: "AIzaSyCk9922Fpk9ijZj_tE9QX2HoV4Jm7sFSPY", 
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
      setState(() { _messages.add({"role": "ai", "text": response.text ?? "Désolé..."}); });
    } catch (e) {
      setState(() { _messages.add({"role": "ai", "text": "Erreur..."}); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("IA WIZZY", style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['role'] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: msg['role'] == "user" ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
                    child: Text(msg['text']!, style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(padding: const EdgeInsets.all(20), child: Row(children: [Expanded(child: TextField(controller: _controller, style: const TextStyle(color: Colors.white))), IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: AppColors.accentYellow))])),
        ],
      ),
    );
  }
}
