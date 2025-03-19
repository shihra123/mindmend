import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedGender = 'Male'; // Default gender

  XFile? _profileImage;
  Uint8List? _webImage; // For web
  final ImagePicker _picker = ImagePicker();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Read file as bytes for web compatibility
        Uint8List imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = imageBytes;
          _profileImage = pickedFile;
        });
      } else {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } else {
      _showSnackBar("No image selected");
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    String cloudinaryUrl = "https://api.cloudinary.com/v1_1/dwno7g81o/image/upload";
    String uploadPreset = "profile_images";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
      request.fields["upload_preset"] = uploadPreset;

      if (kIsWeb && _webImage != null) {
        String base64Image = base64Encode(_webImage!);
        request.fields["file"] = "data:image/png;base64,$base64Image";
      } else {
        request.files.add(await http.MultipartFile.fromPath("file", _profileImage!.path));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        return jsonData["secure_url"]; 
      } else {
        print("Cloudinary Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _signUpUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();
    final gender = _selectedGender;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phone.isEmpty ||
        dob.isEmpty ||
        gender == null) {
      _showSnackBar("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    try {
   
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;

      String? profileImageUrl = await _uploadProfileImage();

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'dob': dob,
        'gender': gender,
        'uid': uid,
        'profileImage': profileImageUrl,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful!");
      // Navigate to another screen, e.g., Home
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred");
    } catch (e) {
      _showSnackBar("An unexpected error occurred");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
                colors: [Colors.grey, Colors.grey],
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
                // Profile Photo
                GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _profileImage != null
                    ? kIsWeb && _webImage != null
                        ? MemoryImage(_webImage!) as ImageProvider
                        : FileImage(File(_profileImage!.path))
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, color: Colors.white, size: 30)
                    : null,
              ),
            ),
                SizedBox(height: 16),

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

                // Phone Field
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hintText: 'Enter your phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16),

                // Date of Birth Field
                GestureDetector(
                  onTap: () => _selectDateOfBirth(context),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dobController,
                      label: 'Date of Birth',
                      hintText: 'Select your date of birth',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Password Field with Show/Hide functionality
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter a strong password',
                  icon: Icons.lock,
                  isPasswordVisible: _isPasswordVisible,
                  togglePasswordVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Confirm Password Field with Show/Hide functionality
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  togglePasswordVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _signUpUser,
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
                  child: Text("Sign Up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Password Field Widget with Show/Hide functionality
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required bool isPasswordVisible,
    required VoidCallback togglePasswordVisibility,
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
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black),
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
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: togglePasswordVisibility,
          ),
        ),
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
          prefixIcon: Icon(icon, color: Colors.black),
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black),
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
}
