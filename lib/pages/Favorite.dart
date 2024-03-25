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
      Uri.parse('http://192.168.1.15:5000/api/user/$userId'), // Assurez-vous que votre API prend en charge cette route pour récupérer les détails de l'utilisateur par son ID
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return userData['image'];
    } else {
      throw Exception('Failed to fetch user data');
    }
  }
  Future<void> removeFavorite(String favoriteId) async {
    final response = await http
        .delete(Uri.parse('http://192.168.1.15:5000/api/favorie/$favoriteId'));

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
          'My Favorite',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favorite = favorites[index];
          final user = favorite['User']; // Récupérer l'utilisateur
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                '${favorite['car']['departureLocation']} To ${favorite['car']['destinationLocation']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Column(
                children: [
                  Text('Date & Time Departure: ${DateFormat('dd/MM/yyyy , HH:mm').format(DateTime.parse(favorite['car']['departureDateTime']))}',
                  ),
                  Text('Price: ${favorite['car']['seatPrice']} Dt/Seat',),
                  Text('Seat Available: ${favorite['car']['seatAvailable']} ',),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  removeFavorite(favorite['_id']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
