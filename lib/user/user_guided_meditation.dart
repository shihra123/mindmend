import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuidedMeditationScreen extends StatefulWidget {
  final String therapistId;

  GuidedMeditationScreen({required this.therapistId});

  @override
  _GuidedMeditationScreenState createState() => _GuidedMeditationScreenState();
}

class _GuidedMeditationScreenState extends State<GuidedMeditationScreen> {
  final TextEditingController _sessionController = TextEditingController();

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  // Add new session
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
                FirebaseFirestore.instance.collection('meditations').add({
                  'title': _sessionController.text,
                  'description': "User added meditation session",
                  'audioUrl': "",
                  'therapistId': widget.therapistId, 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guided Meditation"),
        backgroundColor: Colors.deepOrangeAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewSession,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('meditations')
              .where('therapistId', isEqualTo: widget.therapistId)  // Filter by therapistId
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No meditation sessions available"));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var session = snapshot.data!.docs[index];
                return _buildMeditationCard(
                  context,
                  MeditationSession(
                    title: session['title'],
                    description: session['description'],
                    audioUrl: session['audioUrl'],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMeditationCard(BuildContext context, MeditationSession session) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.self_improvement, color: Colors.deepOrangeAccent),
        title: Text(session.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(session.description),
        trailing: Icon(Icons.play_arrow, color: Colors.deepOrangeAccent),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeditationPlayerScreen(session: session),
            ),
          );
        },
      ),
    );
  }
}

class MeditationSession {
  final String title;
  final String description;
  final String audioUrl;

  MeditationSession({required this.title, required this.description, required this.audioUrl});
}

class MeditationPlayerScreen extends StatelessWidget {
  final MeditationSession session;

  MeditationPlayerScreen({required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(session.title),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(session.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(session.description, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Implement audio player functionality here
              },
              icon: Icon(Icons.play_arrow),
              label: Text("Play Meditation"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
