import 'package:flutter/material.dart';

class ViewFeedbackScreen extends StatelessWidget {
  // Sample data for feedback (replace with real data later)
  final List<Map<String, String>> feedbacks = [
    {
      'user': 'John Doe',
      'feedback': 'Great service! I feel much better after the therapy.',
      'rating': '4.5',
      'date': '2025-02-10',
    },
    {
      'user': 'Jane Smith',
      'feedback': 'Very professional and helpful therapist.',
      'rating': '5.0',
      'date': '2025-02-05',
    },
    {
      'user': 'Michael Johnson',
      'feedback':
          'Good experience, but I would appreciate more detailed sessions.',
      'rating': '3.5',
      'date': '2025-02-01',
    },
    {
      'user': 'Emily Davis',
      'feedback': 'I felt comfortable and heard throughout the session.',
      'rating': '4.8',
      'date': '2025-01-28',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Feedback"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  feedbacks[index]['user']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'Rating: ${feedbacks[index]['rating']}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Feedback: ${feedbacks[index]['feedback']}',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${feedbacks[index]['date']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.deepOrangeAccent,
                ),
                onTap: () {
                  // Optionally, handle feedback details or more actions
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ViewFeedbackScreen(),
  ));
}
