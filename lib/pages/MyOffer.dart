import 'UpdaitOffre.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'SideBar.dart' ;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class MyOffersPage extends StatefulWidget {
  @override
  _MyOffersPageState createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  List<dynamic> _offers = [];
  List<dynamic> _filteredOffers = [];

  @override
  void initState() {
    super.initState();
    _getUserIDAndFetchOffers();
  }

  Future<void> _getUserIDAndFetchOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('User ID is null');
      }
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/car/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _offers = json.decode(response.body);
          _filteredOffers = List.from(_offers);
        });
      } else {
        throw Exception('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }


  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/users/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  void _filterOffersByDestination(String destination) {
    setState(() {
      _filteredOffers = _offers.where((offer) =>
          offer['destinationLocation']
              .toString()
              .toLowerCase()
              .contains(destination.toLowerCase())).toList();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Offers'),
        centerTitle: true,

        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Search by Destination'),
                  content: TextField(
                    onChanged: (value) {
                      _filterOffersByDestination(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter destination...',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: SideBar(), // Add the sidebar here


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 9.0,
                mainAxisSpacing: 9.0,
              ),
              itemCount: _filteredOffers.length,
              itemBuilder: (BuildContext context, int index) {
                final offer = _filteredOffers[index];
                return FutureBuilder(
                  future: _fetchUserData(offer['user']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final userData = snapshot.data ?? {};
                    return SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF009C77), Colors.white38, Color(0xFF009C77)]
                            )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage('assets/images/car.png'),
                                ),
                                SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userData['username'] ?? ''),
                                    SizedBox(height: 4.0),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: offer['image'] != null
                                    ? Image.network(
                                  'http://localhost:5000/uploads/${offer['image']}',
                                  width: 200, // Adjusted width
                                  height: 100, // Adjusted height
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                  },
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    print('Error loading image: $error');
                                    return Icon(Icons.error);
                                  },
                                )
                                    : Icon(Icons.image_not_supported),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/img_6.png',
                                  width: 24,
                                  height: 24,
                                ),

                                SizedBox(width: 10),
                                Text('${offer['departureLocation']} --> '),
                                SizedBox(width: 10),
                                Image.asset(
                                  'assets/images/img_6.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 4.0),
                                Text('${offer['destinationLocation']}'), // Text for Destination Location
                              ],
                            ),
                            SizedBox(height: 4.0),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/img_7.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 4.0),
                                Text(' ${DateTime.parse(offer['departureDateTime']).toString()}'), // Text for Departure Date
                              ],
                            ),
                            SizedBox(height: 4.0),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/img_8.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 4.0),
                                Text('${offer['seatAvailable']}'),
                                SizedBox(width: 20.0),
                                Image.asset(
                                  'assets/images/img_9.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(width: 4.0),
                                Text('${offer['seatPrice']}'),
                              ],
                            ),

                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {

                                  },
                                  child: Image.asset(
                                    'assets/images/img_5.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                SizedBox(width: 70),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateOffrePage(
                                          offerId: offer['_id'].toString(),
                                          departureDateTime: offer['departureDateTime'].toString(),
                                          departureLocation: offer['departureLocation'].toString(),
                                          destinationLocation: offer['destinationLocation'].toString(),
                                          seatPrice: offer['seatPrice'].toString(),
                                          seatAvailable: offer['seatAvailable'].toString(),
                                          model: offer['model'].toString(),
                                          matricule: offer['matricule'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/img_4.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyOffersPage(),
  ));
}
