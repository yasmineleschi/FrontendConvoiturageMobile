import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/reservation.dart';
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
  static const String baseUrl = 'http://192.168.1.14:5000/api/reservations/';

  Future<List<Reservation>> fetchReservations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return [];
    }
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch reservations');
    }
  }



  Future<void> cancelReservation(String reservationId) async {
    final url = Uri.parse('$baseUrl/$reservationId');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete reservation');
    }
  }

  Future<void> confirmReservation(String reservationId) async {
    final url = Uri.parse('$baseUrl/$reservationId/status');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': 'Confirmed'}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm reservation');
    }
  }
}



