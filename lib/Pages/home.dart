import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Navigation/SideBar.dart';
import 'authentification/profile.dart';

import 'package:intl/intl.dart';
import 'offers/DetailTrajet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'offers/AddTrajet.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _offers = [];
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponible':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Indisponible':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
  TextEditingController _dateController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _departureController = TextEditingController();

  String? _selectedDate;
  String? _selectedDestination;
  String? _selectedDeparture;

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<Map<String, dynamic>> _fetchUserData(String user) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.14:5000/api/users/profile/$user'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('User data for $user: $userData'); // Log user data
        return userData;
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  Future<void> _fetchOffers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.14:5000/api/car/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // Traiter les offres en utilisant processOffers
        List<dynamic> processedOffers = processOffers(json.decode(response.body));
        setState(() {
          _offers = processedOffers;
        });
      } else {
        throw Exception('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
      // Handle error here (e.g., show Snackbar or AlertDialog)
    }
  }

  Future<void> _showDestinationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Destination'),
          content: TextField(
            controller: _destinationController,
            decoration: InputDecoration(hintText: "Destination"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _selectedDestination = _destinationController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDepartureDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Departure'),
          content: TextField(
            controller: _departureController,
            decoration: InputDecoration(hintText: "Departure"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  _selectedDeparture = _departureController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<dynamic> _applyFilters() {
    List<dynamic> filteredOffers = List.from(_offers);

    if (_selectedDestination != null) {
      filteredOffers = filteredOffers.where((offer) => offer['destinationLocation'] == _selectedDestination).toList();
    }
    if (_selectedDeparture != null) {
      filteredOffers = filteredOffers.where((offer) => offer['departureLocation'] == _selectedDeparture).toList();
    }

    // If no filters are applied, return all offers
    if ( _selectedDestination == null && _selectedDeparture == null) {
      return _offers;
    }

    return filteredOffers;
  }
  List<dynamic> processOffers(List<dynamic> _offers) {

    List<dynamic> filteredOffers = _offers.where((offer) => offer['status'] != 'Indisponible').toList();


    filteredOffers.sort((a, b) {
      if (a['status'] == 'Disponible' && b['status'] != 'Disponible') {
        return -1;
      } else if (a['status'] != 'Disponible' && b['status'] == 'Disponible') {
        return 1;
      } else if (a['status'] == 'En cours' && b['status'] != 'En cours') {
        return -1;
      } else if (a['status'] != 'En cours' && b['status'] == 'En cours') {
        return 1;
      } else {
        return 0;
      }
    });

    return filteredOffers;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredOffers = _applyFilters();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009C77),
        title: Text('Home',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [

        ],
      ),


      body: Column(

        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),

          Divider(
            color: Colors.grey,
            thickness: 2.0,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              GestureDetector(
                onTap: () {
                  // Show destination text input
                  _showDestinationDialog(context);
                },
                child: Column(
                  children: [
                    Icon(Icons.location_on),
                    Text('Destination'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show departure text input
                  _showDepartureDialog(context);
                },
                child: Column(
                  children: [
                    Icon(Icons.departure_board),
                    Text('Departure'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 2.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 2.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Align buttons to the center
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = true; // Show all offers
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF009C77), // Background color
                  ),
                  child: Text(
                    'Show Offers',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
                SizedBox(width: 10), // Add some space between the buttons
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                      _selectedDestination = null;
                      _selectedDeparture = null;
                      _isSearching = false; // Reset the search
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDA6D35), // Background color
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh, // Change the icon to restart or refresh icon
                        color: Colors.white,
                      ),
                      SizedBox(width: 5), // Add some space between the icon and text
                      Text(
                        'Restart',
                        style: TextStyle(
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),



          if (_isSearching)
            Expanded(
              child: ListView.builder(
                itemCount: filteredOffers.length,
                itemBuilder: (BuildContext context, int index) {
                  final offer = filteredOffers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OfferDetailPage(offer: offer),
                        ),
                      );
                    },

                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [ Color(0xFFFFFFFF)],

                        ),
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
                                  FutureBuilder<Map<String, dynamic>>(
                                    future: _fetchUserData(offer['user'].toString()), // Assuming 'userId' exists in offer
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Text('Loading...'); // Placeholder text while loading
                                      } else {
                                        if (snapshot.hasData && snapshot.data != null) {
                                          final username = snapshot.data!['username'] as String?;
                                          return Text(username ?? 'Unknown User'); // Display username if available
                                        } else {
                                          return Text('Unknown User'); // Fallback if username is not available
                                        }
                                      }
                                    },
                                  ),
                                  SizedBox(height: 4.0),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        DateFormat('HH:mm').format(DateTime.parse(offer['departureDateTime'])),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,

                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(DateTime.parse(offer['departureDateTime'])),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),

                                      ),
                                      Text(
                                        "Starting at",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),

                                      ),
                                    ],
                                  ),

                                  Column(
                                    children: [
                                      Text(
                                        '${offer['seatPrice']}/Dt ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Price',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${offer['seatAvailable']} ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Seat Available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(height: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(children: [

                                    Image.asset(
                                      'assets/images/depart.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${offer['departureLocation']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],),

                                  SizedBox(height: 10),
                                  Row(children: [
                                    Image.asset(
                                      'assets/images/destination.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${offer['destinationLocation']}',

                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),

                                  ],),

                                ],
                              ),

                              Divider(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Status :',
                                    style: TextStyle(
                                      fontSize: 14, color: Colors.black,      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${offer['status']}',
                                    style: TextStyle(
                                      fontSize: 12,

                                      color: _getStatusColor(offer['status']),
                                    ),
                                  ),

                                ],),
                              SizedBox(height: 12),

                            ],
                          ),


                        ],
                      ),
                    ),
                  );
                },
              ),
            )

          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text(
                    'Nothing to show yet',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Do your search',
                    style: TextStyle(
                      color: Color(0xFFDA6D35),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      drawer: SideBar(),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF009C77),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTrajet()),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }



}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
