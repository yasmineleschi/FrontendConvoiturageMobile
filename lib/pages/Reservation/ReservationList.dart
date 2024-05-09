import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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

    final response = await http.get(Uri.parse('http://192.168.1.15:5000/api/reservations/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch reservations');
    }
  }
  void _cancelReservation(String reservationId) async {
    final url = Uri.parse('http://192.168.1.15:5000/api/reservations/$reservationId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        // Mettre à jour la liste des réservations après l'annulation
        setState(() {
          _futureReservations = fetchReservations(); // Recharge les données à partir du serveur
        });
      } else {
        throw Exception('Failed to cancel reservation');
      }
    } catch (e) {
      print('An error occurred while cancelling reservation: $e');
    }
  }

  void _confirmReservation(String reservationId) async {
    final url = Uri.parse('http://192.168.1.15:5000/api/reservations/$reservationId/confirm');
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
      backgroundColor: Color(0xFF009C77),
      appBar: AppBar(
        title: Text(
          'Reservation List',
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
        backgroundColor: Color(0xFF009C77),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
              return ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Reservation ',
                        style: TextStyle(color: Colors.black87),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Contact info',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    '${reservation.contactInfo}',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              Column(
                                children: [
                                  Text(
                                    'Num of passengers',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    '${reservation.numberOfPassengers}',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(DateTime.parse(reservation.reservationDateTime as String)),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.reservationDateTime as String)),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Text(
                                    "Date of request",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Total Price:',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    '${reservation.totalPrice}',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Method Payement',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    '${reservation.paymentMethod}',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _confirmReservation(reservation.id);
                                },
                                child: Text('Confirm'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  _cancelReservation(reservation.id);
                                },

                                child: Text('Cancel'),
                              ),
                            ],
                          )
                        ],
                      ),

                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }


}
class Reservation {
  final String id;
  final String? contactInfo;
  final double? totalPrice;
  final int? numberOfPassengers;
  final String? reservationDateTime;
  final String? paymentMethod;
  final String? status; // Ajouter le champ status

  Reservation({
    required this.id,
    required this.contactInfo,
    required this.totalPrice,
    required this.numberOfPassengers,
    required this.reservationDateTime,
    required this.paymentMethod,
    required this.status, // Initialiser le champ status dans le constructeur
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['_id'],
      contactInfo: json['contactInfo'],
      totalPrice: json['totalPrice']?.toDouble(),
      numberOfPassengers: json['numberOfPassengers'],
      reservationDateTime: json['reservationDateTime'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: ReservationListScreen(),
  ));
}
