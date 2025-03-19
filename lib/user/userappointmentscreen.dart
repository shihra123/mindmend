import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/user/available%20_slots.dart';

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
    final therapistId = therapist['uid']; // Assuming 'uid' is the field for therapist ID

    // Navigate to the TherapistDetailsScreen and pass both therapist data and therapistId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TherapistDetailsScreen(
          therapist: therapist,  // Pass the entire therapist data
          therapistId: therapistId,  // Pass the therapist's ID
        ),
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
        title: Text(
          "mind mend",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by doctor’s name',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  padding: EdgeInsets.all(16.0),
                  itemCount: therapists.length,
                  itemBuilder: (context, index) {
                    final therapist = therapists[index];

                    return Card(
                      margin: EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey[100], // Light grey background for the card
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: therapist['profileImage'] != null
                                      ? NetworkImage(therapist['profileImage'])
                                      : null,
                                  child: therapist['profileImage'] == null
                                      ? Icon(Icons.person, size: 30, color: Colors.grey)
                                      : null,
                                ),
                                SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      therapist['name'] ?? "Unknown",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      therapist['qualification'] ?? "Not specified",
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16.0),
                                        SizedBox(width: 4.0),
                                        Text(
                                          "4.5", // Replace with dynamic rating from Firestore
                                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              "\$${therapist['fees']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _giveFeedback(therapist),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black, // Black button
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Give Feedback",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _bookAppointment(therapist),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black, // Black button
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Book Appointment",
                                    style: TextStyle(color: Colors.white),
                                  ),
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
          ),
        ],
      ),
    );
  }
}