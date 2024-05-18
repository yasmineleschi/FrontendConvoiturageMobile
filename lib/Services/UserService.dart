import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.14:5000/api/users/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch user details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching user details: $e');
    }
  }
}
