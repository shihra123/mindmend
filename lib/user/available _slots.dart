import 'package:flutter/material.dart';

class TherapistDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> therapist; // Therapist data
  final String therapistId; // Therapist ID

  TherapistDetailsScreen({required this.therapist, required this.therapistId});

  @override
  _TherapistDetailsScreenState createState() => _TherapistDetailsScreenState();
}

class _TherapistDetailsScreenState extends State<TherapistDetailsScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selected date
      firstDate: DateTime(2020), // Earliest selectable date
      lastDate: DateTime(2025), // Latest selectable date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Update the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Therapist Details"),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Therapist Info Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.therapist['name'] ?? "Dr. Kevon Lane",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              widget.therapist['qualification'] ?? "Gynecologist",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "\$${widget.therapist['fees'] ?? '200'}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              // Date Picker Section
              Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  await _selectDate(context); // Call the date picker function
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Choose Date'
                      : 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 20.0),

              // Available Time Slots
              Text(
                'Available Time Slots',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  '06:00 PM',
                  '06:30 PM',
                  '07:00 PM',
                  '07:30 PM',
                  '08:00 PM',
                  '08:30 PM',
                  '09:00 PM',
                  '10:00 PM',
                ].map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: _selectedTime == time,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedTime = selected ? time : null;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20.0),

              // Book Appointment Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDate == null || _selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a date and time')),
                      );
                    } else {
                      // Navigate to payment screen or handle booking logic
                      print('Booking appointment on $_selectedDate at $_selectedTime');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Book Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TherapistDetailsScreen(
      therapist: {
        'name': 'Dr. Kevon Lane',
        'qualification': 'Gynecologist',
        'fees': '200',
      },
      therapistId: '12345',
    ),
  ));
}