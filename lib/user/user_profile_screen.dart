import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isEditing = false;
  bool showChangePassword = false;

  Map<String, dynamic>? userData;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController genderController;

  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userData = doc.data() as Map<String, dynamic>;
        nameController = TextEditingController(text: userData!['name']);
        phoneController = TextEditingController(text: userData!['phone']);
        dobController = TextEditingController(text: userData!['dob']);
        genderController = TextEditingController(text: userData!['gender']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading profile")));
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'dob': dobController.text,
        'gender': genderController.text,
      });
      setState(() {
        isEditing = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile updated")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update")));
    }
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassController.text,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password changed successfully")),
      );

      currentPassController.clear();
      newPassController.clear();
      confirmPassController.clear();

      setState(() {
        showChangePassword = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to change password")),
      );
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container( decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 142, 186, 236), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(),
                    SizedBox(height: 20),
                    _buildProfileImage(),
                    SizedBox(height: 20),
                    _buildEditableField("Name", Icons.person, nameController),
                    _buildEditableField("Phone", Icons.phone, phoneController),
                    _buildEditableField("Date of Birth", Icons.cake, dobController),
                    _buildEditableField("Gender", Icons.wc, genderController),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isEditing ? _saveProfile : () {
                        setState(() => isEditing = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEditing ? "Save Changes" : "Edit Profile",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        setState(() => showChangePassword = !showChangePassword);
                      },
                      child: Text(
                        showChangePassword ? "Cancel Change Password" : "Change Password",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    if (showChangePassword) ...[
                      _buildPasswordField("Current Password", currentPassController),
                      _buildPasswordField("New Password", newPassController),
                      _buildPasswordField("Confirm Password", confirmPassController),
                      ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Update Password",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: _logout,
                      child: Text("Logout",
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ],
                ),
              ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Center(
        child: Text("My Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      backgroundImage: userData!['profileImage'] != null
          ? NetworkImage(userData!['profileImage'])
          : null,
      child: userData!['profileImage'] == null
          ? Icon(Icons.person, size: 50, color: Colors.grey)
          : null,
    );
  }

  Widget _buildEditableField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blue.shade700),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade800),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade800),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
