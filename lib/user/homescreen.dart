import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindmend/user/moodtracking.dart';
import 'package:mindmend/user/setgoalscreen.dart';
import 'package:mindmend/user/user_guided_meditation.dart';  

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String dailyQuote = "Loading...";

  @override
  void initState() {
    super.initState();
    generateMindFreshQuote();
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
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Mind Mend"),
      backgroundColor: Colors.deepOrangeAccent,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      backgroundColor: Colors.deepOrangeAccent,
      child: Icon(Icons.insert_emoticon),
    ),
  );
}


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildQuoteCard(String quote) {
    return Card(
      color: Colors.orangeAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrangeAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward, color: Colors.deepOrangeAccent),
        onTap: onTap,
      ),
    );
  }
}
