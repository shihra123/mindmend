import 'package:flutter/material.dart';

class TherapistNotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "patient": "John Doe",
      "message": "Hello, I need to reschedule my session."
    },
    {"patient": "Jane Smith", "message": "Thank you for today's session!"},
    {"patient": "Michael Lee", "message": "Can we have a quick chat?"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Messages"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(notifications[index]["patient"]!),
              subtitle: Text(notifications[index]["message"]!),
              trailing:
                  Icon(Icons.arrow_forward, color: Colors.deepOrangeAccent),
              onTap: () {
                // Navigate to chat screen with the patient
              },
            ),
          );
        },
      ),
    );
  }
}
