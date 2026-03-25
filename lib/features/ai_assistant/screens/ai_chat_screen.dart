import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants/app_colors.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Dans ton State
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: 'AIzaSyCk9922Fpk9ijZj_tE9QX2HoV4Jm7sFSPY',
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
      // Pour la version 0.4.7, on utilise Content.text()
      final content = [Content.text(userText)];
      final response = await _model.generateContent(content);

      setState(() {
        _messages.add({
          "role": "ai",
          "text": response.text ?? "Je n'ai pas pu générer de réponse."
        });
      });
    } catch (e) {
      debugPrint("ERREUR IA : $e");
      setState(() {
        String errorMsg = " WIZZY dort... Réessaie plus tard.";
        if (e.toString().contains("API_KEY_INVALID")) {
          errorMsg = "Ta clé API n'est pas valide.";
        }
        _messages.add({"role": "ai", "text": errorMsg});
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(" WIZZY",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      bool isMe = msg['role'] == "user";
                      return _buildChatBubble(msg['text']!, isMe);
                    },
                  ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
                color: AppColors.accentYellow,
                backgroundColor: Colors.transparent),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome,
              size: 80, color: AppColors.primaryPurple.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text(
            "Pose-moi n'importe quelle question !",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryPurple
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: isMe ? null : Border.all(color: Colors.white10),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border:
            Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        // Ajout du SafeArea pour que ça ne soit pas caché par le bas de l'écran
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Demande-moi n'importe quoi...",
                  hintStyle:
                      const TextStyle(color: Colors.white24, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.accentYellow,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded,
                    color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
