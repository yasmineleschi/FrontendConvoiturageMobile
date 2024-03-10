import 'package:flutter/material.dart';
import 'authentification/profile.dart';
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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const CircleAvatar(
              // Placeholder user image (replace with actual user image or adjust as needed)
              backgroundImage: AssetImage(
                  'assets/images/car.png'), // Ensure the asset exists or adjust accordingly
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

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Add Offer'),
          onTap: () {
            Navigator.pushNamed(context, '/addOffer'); // Close the drawer
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {},
        ),
      ],
    );
  }
}