import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/user/payment_process_screen.dart';


class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchTherapists() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('therapists')
          .where('approved', isEqualTo: true) // Show only approved therapists
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching therapists: $e");
      return [];
    }
  }

  Future<void> _bookAppointment(Map<String, dynamic> therapist) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Navigate to the payment screen and pass the therapist details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(therapist: therapist),
        ),
      );
    } catch (e) {
      print("Error booking appointment: $e");
    }
  }

  Future<void> _giveFeedback(Map<String, dynamic> therapist) async {
    TextEditingController feedbackController = TextEditingController();
    double rating = 3.0; // Default rating

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Use StatefulBuilder to update the rating
        builder: (context, setState) => AlertDialog(
          title: Text("Give Feedback"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(hintText: "Write your feedback"),
              ),
              SizedBox(height: 10),
              Text("Rate the therapist"),
              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 4,
                label: "$rating",
                onChanged: (value) {
                  setState(() {
                    rating = value;  // Update the rating when the slider value changes
                  });
                },
              ),
              Text("Rating: $rating", style: TextStyle(fontSize: 16, color: Colors.black54)), // Show the rating text
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Save the feedback and rating to Firestore
                  await _firestore.collection('feedbacks').add({
                    'therapistId': therapist['uid'],
                    'userId': _auth.currentUser?.uid,
                    'rating': rating,
                    'feedback': feedbackController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Feedback submitted successfully!")),
                  );
                  Navigator.pop(context); // Close the feedback dialog
                } catch (e) {
                  print("Error submitting feedback: $e");
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book an Appointment"),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // Fetch therapists from Firestore
        future: _fetchTherapists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No therapists available"));
          }

          final therapists = snapshot.data!;

          return ListView.builder(
            itemCount: therapists.length,
            itemBuilder: (context, index) {
              final therapist = therapists[index];

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
                      ListTile(
                        leading: CircleAvatar(
                          radius: 40,
                          backgroundImage: therapist['profileImage'] != null
                              ? NetworkImage(therapist['profileImage'])
                              : null,
                          child: therapist['profileImage'] == null
                              ? Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        title: Text(
                          therapist['name'] ?? "Unknown",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          therapist['qualification'] ?? "Not specified",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow(Icons.email, therapist['email']),
                      _buildDetailRow(Icons.phone, therapist['contactNumber']),
                      _buildDetailRow(Icons.attach_money, "Fees: ₹${therapist['fees']}"),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _bookAppointment(therapist),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Book Now", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: () => _giveFeedback(therapist),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black12,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text("Give Feedback", style: TextStyle(color: Colors.white)),
                          ),
                        ],
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
