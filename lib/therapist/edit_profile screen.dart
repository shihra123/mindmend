import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TherapistEditProfileScreen extends StatefulWidget {
  @override
  _TherapistEditProfileScreenState createState() => _TherapistEditProfileScreenState();
}

class _TherapistEditProfileScreenState extends State<TherapistEditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? name, email, contactNumber, qualification, experience, specialization, fees;
  File? _profileImage;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser?.uid ?? '';
    _fetchTherapistProfile();
  }

  Future<void> _fetchTherapistProfile() async {
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('therapists').doc(uid).get();
      if (docSnapshot.exists) {
        setState(() {
          var data = docSnapshot.data() as Map<String, dynamic>;
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          contactNumber = data['contactNumber'] ?? '';
          qualification = data['qualification'] ?? '';
          //experience = data['experience'] ?? '';
          //specialization = data['specialization'] ?? '';
          fees = data['fees'] ?? '';
          _profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
      _showSnackBar("Error fetching profile data");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _firestore.collection('therapists').doc(uid).update({
          'name': name,
          'email': email,
          'contactNumber': contactNumber,
          'qualification': qualification,
         // 'experience': experience,
          //'specialization': specialization,
          'fees': fees,
          'profileImage': _profileImageUrl,
        });
        _showSnackBar("Profile updated successfully");
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar("Error updating profile");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile'), backgroundColor: Colors.deepOrange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null) as ImageProvider?,
                    child: _profileImage == null && _profileImageUrl == null
                        ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('Name', name, (value) => name = value),
                _buildTextField('Email', email, (value) => email = value),
                _buildTextField('Contact Number', contactNumber, (value) => contactNumber = value),
                _buildTextField('Qualification', qualification, (value) => qualification = value),
               // _buildTextField('Experience', experience, (value) => experience = value),
                //_buildTextField('Specialization', specialization, (value) => specialization = value),
                _buildTextField('Fees', fees, (value) => fees = value),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: Text('Update Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? initialValue, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label),
        onSaved: (value) => onSaved(value!),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
