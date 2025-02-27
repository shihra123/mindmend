import 'package:flutter/material.dart';

class Therapist {
  final String name;
  bool isBooked;

  Therapist({required this.name, this.isBooked = false});

  // Store messages for each therapist
  List<String> messages = [];
}

class UserMessagingScreen extends StatefulWidget {
  const UserMessagingScreen({super.key});

  @override
  State<UserMessagingScreen> createState() => _UserMessagingScreenState();
}

class _UserMessagingScreenState extends State<UserMessagingScreen> {
  // List of therapists
  List<Therapist> therapists = [
    Therapist(name: "Dr. Smith - Psychologist"),
    Therapist(name: "Dr. Johnson - Psychiatrist"),
    Therapist(name: "Dr. Brown - Counselor"),
    Therapist(name: "Dr. Williams - Therapist"),
    Therapist(name: "Dr. Davis - Mental Health Coach"),
  ];

  // Controller for the message input
  final TextEditingController _messageController = TextEditingController();

  // Function to open the dialog and send message
  void _openMessageDialog(Therapist therapist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Message ${therapist.name}"),
          content: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "Type your message...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Send message and close dialog
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    therapist.messages.add(_messageController.text.trim());
                  });
                }
                _messageController.clear();
                Navigator.pop(context);
              },
              child: Text("Send"),
            ),
            TextButton(
              onPressed: () {
                // Close dialog without sending
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Therapist"),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: therapists.length,
        itemBuilder: (context, index) {
          final therapist = therapists[index];

          return ListTile(
            title: Text(therapist.name),
            trailing: IconButton(
              icon: Icon(Icons.message),
              onPressed: therapist.isBooked
                  ? () => _openMessageDialog(therapist)
                  : null, // Only allow messaging if the appointment is booked
            ),
            onTap: therapist.isBooked
                ? () {
                    // Optionally, show all previous messages when tapped
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Messages with ${therapist.name}"),
                          content: ListView.builder(
                            itemCount: therapist.messages.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(therapist.messages[index]),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Close"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                : null, // Show message history only if appointment is booked
          );
        },
      ),
    );
  }
}
