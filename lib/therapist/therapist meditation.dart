import 'package:flutter/material.dart';

class MeditationScreen extends StatefulWidget {
  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  List<String> meditationSessions = [
    "Morning Calm - 10 min",
    "Stress Relief - 15 min",
    "Sleep Meditation - 20 min",
  ];

  void _addNewSession() {
    TextEditingController _sessionController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Meditation"),
        content: TextField(
          controller: _sessionController,
          decoration: InputDecoration(hintText: "Enter session name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_sessionController.text.isNotEmpty) {
                setState(() {
                  meditationSessions.add(_sessionController.text);
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _playSession(String session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Playing: $session 🎵"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Provide Meditation"),
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
        child: Column(
          children: [
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addNewSession,
              icon: Icon(Icons.add),
              label: Text("Add Meditation Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: meditationSessions.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.self_improvement,
                          color: Colors.deepOrangeAccent),
                      title: Text(
                        meditationSessions[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.play_arrow,
                            color: Colors.deepOrangeAccent),
                        onPressed: () =>
                            _playSession(meditationSessions[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
