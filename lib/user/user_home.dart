import 'package:flutter/material.dart';
import 'package:mindmend/user/homescreen.dart';
import 'package:mindmend/user/user_profile_screen.dart';
import 'package:mindmend/user/userappointmentscreen.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

 
  final List<Widget> _pages = [
    HomePageScreen(), 
    UserProfileScreen(),
    BookAppointmentScreen(), 
  //  UserMessagingScreen(), 
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
