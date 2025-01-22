import 'package:flutter/material.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Create Account",
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
          // Form Container
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(height: 120),
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  icon: Icons.person,
                ),
                SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter a strong password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    // Handle sign-up action here
                    print("Submitted");
                  },
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
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom TextField Widget with styling
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
}
