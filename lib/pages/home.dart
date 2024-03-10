import 'package:flutter/material.dart';
import 'profile.dart';
import 'sidebar.dart';
import 'AddTrajet.dart'; // Import the AddOffer page

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open the sidebar
          },
          icon: Icon(Icons.menu),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: CircleAvatar(
              // Placeholder user image (replace with actual user image or adjust as needed)
              backgroundImage: AssetImage('assets/images/car.png'),
            ),
          ),
        ],
      ),
      drawer: SideBar(), // Add your Sidebar widget here
      body: Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addOffer');
        },
        backgroundColor: Color(0xFF009C77), // Set button color
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position the button at the bottom right
    );
  }
}
