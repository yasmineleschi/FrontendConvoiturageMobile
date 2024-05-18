import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:frontendcovoituragemobile/pages/authentification/profile.dart';
import 'package:frontendcovoituragemobile/pages/home.dart';




class NavigationBarScreen extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBarScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [

    Placeholder(color: Colors.orange),
    HomePage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.transparent,
        color: Color(0xFF009C77),
        buttonBackgroundColor: Color(0xFF009C77),
        height: 50,
        animationDuration: Duration(milliseconds: 300),
        items: <Widget>[

          Icon(Icons.notifications, size: 30,color: Colors.white,),
          Icon(Icons.home, size: 30 ,color: Colors.white,),
          Icon(Icons.account_circle, size: 30,color: Colors.white,),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

