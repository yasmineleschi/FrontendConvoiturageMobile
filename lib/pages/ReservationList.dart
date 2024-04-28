import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Reservation {
  final String? id;
  final DateTime? date;

  Reservation({required this.id, required this.date});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['_id'],
      date: DateTime.parse(json['date']),
    );
  }
}

class ReservationList extends StatefulWidget {
  @override
  _ReservationListState createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {

  List<Reservation> reservations = [];

  @override
  void initState() {
    super.initState();

    fetchReservations().then((reservations) {
      setState(() {
        this.reservations = reservations;
      });
    }).catchError((error) {
      print('Error loading user data: $error');
    });
  }

  Future<List<Reservation>> fetchReservations() async {
    final response = await http.get(Uri.parse('http://192.168.1.15:5000/api/reservation/'));
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> reservations = json.decode(response.body);
      return reservations.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reservations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation List'),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: fetchReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );

          } else {
            // Afficher la liste des réservations et écouter les mises à jour en temps réel
            return ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                Reservation reservation = reservations[index];
                return ListTile(
                  title: Text('Reservation ID: ${reservation.id}'),
                  subtitle: Text('Date: ${reservation.date.toString()}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}