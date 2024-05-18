import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  final String status;

  UpdateOffrePage({
    required this.offerId,
    required this.departureDateTime,
    required this.departureLocation,
    required this.destinationLocation,
    required this.seatPrice,
    required this.seatAvailable,
    required this.model,
    required this.matricule,
    required this.status,
  });

  @override
  _UpdateOffrePageState createState() => _UpdateOffrePageState();
}

class _UpdateOffrePageState extends State<UpdateOffrePage> {
  TextEditingController _departureDateTimeController = TextEditingController();
  TextEditingController _departureLocationController = TextEditingController();
  TextEditingController _destinationLocationController =
      TextEditingController();
  TextEditingController _seatPriceController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _matriculeController = TextEditingController();
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  late int selectedSeats;
  void _initializeFormFields() {
    DateTime departureDateTime = DateTime.parse(widget.departureDateTime);
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(departureDateTime);

    _departureDateTimeController.text = formattedDateTime;
    _departureLocationController.text = widget.departureLocation;
    _destinationLocationController.text = widget.destinationLocation;
    _seatPriceController.text = widget.seatPrice;
    selectedSeats = int.parse(widget.seatAvailable);
    _modelController.text = widget.model;
    _matriculeController.text = widget.matricule;
    status = widget.status;
  }

  late String status;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(33.892166, 9.561555499999997),
              zoom: 5,
            ),
            onMapCreated: (controller) {
              mapController = controller;
            },
            onTap: _onMapTap,
            markers: _markers.toSet(),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Update Your Offer",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF009C77),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "From *",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _departureLocationController,
                            decoration: InputDecoration(
                              labelText: 'Departure Location',
                              prefixIcon: Icon(
                                Icons.my_location,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _departureLocationController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              ),
                              hintStyle: TextStyle(color: Colors.black38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "To *",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _destinationLocationController,
                            decoration: InputDecoration(
                              labelText: 'Destination Location',
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.black,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _destinationLocationController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              ),
                              hintStyle: const TextStyle(color: Colors.black38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "Details",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF009C77),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _departureDateTimeController,
                            decoration: InputDecoration(
                              labelText: 'Departure date & time',
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today,
                                    color: Colors.black),
                                onPressed: () => _selectDateTime(context),
                              ),
                              hintStyle: const TextStyle(color: Colors.black38),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _seatPriceController,
                                  decoration: InputDecoration(
                                    labelText: 'Seat Price',
                                    prefixIcon: const Icon(
                                      Icons.price_change,
                                      color: Colors.black,
                                    ),
                                    hintStyle:
                                        const TextStyle(color: Colors.black38),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: selectedSeats,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedSeats = newValue!;
                                    });
                                  },
                                  items: [1, 2, 3, 4].map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    );
                                  }).toList(),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Seat Available',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xFF009C77)),
                                    ),
                                    floatingLabelStyle:
                                        TextStyle(color: Color(0xFF009C77)),
                                    prefixIcon: Icon(
                                      Icons.airline_seat_recline_extra_rounded,
                                      color: Colors.black,
                                    ),
                                    hintStyle: TextStyle(color: Colors.black38),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return "  Seat available can\'t be empty!";
                                    }
                                    return null;
                                  },
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: status,
                            onChanged: (String? newValue) {
                              setState(() {
                                status = newValue!;
                              });
                            },
                            items: [
                              'Disponible',
                              'En cours',
                              'Indisponible'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Status',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Color(0xFF009C77)),
                              ),
                              floatingLabelStyle:
                              TextStyle(color: Color(0xFF009C77)),
                              prefixIcon: Icon(
                                Icons.sticky_note_2_rounded,
                                color: Colors.black,
                              ),
                              hintStyle: TextStyle(color: Colors.black38),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "Status can't be empty!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: _updateOffer,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color(0xFF009C77),
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Update",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateOffer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.put(
          Uri.parse('http://192.168.1.14:5000/api/car/${widget.offerId}'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'user': userId,
            'departureDateTime': _departureDateTimeController.text,
            'departureLocation': _departureLocationController.text,
            'destinationLocation': _destinationLocationController.text,
            'seatPrice': _seatPriceController.text,
            'seatAvailable': selectedSeats.toString(),
            'status': status,
            'model': _modelController.text,
            'matricule': _matriculeController.text,
          }),
        );

        if (response.statusCode == 200) {
          _updateMarkers(); // Mettre à jour les marqueurs après la mise à jour de l'offre
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

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      if (_departureLocationController.text.isNotEmpty) {
        _markers.add(
          Marker(
            markerId: MarkerId('departure'),
            position:
                _getLocationFromAddress(_departureLocationController.text),
            infoWindow: InfoWindow(title: 'Departure'),
          ),
        );
      }
      if (_destinationLocationController.text.isNotEmpty) {
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position:
                _getLocationFromAddress(_destinationLocationController.text),
            infoWindow: InfoWindow(title: 'Destination'),
          ),
        );
      }
    });
  }

  void _onMapTap(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark placemark = placemarks.first;
    String address =
        '${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.country}';

    if (_departureLocationController.text.isEmpty) {
      setState(() {
        _departureLocationController.text = address;
      });

      _addMarker(
          'departure', latLng, 'Departure'); // Ajouter un marqueur de départ
    } else if (_destinationLocationController.text.isEmpty) {
      setState(() {
        _destinationLocationController.text = address;
      });

      _addMarker('destination', latLng,
          'Destination'); // Ajouter un marqueur de destination
    } else {
      print('Both departure and destination are already set.');
    }
  }

  void _addMarker(String markerId, LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

  LatLng _getLocationFromAddress(String address) {
    return LatLng(33.892166, 9.561555499999997);
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Success',
      desc: 'Offer updated successfully!',
      btnOkOnPress: () {
        Navigator.pop(context);
      },
      btnOkColor: Colors.green,
    ).show();
  }

  void _showErrorDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: 'Failed to update offer. Please try again later.',
      btnOkOnPress: () {},
      btnOkColor: Colors.red,
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
