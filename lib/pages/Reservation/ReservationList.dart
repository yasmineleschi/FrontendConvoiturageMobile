import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/Model/Reservation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('http://localhost:5000/api/reservations/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch reservations');
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
              return Center(child: Text('No Reservations yet'));
            } else {
              List<Reservation> reservations = snapshot.data!;
              return ListView.builder(
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Reservation ID: ${reservation.id}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Price: ${reservation.contactInfo}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Total Price: ${reservation.paymentMethod}',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],),
                          Text(
                            'Total Price: ${reservation.totalPrice}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Number of Passengers: ${reservation.numberOfPassengers}',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Logique pour confirmer la réservation
                            },
                            child: Text('Confirm'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Logique pour annuler la réservation
                            },
                            child: Text('Cancel'),
                          ),
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

void main() {
  runApp(MaterialApp(
    home: ReservationListScreen(),
  ));
}
