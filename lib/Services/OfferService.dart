import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontendcovoituragemobile/model/offer.dart';

class OfferService {
  static Future<List<Offer>> fetchOffers() async {
    final response = await http.get(Uri.parse('http://192.168.1.14:5000/api/car/api/offers'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((offerData) => Offer(
        id: offerData['_id'],
        departureLocation: offerData['departureLocation'],
        destinationLocation: offerData['destinationLocation'],
        departureDateTime: offerData['departureDateTime'],
        seatAvailable: offerData['seatAvailable'],
        seatPrice: offerData['seatPrice'],
        userId: offerData['user'],
        numberOfPassengers: offerData['numberOfPassengers'] ?? 0,
      )).toList();
    } else {
      throw Exception('Failed to fetch offers');
    }
  }

  static Future<void> addComment(String userId, String carId, String content) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$carId');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({'user': userId, 'car': carId, 'content': content});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  }

  static Future<void> deleteComment(String commentId) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$commentId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
