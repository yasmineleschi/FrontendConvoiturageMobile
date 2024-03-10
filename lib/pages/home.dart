import 'package:flutter/material.dart';
import 'profile.dart';
import 'sidebar.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home '),
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open the sidebar
          },
          icon: Icon(Icons.menu),
        ),
        actions: [
          // Add an IconButton for the user profile
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilPage()), // Navigate to the profile page
              );
            },
            icon: CircleAvatar(
              // Placeholder user image (replace with actual user image)
              backgroundImage: AssetImage('assets/images/car.png'),
            ),
          ),
        ],
      ),
      drawer: SideBar(), // Add your Sidebar widget here
      body: const Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
