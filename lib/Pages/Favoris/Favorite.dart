import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Navigation/navigation_bar.dart';
import 'package:frontendcovoituragemobile/pages/offers/DetailTrajet.dart';
import 'package:frontendcovoituragemobile/services/FavoriteService.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class FavoriteListPage extends StatefulWidget {
  final String? userId;

  FavoriteListPage({required this.userId});

  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final _favoriteService = FavoriteService();
  List<dynamic> _favorites = [];

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchFavorites();
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final favorites = await _favoriteService.getFavorites(widget.userId!);
      setState(() {
        _favorites = favorites;
      });
    } catch (e) {
      print('Failed to fetch favorites: $e');
    }
  }


  Future<void> _removeFavorite(String favoriteId) async {
    try {
      await _favoriteService.removeFavorite(favoriteId);
      setState(() {
        _favorites.removeWhere((favorite) => favorite['_id'] == favoriteId);
      });
    } catch (e) {
      print('Failed to remove favorite: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'disponible':
        return Colors.green;
      case 'en cours':
        return Colors.orange;
      case 'indisponible':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.08;
    final cardHeight = screenWidth * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFF009C77),
      appBar: AppBar(
        title: const Text(
          'My favorites',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF009C77),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFECECEC),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: _favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/animations/hearts.json', width: 150),
                    SizedBox(height: 16),
                    Text(
                      'No Favorites Yet',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xFF009C77)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavigationBarScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                   OfferDetailPage(offer: favorite['car']),
                            ),
                          );
                        },
                        child: Container(
                          width: cardHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [

                              Positioned(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.2,
                                left: MediaQuery.of(context).size.width * 0.04,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.my_location,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${favorite['car']['departureLocation']} ',
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.13,
                                left: MediaQuery.of(context).size.width * 0.04,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on_sharp,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${favorite['car']['destinationLocation']}',
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).size.height * 0.02,
                                right: MediaQuery.of(context).size.width * 0.03,
                                child: IconButton(
                                  icon: Icon(Icons.favorite,
                                      color: Colors.red, size: iconSize),
                                  onPressed: () {
                                    _removeFavorite(favorite['_id']);
                                  },
                                ),
                              ),
                              Positioned(
                                bottom:
                                MediaQuery.of(context).size.height * 0.08,
                                right: MediaQuery.of(context).size.width * 0.06,
                                child: Text(
                                  '${favorite['car']['seatPrice']}DT',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                        favorite['car']['status']),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.03,
                                right: MediaQuery.of(context).size.width * 0.06,
                                child: Text(
                                  '${favorite['car']['status']}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(
                                        favorite['car']['status']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
