import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoriteService {
  Future<List<dynamic>> getFavorites(String userId) async {
    final response = await http.get(
        Uri.parse('http://192.168.1.14:5000/api/favorie/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch favorites: ${response.statusCode}');
    }
  }
  Future<void> addFavorite(String userId, String carId) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/favorie/$userId/$carId');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({'user': userId, 'car': carId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 201) {
      throw Exception('Failed to add favorite');
    }
  }
  Future<void> removeFavorite(String favoriteId) async {
    final response = await http
        .delete(Uri.parse('http://192.168.1.14:5000/api/favorie/$favoriteId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to remove favorite');
    }
  }

  Future<dynamic> getUserData(String userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.14:5000/api/user/$userId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user data');
    }
  }
}
