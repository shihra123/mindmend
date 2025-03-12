import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  // Function to send notification to the therapist
  void sendNotification(String therapistId, String message) {
    FirebaseFirestore.instance.collection('notifications').add({
      'therapistId': therapistId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Details"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No appointments available"));
          }

          var appointments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    appointment['user'] ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Therapist: ${appointment['therapist']}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Date: ${appointment['date']}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Time: ${appointment['time']}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Status: ${appointment['status']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: appointment['status'] == 'Cancelled'
                              ? Colors.red
                              : appointment['status'] == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.notifications, color: Colors.deepOrangeAccent),
                    onPressed: () {
                      sendNotification(
                        appointment['therapistId'],
                        "New update on appointment with ${appointment['user']}",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Notification sent to therapist")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
