import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'package:wizzy/features/messenger/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen(
      {super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final String currentId = FirebaseAuth.instance.currentUser!.uid;

  String getChatId() {
    List<String> ids = [currentId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(getChatId());

    // On utilise bien MessageModel ici
    final messageData = MessageModel(
      senderId: currentId,
      text: _messageController.text.trim(),
      timestamp: Timestamp.now(),
    );

    _messageController.clear();

    await chatRef.collection('messages').add(messageData.toMap());

    await chatRef.set({
      'lastMessage': messageData.text,
      'lastTimestamp': messageData.timestamp,
      'participants': [currentId, widget.receiverId],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.receiverName, style: const TextStyle(fontSize: 16)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId())
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Utilisation de MessageModel pour parser les données
                    final msg = MessageModel.fromFirestore(
                        docs[index].data() as Map<String, dynamic>);
                    bool isMe = msg.senderId == currentId;
                    return _buildBubble(msg.text, isMe);
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPurple : Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Écris ici...",
                hintStyle: const TextStyle(color: Colors.white24),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: AppColors.primaryPurple)),
        ],
      ),
    );
  }
}
