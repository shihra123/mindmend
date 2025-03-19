import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindmend/user/payment.dart';

class TherapistDetailsScreen extends StatefulWidget {
  final String therapistId;

  TherapistDetailsScreen({required this.therapistId, required Map therapist});

  @override
  _TherapistDetailsScreenState createState() => _TherapistDetailsScreenState();
}

class _TherapistDetailsScreenState extends State<TherapistDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? therapistDetails;
  DateTime? _selectedDate; // Variable to store the selected date

  @override
  void initState() {
    super.initState();
    _fetchTherapistDetails();
  }

  Future<void> _fetchTherapistDetails() async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('therapists')
          .doc(widget.therapistId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          therapistDetails = docSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print("Therapist not found in Firestore");
      }
    } catch (e) {
      print("Error fetching therapist details: $e");
    }
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      print('Selected Date: $_selectedDate');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: therapistDetails != null
            ? Text(therapistDetails!['name'] ?? "Therapist Details")
            : Text("Therapist Details"),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: therapistDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                              backgroundImage: therapistDetails!['profileImage'] != null
                                  ? NetworkImage(therapistDetails!['profileImage'])
                                  : null,
                              child: therapistDetails!['profileImage'] == null
                                  ? Icon(Icons.person, size: 40, color: Colors.grey)
                                  : null,
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    therapistDetails!['name'] ?? "Unknown",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    therapistDetails!['qualification'] ?? "Not specified",
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    "\$${therapistDetails!['fees']}",
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
                      onPressed: () => _selectDate(context),
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
                        return Chip(
                          label: Text(time),
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.0),

                    // Book Appointment Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please select a date')),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(),
                              ),
                            );
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