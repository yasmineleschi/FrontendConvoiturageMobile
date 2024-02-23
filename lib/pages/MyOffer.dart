import 'UpdaitOffre.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Filter by Destination'),
                  content: TextField(
                    onChanged: (value) {
                      _filterOffersByDestination(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter destination...',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'This is the List of My Offers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 2.0,
          ),
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
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
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
                                SizedBox(height: 4.0),
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
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Departure: ${offer['departureLocation']} -> Destination: ${offer['destinationLocation']}'),
                                  SizedBox(height: 4.0),
                                  Text('Departure Date: ${DateTime.parse(offer['departureDateTime']).toString()}'),
                                  SizedBox(height: 4.0),
                                  Text('Available Seats: ${offer['seatAvailable']}'),
                                  SizedBox(height: 8.0),
                                  Center( // Wrap the Row with Center widget
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the center
                                      children: [

                                        IconButton(
                                          onPressed: () {
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
                                          icon: Icon(
                                            Icons.update,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
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
