import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Favorite.dart';
import 'package:frontendcovoituragemobile/pages/ReservationList.dart';
import 'package:frontendcovoituragemobile/pages/test.dart';
import 'package:frontendcovoituragemobile/pages/offers/MyOffer.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late String _username = '';
  late String _userId = '';
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  late String? loggedInUserId;
  late String? loggedInCarId;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    getUserId().then((userId) {
      loggedInUserId = userId;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.15:5000/api/users/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _username = userData['username'];
          _userId = userData['_id'];
        });
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFF009C77)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/car.png'),
                ),
                SizedBox(height: 10),
                Text(
                  _username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );

            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('My Offers'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOffersPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.favorite),
            title: const Text('My Favorite'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteListPage(userId: loggedInUserId)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: const Text('reservation'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationList()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: const Text('test'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {

            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}
