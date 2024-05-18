import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentService {
  static Future<List<dynamic>> fetchComments(String carId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.14:5000/api/car/api/comments/$carId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  static Future<void> addComment(
      String userId, String carId, String content) async {
    final url =
    Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$carId');
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
    final url =
    Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$commentId');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
