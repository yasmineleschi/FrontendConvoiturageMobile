import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Favorite.dart';
import 'package:frontendcovoituragemobile/pages/Reservation/ReservationList.dart';
import 'package:frontendcovoituragemobile/pages/offers/MyOffer.dart';
import 'package:frontendcovoituragemobile/pages/Navigation/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late String _username = '';
  late String _etat = '';
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
        Uri.parse('http://192.168.1.14:5000/api/users/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _username = userData['username'];
          _userId = userId;
          _etat = userData['etat'];
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
                colors: [Color(0xFFBEEEE2), Colors.white],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/car.png'),
                ),
                Column(

                  children: [
                    Text(
                      '${_username ?? 'Unknown'}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${_etat ?? ''}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )

              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.deepOrangeAccent),
            title: Text("Home"),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NavigationBarScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.list, color: Colors.deepOrangeAccent),
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
            leading: Icon(Icons.request_page, color: Colors.deepOrangeAccent),
            title: Text('Reservations'),
            onTap: () {
              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationListScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.favorite, color: Colors.deepOrangeAccent),
            title: const Text('My Favorite'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteListPage(userId: loggedInUserId)),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.settings, color: Colors.deepOrangeAccent),
            title: Text('Settings'),
            onTap: () {

            },
          ),

          ListTile(
            leading: Icon(Icons.info, color: Colors.deepOrangeAccent),
            title: Text('About Us'),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}