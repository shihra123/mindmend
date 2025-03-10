import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20home%20page.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';
import 'package:mindmend/user/user_forgot_password.dart';
import 'package:mindmend/user/user_home.dart'; // User Home page


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false; // To toggle password visibility
void _loginUser() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showSnackBar("Please fill all fields");
    return;
  }

  try {
    // Check if admin credentials are used
    if (email == "shihra@gmail.com" && password == "shihra123") {
      // Admin credentials match, navigate to admin home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminHomePage(), // Admin Home screen
        ),
      );
      return;
    }

    // Sign in with Firebase Authentication for users and therapists
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Fetch user role (You would typically store and fetch roles from Firestore here)
    String userRole = await _fetchUserRole(userCredential.user!.uid);

    // Navigate based on the role
    if (userRole == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomePage(), // User Home screen
        ),
      );
    } else if (userRole == 'therapist') {
      // Check if therapist is approved
      bool isApproved = await _checkTherapistApproval(userCredential.user!.uid);

      if (isApproved) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TherapistHomePage(), // Therapist Home screen
          ),
        );
      } else {
        _showSnackBar("Your account is not approved yet. Please contact support.");
      }
    } else {
      _showSnackBar("Unknown role. Please contact support.");
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      _showSnackBar("No user found for this email.");
    } else if (e.code == 'wrong-password') {
      _showSnackBar("Incorrect password.");
    } else {
      _showSnackBar(e.message ?? "An error occurred");
    }
  } catch (e) {
    _showSnackBar("An unexpected error occurred");
  }
}

// Simulating fetching role from Firestore (this should be implemented in your app)
Future<String> _fetchUserRole(String userId) async {
  // Fetch the role from Firestore or Firebase Database here
  // For now, we'll return a fixed value based on your example
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  
  if (userDoc.exists) {
    return userDoc['role']; // Assuming role is stored as 'role' in Firestore
  } else {
    return "user"; // Default role if not found
  }
}

// Check if therapist is approved (in Firestore therapists collection)
Future<bool> _checkTherapistApproval(String therapistId) async {
  DocumentSnapshot therapistDoc = await FirebaseFirestore.instance.collection('therapists').doc(therapistId).get();

  if (therapistDoc.exists) {
    bool isApproved = therapistDoc['approved'] ?? false;
    return isApproved; // Return approval status
  }
  return false; // If therapist document doesn't exist, return false
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Login",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 120),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password Field with Show/Hide Icon
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                ),
                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 5,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text("Login"),
                ),

                SizedBox(height: 20),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ));

                    // Implement password reset
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.deepOrange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  // Password Field with Show/Hide Icon
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible, // Toggle visibility based on the _isPasswordVisible value
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.deepOrange),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
              });
            },
          ),
        ),
      ),
    );
  }
}
