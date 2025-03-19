import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  final Map<String, dynamic> therapist;

  FeedbackScreen({required this.therapist});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0.0;
  TextEditingController _commentController = TextEditingController();

  void _submitFeedback() async {
    if (_rating == 0.0) {
      // Ensure rating is provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide a rating")),
      );
      return;
    }

    try {
      // Save the feedback in Firestore
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'therapistId': widget.therapist['id'],
        'rating': _rating,
        'comment': _commentController.text,
        'userId': 'currentUserId', // Replace with actual user ID
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback submitted successfully")),
      );

      // Go back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      print("Error submitting feedback: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting feedback")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final therapist = widget.therapist;

    return Scaffold(
      appBar: AppBar(
        title: Text("Give Feedback"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Therapist: ${therapist['name']}'),
            SizedBox(height: 10),
            Text('Rate your experience'),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              itemSize: 40.0,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text("Submit Feedback"),
            ),
          ],
        ),
      ),
    );
  }
}
