import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TherapistHomeScreen extends StatefulWidget {
  @override
  _TherapistHomeScreenState createState() => _TherapistHomeScreenState();
}

class _TherapistHomeScreenState extends State<TherapistHomeScreen> {
  String therapistName = "Therapist";
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    fetchTherapistData();
  }

  Future<void> fetchTherapistData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot therapistDoc = await FirebaseFirestore.instance
            .collection('therapists')
            .doc(userId)
            .get();
        if (therapistDoc.exists) {
          Map<String, dynamic> therapistData = therapistDoc.data() as Map<String, dynamic>;
          setState(() {
            therapistName = therapistData['name'] ?? "Therapist";
            profileImage = therapistData['profileImage'] ?? "";
          });
        }
      }
    } catch (e) {
      print("Error fetching therapist data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: Text("Therapist Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
                SizedBox(width: 20),
                Text(
                  "Hello, $therapistName",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Welcome to your therapist dashboard",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
