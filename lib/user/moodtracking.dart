import 'package:flutter/material.dart';

class MoodTrackingScreen extends StatefulWidget {
  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final TextEditingController _moodController = TextEditingController();

  // Placeholder for camera and voice recording logic later
  void _startRecording() {
    // Placeholder for voice or camera logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Your Mood"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please describe how you are feeling today.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _moodController,
              decoration: InputDecoration(
                hintText: "Enter your mood here...",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startRecording,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
              child: Text("Record Voice or Capture Photo"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send mood data to AI (AI logic to be added later)
                print("Mood: ${_moodController.text}");
              },
              child: Text("Submit Mood"),
            ),
          ],
        ),
      ),
    );
  }
}
