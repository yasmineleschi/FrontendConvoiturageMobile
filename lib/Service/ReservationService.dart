import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ReservationService {
  static const String baseUrl = 'http://192.168.1.15:5000/api';
  static IO.Socket? socket;

  static Future<void> sendReservation(String userId, String carId) async {
    final String url = '$baseUrl/reservation/';
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': userId,
          'carId': carId,
        }),
      );
      if (response.statusCode == 201) {
        print('Reservation sent successfully');
        // Emit socket event to notify server about new reservation
        if (socket != null && socket!.connected) {
          socket!.emit('reservation', {'userId': userId, 'carId': carId});
        }
      } else {
        throw Exception('Failed to send reservation');
      }
    } catch (error) {
      print('Error sending reservation: $error');
      throw error;
    }
  }
}

