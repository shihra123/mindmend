import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20home%20page.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';
import 'package:mindmend/forgot_password.dart';
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
   bool passwordVisible = false;
    String email = '';
  String password = '';
   final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
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

  void _login() async {
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade900, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Login to MINDMEND",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:Colors.blue.shade900,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value!.isEmpty ? "Enter email" : null,
                          onSaved: (value) => email = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelText: "Password",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !passwordVisible,
                          validator: (value) => value!.isEmpty ? "Enter password" : null,
                          onSaved: (value) => password = value!,
                        ),
                        SizedBox(height: 24),
                        isLoading
                            ? CircularProgressIndicator()
                            : GestureDetector(
                                onTap: _login,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade900, Colors.blue],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}