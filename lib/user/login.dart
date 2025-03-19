import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20home%20page.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';
import 'package:mindmend/user/user_forgot_password.dart';
import 'package:mindmend/user/user_home.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordVisible = false;
  Future<String> _fetchUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['role'] ?? 'user';
      }
      DocumentSnapshot therapistDoc = await FirebaseFirestore.instance
          .collection('therapists')
          .doc(userId)
          .get();
      if (therapistDoc.exists) {
     
        
        return 'therapist';
      }

    
      return 'user';
    } catch (e) {
      print("Error fetching user role: $e");
      return 'user'; 
    }
  }
  Future<bool> _checkTherapistApproval(String therapistId) async {
    DocumentSnapshot therapistDoc = await FirebaseFirestore.instance
        .collection('therapists')
        .doc(therapistId)
        .get();

    if (therapistDoc.exists) {
      bool isApproved = therapistDoc['approved'] ?? false;
      
      return isApproved; 
    }
    return false; 
  }

  void _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    try {
     
      if (email == "shihra@gmail.com" && password == "shihra123"){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomePage(), 
          ),
        );
        return;
      }

    
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

     
      String userRole = await _fetchUserRole(userCredential.user!.uid);
    
      if (userRole == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserHomePage(), 
          ),
        );
      } else if (userRole == 'therapist') {
        bool isApproved =
            await _checkTherapistApproval(userCredential.user!.uid);

        if (isApproved) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TherapistHomePage(), 
            ),
          );
        } else {
          _showSnackBar(
              "Your account is not approved yet. Please contact support.");
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
       
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 120),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.black,
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
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                        ));

                    
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
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.black),
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
        obscureText:
            !_isPasswordVisible, // Toggle visibility based on the _isPasswordVisible value
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          labelStyle: TextStyle(color: Colors.black),
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
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible =
                    !_isPasswordVisible; // Toggle password visibility
              });
            },
          ),
        ),
      ),
    );
  }
}
