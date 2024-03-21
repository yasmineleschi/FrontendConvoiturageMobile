


import 'package:frontendcovoituragemobile/pages/offers/AddTrajet.dart';
import 'package:frontendcovoituragemobile/pages/offers/UpdaitOffre.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../SideBar.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyOffersPage extends StatefulWidget {
  @override
  _MyOffersPageState createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  List<dynamic> _offers = [];
  List<dynamic> filteredOffers = [];

  @override
  void initState() {
    super.initState();
    _getUserIDAndFetchOffers();
  }

  Future<void> deleteCar(String carId) async {
    final url = 'http://192.168.1.15:5000/api/car/$carId';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _getUserIDAndFetchOffers();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Car deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _getUserIDAndFetchOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('User ID is null');
      }
      final response = await http.get(
        Uri.parse('http://192.168.1.15:5000/api/car/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _offers = json.decode(response.body);
          filteredOffers = List.from(_offers);
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
        Uri.parse('http://192.168.1.15:5000/api/users/profile/$userId'),
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
    if (destination.isEmpty) {
      setState(() {
        filteredOffers = List.from(_offers);
      });
    } else {
      setState(() {
        filteredOffers = _offers
            .where((offer) => offer['destinationLocation']
            .toString()
            .toLowerCase()
            .contains(destination.toLowerCase()))
            .toList();
      });
    }
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

      ),
      drawer: SideBar(),


      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextField(
                onChanged: (value) {
                  _filterOffersByDestination(value);
                },
                decoration: InputDecoration(
                  hintText: 'Enter destination...',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9), // Background color
                  contentPadding: const  EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Padding around the text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Border radius
                    borderSide: BorderSide.none, // No border
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Perform search action
                    },
                  ),
                ),
              ),
            ),
          ),
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
                      gradient:const  LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFD9D9D9), Color(0xFFD9D9D9)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy , HH:mm').format(DateTime.parse(offer['departureDateTime'])),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 70),
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
                        SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpdateOffrePage(
                                          offerId:
                                          offer['_id'].toString(),
                                          departureDateTime: offer[
                                          'departureDateTime']
                                              .toString(),
                                          departureLocation: offer[
                                          'departureLocation']
                                              .toString(),
                                          destinationLocation: offer[
                                          'destinationLocation']
                                              .toString(),
                                          seatPrice: offer['seatPrice']
                                              .toString(),
                                          seatAvailable: offer[
                                          'seatAvailable']
                                              .toString(),
                                          model: offer['model'].toString(),
                                          matricule: offer['matricule']
                                              .toString(),
                                        ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/img_4.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Edit Offre ',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                           const  SizedBox(width: 30),
                            InkWell(
                              onTap: () => deleteCar(offer['_id']),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/img_5.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Delete Offre',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
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
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTrajet()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Set text color to white
              ),
              child: const Padding(
                padding:  EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Add Trajet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
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
