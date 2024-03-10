import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';



class UpdateOffrePage extends StatefulWidget {
  final String offerId;
  final String departureDateTime;
  final String departureLocation;
  final String destinationLocation;
  final String seatPrice;
  final String seatAvailable;
  final String model;
  final String matricule;

  UpdateOffrePage({
    required this.offerId,
    required this.departureDateTime,
    required this.departureLocation,
    required this.destinationLocation,
    required this.seatPrice,
    required this.seatAvailable,
    required this.model,
    required this.matricule,
  });

  @override
  _UpdateOffrePageState createState() => _UpdateOffrePageState();
}

class _UpdateOffrePageState extends State<UpdateOffrePage> {
  TextEditingController _departureDateTimeController = TextEditingController();
  TextEditingController _departureLocationController = TextEditingController();
  TextEditingController _destinationLocationController = TextEditingController();
  TextEditingController _seatPriceController = TextEditingController();
  TextEditingController _seatAvailableController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _matriculeController = TextEditingController();
  File? _carImage;
  List<dynamic> _offers = [];
  List<dynamic> _filteredOffers = [];

  @override
  void initState() {
    super.initState();
    _getUserIDAndFetchOffers(); // Call _getUserIDAndFetchOffers to fetch user ID and offers
    _departureDateTimeController.text = widget.departureDateTime;
    _departureLocationController.text = widget.departureLocation;
    _destinationLocationController.text = widget.destinationLocation;
    _seatPriceController.text = widget.seatPrice;
    _seatAvailableController.text = widget.seatAvailable;
    _modelController.text = widget.model;
    _matriculeController.text = widget.matricule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Offer'),
        centerTitle: true,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _departureLocationController,
                decoration: InputDecoration(
                  labelText: 'Departure Location',
                  suffixIcon: Image.asset(
                    'assets/images/img_6.png',
                    width: 20,
                    height: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),

                ),
              ),

              SizedBox(height: 20),
              TextFormField(
                controller: _destinationLocationController,
                decoration: InputDecoration(labelText: 'Destination Location',
                  suffixIcon: Image.asset(
                    'assets/images/img_6.png',
                    width: 20,
                    height: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),

              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _seatPriceController,
                decoration: InputDecoration(labelText: 'Seat Price',
                  suffixIcon: Image.asset(
                    'assets/images/img_9.png',
                    width: 20,
                    height: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _seatAvailableController,
                decoration: InputDecoration(labelText: 'Seat Available',
                  suffixIcon: Image.asset(
                    'assets/images/img_8.png',
                    width: 20,
                    height: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),),

              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _departureDateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Departure Date and Time',
                  suffixIcon: IconButton(
                    onPressed: () => _selectDateTime(context),
                    icon: Image.asset(
                      'assets/images/img_7.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),


              SizedBox(height: 20),


              ElevatedButton(
                onPressed: _updateOffer,
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF009C77), // Background color
                ),
                child: Text('Update',
                  style: TextStyle(
                    color: Colors.white, // Text color
                  ),),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUserIDAndFetchOffers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('User ID is null');
      }
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/car/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _offers = json.decode(response.body);
          _filteredOffers = List.from(_offers);
        });
      } else {
        throw Exception('Failed to fetch offers');
      }
    } catch (e) {
      print('Error fetching offers: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/users/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }


// Inside _UpdateOffrePageState class
  Future<void> _updateOffer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      // Check if user ID is not null
      if (userId != null) {
        // Update offer with user ID
        final response = await http.put(
          Uri.parse('http://localhost:5000/api/car/${widget.offerId}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'user': userId,
            'departureDateTime': _departureDateTimeController.text,
            'departureLocation': _departureLocationController.text,
            'destinationLocation': _destinationLocationController.text,
            'seatPrice': _seatPriceController.text,
            'seatAvailable': _seatAvailableController.text,
            'model': _modelController.text,
            'matricule': _matriculeController.text,
          }),
        );

        // Handle response based on status code
        if (response.statusCode == 200) {
          // Car updated successfully
          _showSuccessDialog();
        } else {
          // Failed to update car
          _showErrorDialog();
        }
      } else {
        // Handle the case where user ID is null
        print('User ID is null');
      }
    } catch (e) {
      // Handle errors
      print('Error updating offer: $e');
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,

      title: 'Success',
      desc: 'Offer updated successfully!',
      btnOkOnPress: () {
        Navigator.pop(context); // Go back to MyOffrePage
      },
    ).show();
  }

  void _showErrorDialog() {
    AwesomeDialog(
      context: context,

      title: 'Error',
      desc: 'Failed to update offer. Please try again later.',
      btnOkOnPress: () {},
    ).show();
  }




  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _departureDateTimeController.text = combinedDateTime.toString();
        });
      }
    }
  }
}
