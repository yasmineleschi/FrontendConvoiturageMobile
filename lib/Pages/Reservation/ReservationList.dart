import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/Model/Reservation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationListScreen extends StatefulWidget {
  @override
  _ReservationListScreenState createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  late Future<List<Reservation>> _futureReservations;

  @override
  void initState() {
    super.initState();
    _futureReservations = fetchReservations();
  }

  Future<List<Reservation>> fetchReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return [];
    }

    final response = await http
        .get(Uri.parse('http://192.168.1.14:5000/api/reservations/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch reservations');
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    final url =
        Uri.parse('http://192.168.1.14:5000/api/reservations/$reservationId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _futureReservations = fetchReservations();
        });
      } else {
        throw Exception('Failed to delete reservation');
      }
    } catch (e) {
      print('An error occurred while deleting reservation: $e');
    }
  }

  void _confirmReservation(String reservationId) async {
    final url = Uri.parse(
        'http://192.168.1.14:5000/api/reservations/$reservationId/status');
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        setState(() {
          _futureReservations = fetchReservations();
        });
      } else {
        throw Exception('Failed to confirm reservation');
      }
    } catch (e) {
      print('An error occurred while confirming reservation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009C77),
      appBar: AppBar(
        title: const Text(
          'My request',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF009C77),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFECECEC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: FutureBuilder<List<Reservation>>(
          future: _futureReservations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to fetch reservations'));
            } else {
              List<Reservation> reservations = snapshot.data!;
              return reservations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/animations/request.json',
                              width: 150),
                          SizedBox(height: 16),
                          const Text(
                            'No Requests Yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF009C77)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Go Back',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ListTile(
                              title: Text(
                                'Reservation ${index + 1}',
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Contact Info: ',
                                        style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${reservation.contactInfo}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Payment Method: ',
                                        style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${reservation.paymentMethod}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Total Price: ',
                                        style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${reservation.totalPrice}/DT',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Passengers: ',
                                        style: TextStyle(
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('${reservation.numberOfPassengers}',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (reservation.status == 'Confirmed')
                                    Text(
                                      'Status: Confirmed',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    )
                                  else
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFF009C77)),
                                          ),
                                          onPressed: () => _confirmReservation(
                                              reservation.id),
                                          child: Text(
                                            'Confirm',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                          ),
                                          onPressed: () => _cancelReservation(
                                              reservation.id),
                                          child: Text(
                                            'refuse',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ));
                      },
                    );
            }
          },
        ),
      ),
    );
  }
}
