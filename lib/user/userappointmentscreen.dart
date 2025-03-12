import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  final CollectionReference _therapistsCollection =
      FirebaseFirestore.instance.collection('therapists');

  void _bookAppointment(String docId, String name) {
    _therapistsCollection.doc(docId).update({'availability': 'Booked'});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment booked with $name!')),
    );
  }

  void _submitFeedback(String docId, String feedback) {
    _therapistsCollection.doc(docId).update({'feedback': feedback});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Feedback submitted successfully!')),
    );
  }

  void _showFeedbackDialog(String docId) {
    TextEditingController feedbackController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Submit Feedback'),
          content: TextField(
            controller: feedbackController,
            decoration: InputDecoration(hintText: 'Enter your feedback here'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (feedbackController.text.isNotEmpty) {
                  _submitFeedback(docId, feedbackController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
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
        title: Text('My Appointments'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: StreamBuilder(
        stream: _therapistsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No therapists available.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var therapist = snapshot.data!.docs[index];
              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: ListTile(
                  title: Text(therapist['name'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: therapist['availability'] == 'Available'
                            ? () => _bookAppointment(
                                therapist.id, therapist['name'])
                            : null,
                        child: Text(therapist['availability'] == 'Available'
                            ? 'Book Now'
                            : 'Booked'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              therapist['availability'] == 'Available'
                                  ? Colors.deepOrangeAccent
                                  : Colors.grey,
                        ),
                      ),
                      if (therapist['availability'] == 'Booked')
                        TextButton(
                          onPressed: () => _showFeedbackDialog(therapist.id),
                          child: Text('Give Feedback'),
                        ),
                    ],
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
