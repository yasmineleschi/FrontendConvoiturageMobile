import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class FavoriteListPage extends StatefulWidget {
  final String? userId;

  FavoriteListPage({required this.userId});

  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  List<dynamic> favorites = [];

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      fetchFavorites();
    }
  }

  Future<void> fetchFavorites() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.15:5000/api/favorie/${widget.userId}'));
    if (response.statusCode == 200) {
      setState(() {
        favorites = json.decode(response.body);
      });
    } else {
      print('Failed to fetch favorites: ${response.statusCode}');
    }
  }

  Future<String?> fetchUser(String userId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.15:5000/api/user/$userId'),
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return userData['image'];
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    final response = await http.delete(
        Uri.parse('http://192.168.1.15:5000/api/favorie/$favoriteId'));

    if (response.statusCode == 200) {
      fetchFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorite deleted successfully')));
    } else {
      throw Exception('Failed to remove favorite');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009C77),
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? Center(
        child: Text(
          'No favorites yet',
          style: TextStyle(fontSize: 18),
        ),
      )
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 0.7,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          final user = favorite['User'];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                // Action when tapping on the favorite item
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFFFFF)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${favorite['car']['departureLocation']} ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${favorite['car']['destinationLocation']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Date & Time Departure: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(favorite['car']['departureDateTime']))}',
                          ),
                          Text(
                            ' ${DateFormat(' HH:mm').format(DateTime.parse(favorite['car']['departureDateTime']))}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      removeFavorite(favorite['_id']);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
