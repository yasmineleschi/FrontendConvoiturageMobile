import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfferDetailPage extends StatefulWidget {
  final dynamic offer;

  OfferDetailPage({required this.offer});

  @override
  _OfferDetailPageState createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  List<dynamic> comments = [];
  TextEditingController _commentController = TextEditingController();
  late String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    fetchComments();
    getUserId().then((userId) {
      loggedInUserId = userId;
    });
  }

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/car/api/comments/${widget.offer['_id']}'));
    if (response.statusCode == 200) {
      setState(() {
        comments = json.decode(response.body);
      });
    } else {
      // Handle error, maybe show a Snackbar or an AlertDialog
      print('Failed to fetch comments: ${response.statusCode}');
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _sendComment() async {
    final commentContent = _commentController.text;
    final userId = loggedInUserId; // Retrieve user ID

    if (userId != null) {
      final carId = widget.offer['_id']; // Extract car ID from the offer object
      final url = Uri.parse('http://localhost:5000/api/car/api/comments/$carId');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final body = jsonEncode({'user': userId, 'car': carId, 'content': commentContent});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        fetchComments();
        _commentController.clear();
      } else {
        // Handle error
      }
    } else {
      // Handle error (user ID not found in SharedPreferences)
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final url = Uri.parse('http://localhost:5000/api/car/api/comments/$commentId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Reload comments after deletion
      fetchComments();
    } else {
      // Handle error
      print('Failed to delete comment: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offer Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Offer Details Card
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 200.0, // Set your desired width
                    height: 200.0, // Set your desired height
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                        image: DecorationImage(
                          image: AssetImage('assets/images/car.png'), // Use your offer image here
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              '${widget.offer['departureLocation']} to ${widget.offer['destinationLocation']}',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Text(
                            'Date: ${widget.offer['departureDateTime']}',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.event_seat, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Text(
                            'Seats Available: ${widget.offer['seatAvailable']}',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Text(
                            'Seat Price: ${widget.offer['seatPrice']}',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments Section
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final String userId = comment['user']['_id']; // User ID of the comment author
                final bool isCurrentUserComment = userId == loggedInUserId;

                return ListTile(
                  title: Text(
                    comment['user']['username'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment['content'] ?? ''),
                  trailing: isCurrentUserComment ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Implement logic to delete the comment
                      _deleteComment(comment['_id']);
                    },
                  ) : null,
                );
              },
            ),
          ),

          // Comment Input Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(labelText: 'Add a comment'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendComment();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
