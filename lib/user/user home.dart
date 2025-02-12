import 'package:flutter/material.dart';
import 'package:mindmend/user/home%20screen.dart';
import 'package:mindmend/user/user%20appointment%20screen.dart';
import 'package:mindmend/user/user%20messaging.dart';
import 'package:mindmend/user/user%20notification%20screen.dart';
import 'package:mindmend/user/user%20profile%20screen.dart';
// Messaging Screen

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageScreen(),
    BookAppointmentScreen(),
    NotificationsScreen(),
    UserMessagingScreen(), // Messaging Page
    UserProfileScreen(),
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

      // Bottom Navigation Bar with Messaging
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.deepOrangeAccent,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Messaging", // Chat Feature
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
