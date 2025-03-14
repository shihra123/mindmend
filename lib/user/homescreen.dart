import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindmend/user/moodtracking.dart';
import 'package:mindmend/user/setgoalscreen.dart';
import 'package:mindmend/user/user_guided_meditation.dart';  

class GeminiAPI {
  final String apiKey = 'AIzaSyBICQYYc8mqAyOxWOULqy-AwB-wc9YMXS4';
  final String endpoint = 'https://generativeai.googleapis.com/v1beta2/generate';

  Future<Map<String, dynamic>> geminiAI(String prompt, {int maxRetries = 10}) async {
    Map<String, dynamic> responseData = {};
    int retries = 0;

    while (retries < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'prompt': prompt,
            'model': 'gemini-pro',
          }),
        );

        if (response.statusCode == 200) {
          var story = jsonDecode(response.body);
          responseData = {'data': story, 'flag': true};
          return responseData;
        } else {
          throw Exception('Failed to load content');
        }
      } catch (e) {
        retries++;
        print('Attempt $retries failed: $e');
      }
    }

    return {
      'message': 'Failed to fetch data after $maxRetries attempts',
      'flag': false,
      'data': {},
    };
  }
}

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String dailyQuote = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchDailyQuote();
  }

  Future<void> _fetchDailyQuote() async {
    GeminiAPI geminiAPI = GeminiAPI();
    var result = await geminiAPI.geminiAI(
      'Give me a short motivational quote related to health and mood refreshment.',
    );

    setState(() {
      if (result['flag']) {
        dailyQuote = result['data']['candidates'][0]['content']['parts'][0]['text'] ??
            "Stay healthy and positive!";
      } else {
        dailyQuote = result['message'] ?? "Failed to fetch quote. Try again later.";
      }
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("Mind Mend"),
      backgroundColor: Colors.black,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey, Colors.grey],
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
                    builder: (context) => GuidedMeditationScreen(),
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
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildQuoteCard(String quote) {
    return Card(
      color: Colors.black,
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
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward, color: Colors.black),
        onTap: onTap,
      ),
    );
  }
}
