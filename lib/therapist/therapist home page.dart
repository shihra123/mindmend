import 'package:flutter/material.dart';
import 'package:mindmend/therapist/therapist%20meditation.dart';
import 'package:mindmend/therapist/therapist%20messaging%20screen.dart';
import 'package:mindmend/therapist/therapist%20notification.dart';
import 'package:mindmend/therapist/view%20appointment.dart';

class TherapistHomePage extends StatefulWidget {
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TherapistNotificationsScreen(),
    MeditationScreen(),
    TherapistAppointmentsScreen(),
    ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: Colors.white70,
            backgroundColor: Colors.deepOrangeAccent,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications, size: 30),
                label: "Notifications",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.self_improvement, size: 30),
                label: "Meditation",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today, size: 30),
                label: "Appointments",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message, size: 30),
                label: "Messages",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

