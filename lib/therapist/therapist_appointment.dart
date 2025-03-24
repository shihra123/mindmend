import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  @override
  _TherapistAppointmentsScreenState createState() => _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState extends State<TherapistAppointmentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String therapistId;

  @override
  void initState() {
    super.initState();
    therapistId = _auth.currentUser?.uid ?? '';
  }

  // Navigate to Chat Screen
  void _navigateToChat(String userId) {
    Navigator.pushNamed(context, '/chat', arguments: {'userId': userId});
  }

  // Navigate to Add Meditation Screen
  void _navigateToAddMeditation(String userId) {
    Navigator.pushNamed(context, '/addMeditation', arguments: {'userId': userId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments"),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('appointments')
            .where('therapistId', isEqualTo: therapistId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No appointments found"));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: data['userProfileImage'] != null
                        ? NetworkImage(data['userProfileImage'])
                        : null,
                    child: data['userProfileImage'] == null
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(data['userName'] ?? "Unknown"),
                  subtitle: Text("Date: ${data['appointmentDate']} \nTime: ${data['appointmentTime']}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'message') {
                        _navigateToChat(data['userId']);
                      } else if (value == 'add_meditation') {
                        _navigateToAddMeditation(data['userId']);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'message',
                        child: Text("Message"),
                      ),
                      PopupMenuItem(
                        value: 'add_meditation',
                        child: Text("Add Meditation"),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
