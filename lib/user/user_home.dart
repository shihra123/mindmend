import 'package:flutter/material.dart';
import 'package:mindmend/user/homescreen.dart';
import 'package:mindmend/user/user_notification%20screen.dart';
import 'package:mindmend/user/user_profile_screen.dart';
import 'package:mindmend/user/userappointmentscreen.dart'; // Importing My Appointments Screen

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    HomePageScreen(), // Home Page
    UserProfileScreen(), // User Profile
    BookAppointmentScreen(), // My Appointments
  //  UserMessagingScreen(), // Messaging
  ];

  // Method to handle the tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white70,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "My Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Messaging",
          ),
        ],
      ),
    );
  }
}
