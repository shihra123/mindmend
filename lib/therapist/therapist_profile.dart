import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/therapist/edit_profile%20screen.dart';


class TherapistProfileScreen extends StatefulWidget {
  @override
  _TherapistProfileScreenState createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String uid;
  bool isLoading = true;
  Map<String, dynamic>? therapistData;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      _fetchTherapistProfile();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTherapistProfile() async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('therapists')
          .doc(uid)
          .get();
      
      if (docSnapshot.exists && (docSnapshot.data() as Map<String, dynamic>)['approved'] == true) {
        setState(() {
          therapistData = docSnapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Therapist profile not found or not approved")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading therapist profile")),
      );
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TherapistEditProfileScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Therapist Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (therapistData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Therapist Profile')),
        body: Center(child: Text('No profile data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Therapist Profile'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 75,
                backgroundColor: Colors.white,
                backgroundImage: therapistData!['profileImage'] != null
                    ? NetworkImage(therapistData!['profileImage'])
                    : null,
                child: therapistData!['profileImage'] == null
                    ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                    : null,
              ),
              SizedBox(height: 20),

              // Name
              Text(
                therapistData!['name'] ?? '',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              SizedBox(height: 10),

              // Email
              Row(
                children: [
                  Icon(Icons.email, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    therapistData!['email'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Contact Number
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    therapistData!['contactNumber'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Qualification
              Row(
                children: [
                  Icon(Icons.school, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    therapistData!['qualification'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Fees
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    'Fees: ₹${therapistData!['fees'] ?? ''}',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Edit Profile Button
              ElevatedButton(
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
