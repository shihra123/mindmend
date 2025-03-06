import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/user/editprofilescreen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String uid;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser?.uid ?? '';
    print('UID: $uid'); // Debugging: Check the UID

    if (uid.isNotEmpty) {
      _fetchUserProfile();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        setState(() {
          userData = docSnapshot.data() as Map<String, dynamic>?;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile data not found")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user profile: $e'); // Log error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile")),
      );
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(),
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
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('No profile data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
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
                backgroundImage: userData!['profileImage'] != null
                    ? NetworkImage(userData!['profileImage'])
                    : null,
                child: userData!['profileImage'] == null
                    ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                    : null,
              ),
              SizedBox(height: 20),

              // Name
              Text(
                userData!['name'] ?? '',
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
                    userData!['email'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Phone
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    userData!['phone'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Date of Birth
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    'DOB: ${userData!['dob'] ?? ''}',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Gender
              Row(
                children: [
                  Icon(Icons.accessibility, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Text(
                    'Gender: ${userData!['gender'] ?? ''}',
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
