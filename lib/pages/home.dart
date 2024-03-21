import 'package:flutter/material.dart';
import 'authentification/profile.dart';
import 'sidebar.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'offers/AddTrajet.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _offers = [];
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
        Uri.parse('http://192.168.1.15:5000/api/users/profile/$user'),
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
        Uri.parse('http://192.168.1.15:5000/api/car/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _offers = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
      // Handle error here (e.g., show Snackbar or AlertDialog)
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked.toString();
        _dateController.text = _selectedDate!;
      });
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


  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredOffers = _applyFilters();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/images/car.png'),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,

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
                    primary: Color(0xFF009C77), // Background color
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
                    primary: Color(0xFFDA6D35), // Background color
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
                      // Handle offer details navigation here
                    },

                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFD9D9D9), Color(0xFFD9D9D9)]
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
                          Row(
                            children: [
                              Text(
                                '${offer['departureLocation']} --> ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${offer['destinationLocation']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 70),
                              Image.asset(
                                'assets/images/img_8.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${offer['seatAvailable']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy , HH:mm').format(
                                    DateTime.parse(
                                        offer['departureDateTime'])),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 70),
                              Image.asset(
                                'assets/images/img_9.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '${offer['seatPrice']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
  // Initialize WebView
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
