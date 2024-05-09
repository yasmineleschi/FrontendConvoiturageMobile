import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/Favorite.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

  late int initialSeatsAvailable;

  int? remainingSeats;
  void updateRemainingSeats() {
    setState(() {
      remainingSeats = initialSeatsAvailable - numberOfPassengers;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchComments();

    getUserId().then((userId) {
      loggedInUserId = userId;

      initialSeatsAvailable = widget.offer['seatAvailable'];

      remainingSeats = initialSeatsAvailable - numberOfPassengers;
      contactController = TextEditingController();
      fetchOfferUserDetails(widget.offer['user']);
    });
  }

  Future<void> fetchComments() async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.15:5000/api/car/api/comments/${widget.offer['_id']}'));

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
    final userId = loggedInUserId;

    if (userId != null) {
      final carId = widget.offer['_id'];
      final url =
          Uri.parse('http://192.168.1.15:5000/api/car/api/comments/$carId');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final body =
          jsonEncode({'user': userId, 'car': carId, 'content': commentContent});

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
    final url =
        Uri.parse('http://192.168.1.15:5000/api/car/api/comments/$commentId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Reload comments after deletion
      fetchComments();
    } else {
      // Handle error
      print('Failed to delete comment: ${response.statusCode}');
    }
  }

  bool isFavorite = false;

  late String? offerUserId;
  String? offerUsername;
  String? offerfirstname;
  String? offerlastName;
  String? offerphone;
  String? offeradress;
  Future<void> addFavorite(String? userId, String carId) async {
    if (userId != null) {
      final url =
          Uri.parse('http://192.168.1.15:5000/api/favorie/$userId/$carId');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final body = jsonEncode({'user': userId, 'car': carId});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        setState(() {
          isFavorite = true;
        });
        print('Car added to favorites successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FavoriteListPage(userId: userId)),
        );
      } else {
        print('Failed to add car to favorites');
      }
    } else {
      print('User ID not found');
    }
  }

  Future<void> fetchOfferUserDetails(String userId) async {
    final url = Uri.parse('http://192.168.1.15:5000/api/users/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      setState(() {
        offerUserId = userId;
        offerUsername = userData['username'];
        offerfirstname = userData['firstname'];
        offerlastName = userData['lastname'];
        offerphone = userData['phone'];
        offeradress = userData['address'];
      });
    } else {
      // Handle error
      print('Failed to fetch offer user details: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF009C77),
      appBar: AppBar(
        title: Text(
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF009C77),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
                addFavorite(loggedInUserId, widget.offer['_id']);
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Color(0xFF009C77),
              ),
              backgroundColor: Colors.white,
            ),
          ),
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15.0)),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/car.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
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
                          Icon(Icons.person, color: Colors.orangeAccent),
                          SizedBox(width: 8.0),
                          Text(
                            'Offered by:',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showDetails = !_showDetails;
                              });
                            },
                            child: Text(
                              '${offerUsername ?? 'Unknown'}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Show user details when _showDetails is true

                          Expanded(
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
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver Details ',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'First Name: ',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  'Last Name: Doe',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Text(
                                  'Phone: 123456789',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                // Add other user details as needed
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.orangeAccent),
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
                              const Icon(Icons.location_on_sharp, color: Colors.orangeAccent),
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
                                  Icon(Icons.date_range, color: Colors.orangeAccent),
                                    SizedBox(width: 8.0),
                                  Text('Start Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],),

                                Text(
                                  DateFormat('EEEE, d MMMM y').format(DateTime.parse(
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
                                    Icon(Icons.access_time_outlined, color: Colors.orangeAccent),
                                    SizedBox(width: 8.0),
                                    Text('Start Time',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],),
                                Text(
                                  DateFormat('HH:mm').format(DateTime.parse(
                                      widget.offer['departureDateTime'])) + ' PM',
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
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.event_seat, color: Colors.orangeAccent),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Seats Available',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black, fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' $remainingSeats',
                                  style: TextStyle(
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.price_change_outlined, color: Colors.orangeAccent),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Seats Price',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' ${widget.offer['seatPrice']}  /Seat',
                                  style: TextStyle(
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
          Positioned(
            bottom: 15,
            left: 20,
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
            bottom: 15,
            right: 20,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton(
                onPressed: () {
                  _showAddReservationDialog(context);
                },
                backgroundColor: Color(0xFF009C77),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text('Make Reservation', style: TextStyle(color: Colors.white)), // Texte en blanc
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
              constraints: BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(

                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final String userId =
                          comment['user']['_id'];
                          final bool isCurrentUserComment = userId == loggedInUserId;

                          return ListTile(
                            title: Text(
                              comment['user']['username'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment['content'] ?? ''),
                            trailing: isCurrentUserComment
                                ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {

                                _deleteComment(comment['_id']);
                              },
                            )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,

                                decoration: InputDecoration(
                                  labelText: 'Add a comment',
                                  floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color:Color(0xFF009C77) ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                  hintText: 'Enter your comment here',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send , color:Colors.black ,),
                              onPressed: () {
                                _sendComment();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  bool _showDetails = false;
  final _formKey = GlobalKey<FormState>();

  late double totalPrice = (widget.offer['seatPrice'] as double);
  String paymentMethod = "Cash";
  int numberOfPassengers = 1;

  late TextEditingController contactController;

  @override
  void dispose() {
    contactController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    totalPrice = numberOfPassengers * (widget.offer['seatPrice'] as double);
  }

  Future<void> _addReservation() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    var url = Uri.parse('http://192.168.1.15:5000/api/reservations/');
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
        print('Reservation added successfully');
      } else {
        final errorResponse = json.decode(response.body);
        print('Error creating reservation: ${errorResponse['message']}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }



  final TextEditingController ContactController = TextEditingController();
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
            title:
              const Text(
                'Make Reservation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color:  Colors.black,
                ),
              ),


            content: SingleChildScrollView(

            child: Form(
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
                        color: Colors.orangeAccent ,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF009C77)),
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
                    ),

                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter contact info';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (numberOfPassengers >
                                initialSeatsAvailable) {
                              numberOfPassengers--;
                              _calculateTotalPrice();
                            }
                          });
                        },
                        child: Icon(Icons.remove ,color: Color(0xFF009C77)),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$numberOfPassengers',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (numberOfPassengers <
                                initialSeatsAvailable) {
                              numberOfPassengers++;
                              _calculateTotalPrice();
                            }
                          });
                        },
                        child: Icon(Icons.add,color: Color(0xFF009C77)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
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
                      SizedBox(width: 8),
                      Text(
                        '$totalPrice',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),


                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF009C77)),
                      ),
                      floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Credit Card', 'D17', 'Cash'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _addReservation();
                  Navigator.of(context).pop();
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
