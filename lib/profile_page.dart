import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'sos_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  final List<Widget> _pages = [
    HomeScreen(),
    ScheduleScreen(),
    SOSScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Color(0xFF3F51B5), // Indigo
        color: Color(0xFF0A74DA), // Deep Blue
        buttonBackgroundColor: Color(0xFF0F766E), // Teal
        height: 60,
        animationDuration: Duration(milliseconds: 400),
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.calendar_today, size: 30, color: Colors.white),
          Icon(Icons.sos, size: 30, color: Colors.white),
          Icon(Icons.message, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}