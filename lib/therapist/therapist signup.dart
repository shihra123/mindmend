import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmend/helper.dart';

class TherapistSignupScreen extends StatefulWidget {
  const TherapistSignupScreen({Key? key}) : super(key: key);

  @override
  State<TherapistSignupScreen> createState() => _TherapistSignupScreenState();
}

class _TherapistSignupScreenState extends State<TherapistSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  XFile? _profileImage;
  Uint8List? _webImage; 
  final ImagePicker _picker = ImagePicker();
  
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

  void _signUpTherapist() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final qualification = _qualificationController.text.trim();
    final contactNumber = _contactController.text.trim();
    final fees = _feesController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        qualification.isEmpty ||
        contactNumber.isEmpty ||
        fees.isEmpty) {
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
      await _firestore.collection('therapists').doc(uid).set({
        'name': name,
        'email': email,
        'qualification': qualification,
        'contactNumber': contactNumber,
        'fees': fees,
        'uid': uid,
        'profileImage': profileImageUrl,
        'approved': false,
        'role': 'therapist',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Sign up successful!");
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
        title: const Text(
          "Create Therapist Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Enhanced Background Gradient with Deep Orange & Peach tones
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFA07A),
                  Color(0xFFFF6347),
                  Color(0xFFFF4500)
                ],
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
                const SizedBox(height: 120),
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
               
                _buildTextField(
                  controller: _nameController,
                  label: 'Therapist Name',
                  hintText: 'Enter your full name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter a strong password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Qualification Field
                _buildTextField(
                  controller: _qualificationController,
                  label: 'Qualification',
                  hintText: 'Enter your qualification',
                  icon: Icons.school,
                ),
                const SizedBox(height: 16),

                // Contact Number Field
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Number',
                  hintText: 'Enter your contact number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Fees Field
                _buildTextField(
                  controller: _feesController,
                  label: 'Consultation Fees',
                  hintText: 'Enter your consultation fees',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),

                // Submit Button
                ElevatedButton(
                  onPressed: _signUpTherapist,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 80.0),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 8,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrangeAccent,
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.deepOrangeAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom TextField Widget with enhanced styling
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.deepOrangeAccent),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }
}
