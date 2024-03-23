import 'package:flutter/material.dart';

class OfferDetailPage extends StatelessWidget {
  final dynamic offer;

  OfferDetailPage({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offer Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offer Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('From: ${offer['departureLocation']}'),
            Text('To: ${offer['destinationLocation']}'),
            Text('Departure Date & Time: ${offer['departureDateTime']}'),
            Text('Seats Available: ${offer['seatAvailable']}'),
            Text('Seat Price: ${offer['seatPrice']}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
