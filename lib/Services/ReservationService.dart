import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservationService {
  static Future<void> createReservation(
      String offerUserId,
      String passengerUserId,
      String carId,
      int numberOfPassengers,
      int totalPrice,
      String paymentMethod,
      String contactInfo,
      ) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/reservations/');
    final data = {
      'userId': offerUserId,
      'passengerid': passengerUserId,
      'carId': carId,
      'numberOfPassengers': numberOfPassengers.toString(),
      'totalPrice': totalPrice.toString(),
      'paymentMethod': paymentMethod,
      'contactInfo': contactInfo,
    };

    final response = await http.post(
      url,
      body: jsonEncode(data),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reservation');
    }
  }
}
