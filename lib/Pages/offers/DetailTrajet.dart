import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/Services/CommentService.dart';
import 'package:frontendcovoituragemobile/Services/FavoriteService.dart';
import 'package:frontendcovoituragemobile/Services/UserService.dart';
import 'package:frontendcovoituragemobile/pages/Favoris/Favorite.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  late int initialSeatsAvailable = (widget.offer['seatAvailable'] as int);
  late int? remainingSeats;
  bool isFavorite = false;
  late String? offerUserId;
  String? offerUsername;
  String? offerAge;
  String? offeremail;
  String? offerphone;
  String? offeradress;
  String? _image;
  late String reservationStatus = 'Pending';
  bool _showForm = true;
  late String paymentMethod = "Cash";
  late int numberOfPassengers = 1;
  void updateRemainingSeats() {
    setState(() {
      remainingSeats = initialSeatsAvailable - numberOfPassengers;
    });
  }



  void _calculateTotalPrice() {
    totalPrice = numberOfPassengers * (widget.offer['seatPrice'] as int);
  }

  final TextEditingController ContactController = TextEditingController();
  bool _showDetails = false;
  final _formKey = GlobalKey<FormState>();
  late int totalPrice = (widget.offer['seatPrice'] as int);
  late TextEditingController contactController;

  @override
  void initState() {
    super.initState();
    fetchComments();
    getUserId().then((userId) {
      loggedInUserId = userId;
      initialSeatsAvailable = (widget.offer['seatAvailable'] as int);
      updateRemainingSeats();
      contactController = TextEditingController();
      fetchOfferUserDetails(widget.offer['user']);
    });
  }

  @override
  void dispose() {
    contactController.dispose();
    super.dispose();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> _sendComment() async {
    final commentContent = _commentController.text;
    final userId = loggedInUserId;
    final carId = widget.offer['_id'];

    if (userId != null) {
      try {
        await CommentService.addComment(userId, carId, commentContent);
        fetchComments();
        _commentController.clear();
      } catch (e) {
        print('Erreur lors de l\'ajout du commentaire: $e');
        if (e is Exception) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout du commentaire: $e'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur inattendue s\'est produite'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      print('Aucun utilisateur connecté');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vous devez être connecté pour ajouter un commentaire'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }




  Future<List> fetchComments() async {
    final response = await CommentService.fetchComments(widget.offer['_id']);
    setState(() {
      comments = response;
    });
    return response;
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await CommentService.deleteComment(commentId);
      setState(() {
        comments.removeWhere((comment) => comment['_id'] == commentId);
      });
    } catch (e) {
      print('Failed to delete comment: $e');
    }
  }


  Future<void> addFavorite(String? userId, String carId) async {
    if (userId != null) {
      try {
        await FavoriteService().addFavorite(userId, carId);
        setState(() {
          isFavorite = true;
        });
        print('Car added to favorites successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FavoriteListPage(userId: userId)),
        );
      } catch (e) {
        print('Failed to add car to favorites: $e');
      }
    } else {
      print('User ID not found');
    }
  }

  Future<void> fetchOfferUserDetails(String userId) async {
    try {
      final userDetails = await UserService.fetchUserDetails(userId);
      setState(() {
        offerUserId = userId;
        offerUsername = userDetails['username'];
        offeremail = userDetails['email'];
        offerAge = userDetails['age'];
        offerphone = userDetails['phone'];
        offeradress = userDetails['address'];
        _image = userDetails['image'];
      });
    } catch (e) {
      print('Failed to fetch offer user details: $e');
    }
  }

  Future<void> _addReservation() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    var url = Uri.parse('http://192.168.1.14:5000/api/reservations/');
    Map<String, dynamic> data = {
      'userId': offerUserId,
      'passengerid': userId,
      'carId': widget.offer['_id'],
      'numberOfPassengers': numberOfPassengers.toString(),
      'totalPrice': totalPrice.toString(),
      'paymentMethod': paymentMethod,
      'contactInfo': contactController.text,
    };

    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          initialSeatsAvailable -= numberOfPassengers;
          remainingSeats = initialSeatsAvailable;
        });
      }
     else {
        final errorResponse = json.decode(response.body);
      }
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009C77),
      appBar: AppBar(
        title: const Text(
          'Offer Details',
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15.0)),
                        image: DecorationImage(
                          image: NetworkImage(
                            'http://192.168.1.14:5000/uploads/$_image',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person,
                                color: Colors.orangeAccent),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Offered by:',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDetails = !_showDetails;
                                });
                              },
                              child: Text(
                                '${offerUsername ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.yellow),
                                      SizedBox(width: 5.0),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_showDetails)
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Driver Details',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Text(
                                      'Phone: ${offerphone ?? ''}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      'Age: ${offerAge ?? ''}',
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Address: ${offeradress ?? ''}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'E-mail: ${offeremail ?? ''}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.my_location,
                                    color: Colors.orangeAccent),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.offer['departureLocation']} ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on_sharp,
                                    color: Colors.orangeAccent),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.offer['destinationLocation']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.date_range,
                                          color: Colors.orangeAccent),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Start Date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('EEEE, d MMMM y').format(
                                        DateTime.parse(
                                            widget.offer['departureDateTime'])),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.access_time_outlined,
                                          color: Colors.orangeAccent),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Start Time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${DateFormat('HH:mm').format(DateTime.parse(widget.offer['departureDateTime']))} PM',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.event_seat,
                                          color: Colors.orangeAccent),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Seats Available',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    ' $remainingSeats',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.price_change_outlined,
                                          color: Colors.orangeAccent),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Seats Price',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    ' ${widget.offer['seatPrice']}  /Seat',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.width * 0.05,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                addFavorite(loggedInUserId, widget.offer['_id']);
              },
              backgroundColor: Colors.white,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Color(0xFF009C77),
              ),
            ),
          ),

          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.05,
            child: FloatingActionButton(
              onPressed: () {
                _showCommentsBottomSheet(context);
              },
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Icon(Icons.comment, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.width * 0.05,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: FloatingActionButton(
                onPressed: remainingSeats == 0 ? null : () {
                  _showAddReservationDialog(context);
                },
                backgroundColor: const Color(0xFF009C77),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Make Request',
                  style: TextStyle(
                    color: remainingSeats == 0 ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009C77),
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<dynamic>(
                      future: fetchComments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          final comments = snapshot.data!;
                          return ListView.separated(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              final String userId = comment['user']['_id'];
                              final bool isCurrentUserComment = userId == loggedInUserId;

                              return ListTile(
                                title: Text(
                                  comment['user']['username'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(comment['content'] ?? ''),
                                trailing: isCurrentUserComment
                                    ? IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 15,
                                  ),
                                  onPressed: () {
                                    _deleteComment(comment['_id']);
                                  },
                                )
                                    : null,
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(),
                          );
                        }
                      },
                    ),


                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset:  Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration:  InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 16.0),
                                hintText: 'Enter your comment here',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                          IconButton(
                            icon:  Icon(Icons.send,
                                color: Colors.orangeAccent),
                            onPressed: () async {
                             await _sendComment();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: const Text(
                'Make Request',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: _showForm
                    ? Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Info',
                                border: OutlineInputBorder(),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.orangeAccent,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF009C77)),
                                ),
                                floatingLabelStyle:
                                    const TextStyle(color: Color(0xFF009C77)),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter contact info';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (numberOfPassengers > 1) {
                                        numberOfPassengers--;
                                        _calculateTotalPrice();
                                      }
                                    });
                                  },
                                  child: const Icon(Icons.remove,
                                      color: Color(0xFF009C77)),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '$numberOfPassengers',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (numberOfPassengers < 4) {
                                        numberOfPassengers++;
                                        _calculateTotalPrice();
                                      }
                                    });
                                  },
                                  child: const Icon(Icons.add,
                                      color: Color(0xFF009C77)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text(
                                  'Total Price:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$totalPrice',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: paymentMethod,
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF009C77)),
                                ),
                                floatingLabelStyle:
                                    TextStyle(color: Color(0xFF009C77)),
                                labelText: 'Payment Method',
                                border: OutlineInputBorder(),
                              ),
                              items: ['Credit Card', 'D17', 'Cash']
                                  .map((String value) {
                                Widget leadingIcon = Container();
                                if (value == 'Credit Card') {
                                  leadingIcon = Image.asset(
                                      'assets/images/creditCart.png',
                                      width: 30,
                                      height: 30);
                                } else if (value == 'D17') {
                                  leadingIcon = Image.asset(
                                      'assets/images/d17.png',
                                      width: 30,
                                      height: 30);
                                } else if (value == 'Cash') {
                                  leadingIcon = Image.asset(
                                      'assets/images/cach.png',
                                      width: 30,
                                      height: 30);
                                }
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      leadingIcon,
                                      const SizedBox(width: 8),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  paymentMethod = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select payment method';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/animations/cong.json', width: 150),
                      SizedBox(height: 16),
                      Text(
                        'Congratulations',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF009C77),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Status:',textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$reservationStatus',textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),

                    ],
                  ),
                )
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orangeAccent),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _addReservation();
                      setState(() {
                        _showForm = false;
                      });
                    }
                  },
                  child: const Text(
                    'Make Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: OfferDetailPage(
      offer: {
        'departureLocation': 'Location A',
        'destinationLocation': 'Location B',
        'departureDateTime': '2024-05-09',
        'seatAvailable': 3,
        'seatPrice': 5,
      },
    ),
  ));
}
