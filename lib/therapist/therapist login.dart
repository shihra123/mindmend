import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindmend/therapist/therapist%20forgot%20password.dart';
import 'package:mindmend/therapist/therapist%20home%20page.dart';

class TherapistLoginScreen extends StatefulWidget {
  const TherapistLoginScreen({super.key});

  @override
  State<TherapistLoginScreen> createState() => _TherapistLoginScreenState();
}

class _TherapistLoginScreenState extends State<TherapistLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // To toggle password visibility

  void _loginTherapist() async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TherapistHomePage(),
        ));
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _showSnackBar("Login successful!");

      // Navigate to therapist dashboard (replace with actual screen)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TherapistDashboard()));
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login failed");
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _forgotPassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TherapistForgotPasswordScreen(),
        ));
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Enter your email to reset password");
      return;
    }

    _auth.sendPasswordResetEmail(email: _emailController.text.trim());
    _showSnackBar("Password reset link sent to your email");
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
          "Therapist Login",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    hintText: "Enter your email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Password Field with Show/Hide Icon
                  _buildPasswordField(
                    controller: _passwordController,
                    label: "Password",
                    hintText: "Enter your password",
                    icon: Icons.lock,
                  ),
                  SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text("Forgot Password?",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loginTherapist,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Login"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(30),
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
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
            borderRadius: BorderRadius.circular(30),
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
