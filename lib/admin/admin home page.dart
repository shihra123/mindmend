import 'package:flutter/material.dart';
import 'package:mindmend/admin/admin%20view%20appointment.dart';
import 'package:mindmend/admin/manage%20therapist.dart';
import 'package:mindmend/admin/view%20feedback.dart';
import 'package:mindmend/admin/view%20users.dart';

// Placeholder screens with card styling
//class ViewUsersScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("View Users"),
      backgroundColor: Colors.deepOrangeAccent,
    ),
    body: Center(
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "View Users Page",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

// Main Admin Home Page with Bottom Navigation Bar
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ViewUsersScreen(), // View Users Page
    ManageTherapistScreen(), // Manage Therapists Page
    ViewFeedbackScreen(), // View Feedback Page
    AppointmentDetailsScreen(), // View Appointments Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display selected page

      // Bottom Navigation Bar for Admin
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.deepOrangeAccent,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: "View Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add, size: 30),
            label: "Manage Therapists",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback, size: 30),
            label: "View Feedback",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule, size: 30),
            label: "View Appointments",
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminHomePage(),
  ));
}
