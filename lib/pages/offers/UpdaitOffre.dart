


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

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
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
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

            _buildMap(),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _updateOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF009C77), // Background color
              ),
              child: Text('Update',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),),

            ),

          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText, {bool readOnly = false, Function()? onTap}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap as void Function()?,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 12,
        ),
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        markers: _markers,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _onMapTap(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String address = placemark.name ?? placemark.toString();

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('selected-location'),
            position: position,
            infoWindow: InfoWindow(title: address),
          ),
        );

        if (_departureLocationController.text.isEmpty) {
          _departureLocationController.text = address;
        } else if (_destinationLocationController.text.isEmpty) {
          _destinationLocationController.text = address;
        }
      });
    }
  }

  Future<void> _updateOffer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
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

        if (response.statusCode == 200) {
          _showSuccessDialog();
        } else {
          _showErrorDialog();
        }
      } else {
        print('User ID is null');
      }
    } catch (e) {
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
        Navigator.pop(context);
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
