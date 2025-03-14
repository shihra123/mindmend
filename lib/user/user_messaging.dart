import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Therapist {
  final String id;
  final String name;
  final bool isBooked;

  Therapist({required this.id, required this.name, required this.isBooked});

  factory Therapist.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Therapist(
      id: doc.id,
      name: data['name'],
      isBooked: data['isBooked'] ?? false,
    );
  }
}

class UserMessagingScreen extends StatefulWidget {
  @override
  State<UserMessagingScreen> createState() => _UserMessagingScreenState();
}

class _UserMessagingScreenState extends State<UserMessagingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void _openMessageDialog(Therapist therapist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Chat with ${therapist.name}"),
          content: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "Type your message...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_messageController.text.isNotEmpty) {
                  await _firestore
                      .collection("therapists")
                      .doc(therapist.id)
                      .collection("messages")
                      .add({
                    'text': _messageController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
                _messageController.clear();
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
            TextButton(
              onPressed: () {
                _messageController.clear();
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showChatHistory(Therapist therapist) {
    showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("therapists")
              .doc(therapist.id)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text("Messages with ${therapist.name}"),
                content: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AlertDialog(
                title: Text("Messages with ${therapist.name}"),
                content: Text("No messages yet."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              );
            }

            return AlertDialog(
              title: Text("Messages with ${therapist.name}"),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['text']),
                      subtitle: Text(doc['timestamp']?.toDate().toString() ?? ""),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Therapist"),
        backgroundColor: Colors.lightBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("therapists").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No therapists available."));
          }

          List<Therapist> therapists = snapshot.data!.docs
              .map((doc) => Therapist.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: therapists.length,
            itemBuilder: (context, index) {
              final therapist = therapists[index];

              return ListTile(
                title: Text(therapist.name),
                trailing: IconButton(
                  icon: Icon(Icons.message, color: therapist.isBooked ? Colors.blue : Colors.grey),
                  onPressed: therapist.isBooked ? () => _openMessageDialog(therapist) : null,
                ),
                onTap: therapist.isBooked ? () => _showChatHistory(therapist) : null,
              );
            },
          );
        },
      ),
    );
  }
}
