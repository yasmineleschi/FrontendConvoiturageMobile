import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:frontendcovoituragemobile/pages/offers/AddTrajet.dart';
import 'package:frontendcovoituragemobile/pages/offers/UpdaitOffre.dart';
import 'package:frontendcovoituragemobile/pages/offers/DetailTrajet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Navigation/SideBar.dart';
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  List<dynamic> processOffers(List<dynamic> _offers) {

    _offers.sort((a, b) {
      // Ordre de tri: 'Disponible' < 'En cours' < 'Indisponible'
      if (a['status'] == 'Disponible') {
        return -1;
      } else if (b['status'] == 'Disponible') {
        return 1;
      } else if (a['status'] == 'En cours') {
        return -1;
      } else if (b['status'] == 'En cours') {
        return 1;
      } else {
        return 0;
      }
    });

    // Retourner la liste triée
    return _offers;
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
        // Récupérer les offres depuis la réponse
        List<dynamic> fetchedOffers = json.decode(response.body);

        // Trier les offres par statut
        List<dynamic> sortedOffers = processOffers(fetchedOffers);

        // Mettre à jour l'état avec les offres triées
        setState(() {
          _offers = sortedOffers;
          filteredOffers = List.from(sortedOffers);
        });
      } else {
        throw Exception('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009C77),
        title: Text(
          'My Offers',
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
      body: Container(
        color: Colors.grey[200], // Grey background for the entire body
        child: Column(
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
                    fillColor: Colors.white, // White background for the search box
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
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
                                          status: offer['status'].toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.orangeAccent),
                                      SizedBox(width: 4),
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () => deleteCar(offer['_id']),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        backgroundColor: Color(0xFF009C77),
      ),
    );
  }
}
