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
    "Focus Boost - 12 min",
    "Relaxation Guide - 18 min"
  ];

  final TextEditingController _sessionController = TextEditingController();

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  void _addNewSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Meditation"),
        content: TextField(
          controller: _sessionController,
          decoration: const InputDecoration(hintText: "Enter session name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sessionController.clear();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (_sessionController.text.isNotEmpty) {
                setState(() {
                  meditationSessions.add(_sessionController.text);
                });
                Navigator.pop(context);
                _sessionController.clear();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _playSession(String session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Playing: $session 🎵"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meditation"),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.lightBlue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addNewSession,
              icon: const Icon(Icons.add),
              label: const Text("Add Meditation Session"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: meditationSessions.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.self_improvement,
                          color: Colors.deepOrangeAccent),
                      title: Text(
                        meditationSessions[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow,
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
