import 'package:flutter/material.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  // Sample data for appointments (replace with real data later)
  final List<Map<String, String>> appointments = [
    {
      'user': 'John Doe',
      'therapist': 'Dr. Sarah Smith',
      'date': '2025-02-10',
      'time': '10:00 AM',
      'status': 'Confirmed',
    },
    {
      'user': 'Jane Smith',
      'therapist': 'Dr. James Miller',
      'date': '2025-02-12',
      'time': '02:00 PM',
      'status': 'Pending',
    },
    {
      'user': 'Michael Johnson',
      'therapist': 'Dr. Linda Taylor',
      'date': '2025-02-14',
      'time': '11:30 AM',
      'status': 'Completed',
    },
    {
      'user': 'Emily Davis',
      'therapist': 'Dr. Robert Green',
      'date': '2025-02-15',
      'time': '03:00 PM',
      'status': 'Cancelled',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Details"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: appointments.length,
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
                  appointments[index]['user']!,
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
                      'Therapist: ${appointments[index]['therapist']}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Date: ${appointments[index]['date']}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Time: ${appointments[index]['time']}',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Status: ${appointments[index]['status']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: appointments[index]['status'] == 'Cancelled'
                            ? Colors.red
                            : appointments[index]['status'] == 'Completed'
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.deepOrangeAccent,
                ),
                onTap: () {
                  // Optionally, handle appointment details or more actions
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
    home: AppointmentDetailsScreen(),
  ));
}
