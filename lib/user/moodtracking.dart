import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoodTrackingScreen extends StatefulWidget {
  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  final TextEditingController _moodController = TextEditingController();
  String? _selectedEmoji;

  final List<String> emojis = ['😄', '😐', '😢', '😡'];
  final Color primaryColor = Colors.blueAccent;

  void _submitMood() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || _selectedEmoji == null) return;

    await FirebaseFirestore.instance.collection('mood_logs').add({
      'userId': userId,
      'emoji': _selectedEmoji,
      'note': _moodController.text,
      'timestamp': Timestamp.now(),
      'audioUrl': null,
      'imageUrl': null,
    });

    _moodController.clear();
    setState(() => _selectedEmoji = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mood submitted successfully!")),
    );
  }

  void _recordVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice recording coming soon!")),
    );
  }

  void _capturePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Photo capture coming soon!")),
    );
  }

  Widget _buildEmojiSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: emojis.map((emoji) {
        bool isSelected = emoji == _selectedEmoji;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedEmoji = emoji;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodLogs() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mood_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var moods = snapshot.data!.docs;

        if (moods.isEmpty) {
          return const Text("No mood logs yet.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Previous Mood Logs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...moods.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Text(data['emoji'] ?? '🙂',
                      style: const TextStyle(fontSize: 24)),
                  title: Text(data['note'] ?? ''),
                  subtitle: Text(
                    (data['timestamp'] as Timestamp).toDate().toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }).toList()
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Track Your Mood"),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildEmojiSelector(),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _moodController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Write more about your mood...",
                    border: InputBorder.none,
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Voice recording button
            ElevatedButton.icon(
              onPressed: _recordVoice,
              icon: const Icon(Icons.mic),
              label: const Text("Record Voice"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade100,
                foregroundColor: Colors.black87,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade100,
                foregroundColor: Colors.black87,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            // Submit mood
            ElevatedButton.icon(
              onPressed: _submitMood,
              icon: const Icon(Icons.send),
              label: const Text("Submit Mood"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),

            _buildMoodLogs(),
          ],
        ),
      ),
    );
  }
}
