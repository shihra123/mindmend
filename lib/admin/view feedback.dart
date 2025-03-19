import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminFeedbackScreen extends StatefulWidget {
  @override
  _AdminFeedbackScreenState createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchFeedbacks() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('feedbacks')
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> feedbacks = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Fetch therapist details
        String therapistName = await _fetchTherapistName(data['therapistId']);

        // Fetch user details
        String userName = await _fetchUserName(data['userId']);

        feedbacks.add({
          'id': doc.id,
          'userName': userName,
          'therapistName': therapistName,
          'rating': data['rating'] ?? 'N/A',
          'feedback': data['feedback'] ?? 'No feedback provided',
          'timestamp': data['timestamp'],
        });
      }

      return feedbacks;
    } catch (e) {
      print("Error fetching feedbacks: $e");
      return [];
    }
  }

  Future<String> _fetchTherapistName(String therapistId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('therapists').doc(therapistId).get();
      return doc.exists ? (doc['name'] ?? 'Unknown') : 'Unknown';
    } catch (e) {
      print("Error fetching therapist name: $e");
      return 'Unknown';
    }
  }

  Future<String> _fetchUserName(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return doc.exists ? (doc['name'] ?? 'Unknown') : 'Unknown';
    } catch (e) {
      print("Error fetching user name: $e");
      return 'Unknown';
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown date";
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Feedbacks"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No feedbacks found"));
          }

          final feedbacks = snapshot.data!;

          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];

              return Card(
                margin: EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.person, "User: ${feedback['userName']}"),
                      _buildDetailRow(Icons.healing, "Therapist: ${feedback['therapistName']}"),
                      _buildDetailRow(Icons.star, "Rating: ${feedback['rating']} ★"),
                      _buildDetailRow(Icons.message, "Feedback: ${feedback['feedback']}"),
                      _buildDetailRow(Icons.date_range, "Date: ${_formatTimestamp(feedback['timestamp'])}"),
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
