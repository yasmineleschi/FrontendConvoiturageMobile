import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CommentService {
  static Future<List<dynamic>> fetchComments(String carId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$carId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  static Future<void> addComment(String userId, String carId, String content) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$carId');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'userId': userId,
      'carId': carId,
      'content': content,
      'datecreation': DateTime.now().toIso8601String(),
    });

    try {
      print('Sending comment request: userId=$userId, carId=$carId, content=$content');
      final response = await http.post(url, headers: headers, body: body);
      print('Comment response status code: ${response.statusCode}');
      print('Comment response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Comment added successfully');
      } else {
        final errorBody = jsonDecode(response.body);
        print('Error response: ${errorBody['error']}');
        throw Exception('Failed to add comment: ${errorBody['error']}');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      rethrow;
    } on FormatException catch (e) {
      print('JSON format error: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  static Future<void> deleteComment(String commentId) async {
    final url = Uri.parse('http://192.168.1.14:5000/api/car/api/comments/$commentId');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Failed to delete comment: ${errorBody['error']}');
    }
  }
}
