import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String patientId;  // The patient ID for identifying the chat
  final String therapistId; // The therapist ID for the chat

  ChatScreen({required this.patientId, required this.therapistId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();

  void _sendMessage(String sender) async {
    if (_messageController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.therapistId)
          .collection(widget.patientId)
          .add({
        'sender': sender,  // Either 'therapist' or 'patient'
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
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
        title: Text("Chat"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.therapistId)
                  .collection(widget.patientId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  reverse: true,  // Reverse to show the most recent message at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isTherapist = message['sender'] == 'therapist';
                    return _buildMessageBubble(
                      message['text'],
                      isTherapist,
                    );
                  },
                );
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
                  onPressed: () {
                    // Determine who is sending the message
                    // If therapist, pass 'therapist' as the sender
                    _sendMessage('therapist');
                    // If patient, pass 'patient' as the sender
                    // _sendMessage('patient');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
