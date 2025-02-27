import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? name, email, phone, dob, gender;
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser?.uid ?? '';
    _fetchUserProfile();
  }

  // Fetch the current user's profile data from Firestore
  Future<void> _fetchUserProfile() async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        setState(() {
          var data = docSnapshot.data() as Map<String, dynamic>;
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          dob = data['dob'] ?? '';
          gender = data['gender'] ?? '';
          _profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
      _showSnackBar("Error fetching profile data");
    }
  }

  // Pick a profile image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Update the profile information in Firestore
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String imageUrl = _profileImageUrl ?? '';

      // Upload a new profile image to Firebase Storage
      if (_profileImage != null) {
        try {
          // UploadTask uploadTask = FirebaseStorage.instance
          //     .ref('profile_images/$uid')
          //     .putFile(_profileImage!);
          // TaskSnapshot taskSnapshot = await uploadTask;
          // imageUrl = await taskSnapshot.ref.getDownloadURL();
        } catch (e) {
          _showSnackBar("Error uploading image");
          return;
        }
      }

      // Update the user data in Firestore
      try {
        await _firestore.collection('users').doc(uid).update({
          'name': name,
          'email': email,
          'phone': phone,
          'dob': dob,
          'gender': gender,
          'profileImage': imageUrl,
        });

        _showSnackBar("Profile updated successfully");
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        _showSnackBar("Error updating profile");
      }
    }
  }

  // Show a SnackBar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.deepOrange.shade50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!) as ImageProvider
                            : null),
                    child: _profileImage == null && _profileImageUrl == null
                        ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: 20),

                // Name Field
                TextFormField(
                  initialValue: name,
                  decoration: InputDecoration(labelText: 'Name'),
                  onSaved: (value) {
                    name = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Email Field
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(labelText: 'Email'),
                  onSaved: (value) {
                    email = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Phone Field
                TextFormField(
                  initialValue: phone,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  onSaved: (value) {
                    phone = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Date of Birth Field
                TextFormField(
                  initialValue: dob,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  onSaved: (value) {
                    dob = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Gender Field
                TextFormField(
                  initialValue: gender,
                  decoration: InputDecoration(labelText: 'Gender'),
                  onSaved: (value) {
                    gender = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your gender';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Update Button
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
