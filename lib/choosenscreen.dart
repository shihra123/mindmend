import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20login.dart';
import 'package:mindmend/therapist/therapist%20login.dart';
import 'package:mindmend/user/user_login.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String? _selectedRole;

  void _submitRole() {
    if (_selectedRole == null) {
      _showSnackBar("Please select a role");
      return;
    }

    _showSnackBar("Selected Role: $_selectedRole");

    // Navigation logic (Replace with your actual screens)
    if (_selectedRole == "Admin") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminLoginScreen(),
          ));
      // Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSignupScreen()));
    } else if (_selectedRole == "User") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserLoginScreen(),
          ));

      // Navigator.push(context, MaterialPageRoute(builder: (context) => UserSignupScreen()));
    } else if (_selectedRole == "Therapist") {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TherapistLoginScreen(),
          ));
      // Navigator.push(context, MaterialPageRoute(builder: (context) => TherapistSignupScreen()));
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
        title: Text(
          "Choose Role",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select Your Role",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Role Selection Cards
                  _buildRoleCard("Admin", Icons.admin_panel_settings),
                  _buildRoleCard("User", Icons.person),
                  _buildRoleCard("Therapist", Icons.medical_services),

                  SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitRole,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 5,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text("Continue"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : Colors.deepOrange,
            ),
            SizedBox(width: 15),
            Text(
              role,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
