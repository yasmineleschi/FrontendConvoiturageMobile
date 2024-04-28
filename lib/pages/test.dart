import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<String> reservations = [];
 IO.Socket ? socket;

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://192.168.1.15:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    socket!.on('all_reservations', (reservationsData) {
      setState(() {
        reservationsData.forEach((reservation) {
          reservations.add(reservation['userId'] + ' reserved a car with ID: ' + reservation['carId']);
        });
      });
    });
    socket!.on('new_reservation', (savedReservation) {
      setState(() {
        reservations.add(savedReservation['userId'] + ' reserved a car with ID: ' + savedReservation['carId']);
      });
    });
  }

  void _addReservation() {
    socket!.emit('reservation', {
      'userId': _nameController.text,
      'carId': _dateController.text,
    });
    _nameController.clear();
    _dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Reservation')),
      body: Column(
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(labelText: 'User ID')),
          TextField(controller: _dateController, decoration: InputDecoration(labelText: 'Car ID')),
          ElevatedButton(onPressed: _addReservation, child: Text('Add Reservation')),
          SizedBox(height: 20),
          Text('Reservations:', style: TextStyle(fontSize: 20)),
          ListView.builder(
            shrinkWrap: true,
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(reservations[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}