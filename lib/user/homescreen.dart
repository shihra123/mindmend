import 'package:flutter/material.dart';
import 'package:mindmend/user/user_guided_meditation.dart';

class HomePageScreen extends StatelessWidget {
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
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Daily Affirmation"),
              _buildAffirmationCard(
                  "You are strong, capable, and worthy of happiness."),
              _buildSectionTitle("Guided Meditation"),
              _buildFeatureCard(
                "Relax Your Mind",
                "Enjoy calming meditation sessions.",
                Icons.self_improvement,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuidedMeditationScreen(),
                    ));
                  // Navigate to Guided Meditation Screen
                },
              ),
              _buildSectionTitle("Emotional Pattern Tracking"),
              _buildFeatureCard(
                "Track Your Emotions",
                "Monitor your emotional patterns over time.",
                Icons.show_chart,
                () {
                  // Navigate to Emotional Pattern Tracking Screen
                },
              ),
              _buildSectionTitle("Setting Goals"),
              _buildFeatureCard(
                "Set Personal Goals",
                "Create goals for mental well-being and track progress.",
                Icons.assignment,
                () {
                  // Navigate to Setting Goals Screen
                },
              ),
            ],
          ),
        ),
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

  Widget _buildAffirmationCard(String affirmation) {
    return Card(
      color: Colors.orangeAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          affirmation,
          style: TextStyle(
              fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
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
