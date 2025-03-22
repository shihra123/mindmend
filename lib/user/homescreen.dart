import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindmend/user/moodtracking.dart';
import 'package:mindmend/user/setgoalscreen.dart';
import 'package:mindmend/user/user_guided_meditation.dart';  

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}
class _HomePageScreenState extends State<HomePageScreen> {
  String dailyQuote = "Loading...";
  String userName = '';
  String profileImage = " ";
  @override
  void initState() {
    super.initState();
    fetchUserData();
    generateMindFreshQuote();
  }
Future<void> fetchUserData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name'] ?? "User";
          profileImage = userData['profileImage'] ?? "";
        });
      } else {
        print("User document does not exist!");
      }
    } else {
      print("No user is logged in!");
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}
Future<void> generateMindFreshQuote() async {
  final Uri url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=AIzaSyB2mKwjSjP2zeCLnXh6COx3RoxWMlaI2yY",
  );
  final Map<String, dynamic> requestBody = {
    "contents": [
      {"parts": [{"text": "Give me a random, fresh, mind-refreshing health quote. Avoid repetition."}]}
    ]
  };
  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        dailyQuote = data["candidates"][0]["content"]["parts"][0]["text"];
      });
    } else {
      setState(() {
        dailyQuote = "Failed to load quote.";
      });
    }
  } catch (e) {
    setState(() {
      dailyQuote = "Error fetching quote.";
    });
  }
}
@override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text("Mind Mend", style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 5,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : AssetImage('assets/user_profile.jpg') as ImageProvider,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("HELLO,", style: TextStyle(fontSize: 18, color: Colors.white)),
                    Text(userName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildSectionTitle("Daily Health & Mood Refreshment Quote"),
            _buildQuoteCard(dailyQuote),
            _buildSectionTitle("Guided Meditation"),
            _buildFeatureCard(
              "Relax Your Mind",
              "Meditations recommended by your therapist.",
              Icons.self_improvement,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuidedMeditationScreen(therapistId: '',),
                  ),
                );
              },
            ),
            _buildSectionTitle("Setting Goals"),
            _buildFeatureCard(
              "Manage Your Mind",
              "Guided exercises for better mental well-being.",
              Icons.lightbulb,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodTrackingScreen(),
          ),
        );
      },
      backgroundColor: Colors.black,
      child: Icon(Icons.insert_emoticon, color: Colors.white),
    ),
  );
}
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
  Widget _buildQuoteCard(String quote) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey,
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          quote,
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey,
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
        subtitle: Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade300)),
        trailing: Icon(Icons.arrow_forward, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
