import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Home Page'),
        actions: [

          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');

            },
            icon: const CircleAvatar(
              // Placeholder user image (replace with actual user image or adjust as needed)
              backgroundImage: AssetImage('assets/images/car.png'), // Ensure the asset exists or adjust accordingly
            ),
          ),
        ],
      ),

      body: Center(
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
          onTap: () {

          },
        ),

      ],
    );
  }
}
