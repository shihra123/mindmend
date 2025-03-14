import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TherapistNotificationsScreen extends StatelessWidget {
  final String therapistId; // Passed from another screen, identifies the therapist

  TherapistNotificationsScreen({required this.therapistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Reminders"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('therapistId', isEqualTo: therapistId) // Filter by therapist ID
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No new notifications."));
          }
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data!.docs[index];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(notification['patientName']),
                  subtitle: Text(notification['message']),
                  trailing: Icon(Icons.arrow_forward, color: Colors.deepOrangeAccent),
                  onTap: () {
                 
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
