import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [
    {"sender": "patient", "text": "Hello, doctor!"},
    {"sender": "therapist", "text": "Hi! How can I assist you today?"},
    {"sender": "patient", "text": "I’ve been feeling anxious lately."},
    {"sender": "therapist", "text": "I'm here to help. Can you tell me more?"},
  ];

  TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add({"sender": "therapist", "text": _messageController.text});
      });
      _messageController.clear();
    }
  }

  Widget _buildMessageBubble(String text, bool isTherapist) {
    return Align(
      alignment: isTherapist ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isTherapist ? Colors.deepOrangeAccent : Colors.blueAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isTherapist ? Radius.circular(12) : Radius.zero,
            bottomRight: isTherapist ? Radius.zero : Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Patient"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isTherapist = messages[index]["sender"] == "therapist";
                return _buildMessageBubble(
                    messages[index]["text"]!, isTherapist);
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.deepOrangeAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
