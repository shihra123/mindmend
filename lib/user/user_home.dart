import 'package:flutter/material.dart';
import 'package:mindmend/user/homescreen.dart';
import 'package:mindmend/user/user_messaging.dart';
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
    NotificationsScreen(userId: '',), // Notifications
    BookAppointmentScreen(), // My Appointments
    UserMessagingScreen(), // Messaging
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
      body: _pages[_selectedIndex], // Show selected page

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black,
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
            icon: Icon(Icons.notifications),
            label: "Notifications",
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
