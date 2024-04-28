import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:awesome_dialog/awesome_dialog.dart';


class AddTrajet extends StatefulWidget {
  const AddTrajet({Key? key}) : super(key: key);

  @override
  _AddTrajetState createState() => _AddTrajetState();
}

class _AddTrajetState extends State<AddTrajet> {
  late GoogleMapController mapController;
  int selectedSeats = 1;
  String status = "Disponible";

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureLocationController =
  TextEditingController();
  final TextEditingController _destinationLocationController =
  TextEditingController();
  final TextEditingController _departureDateTimeController =
  TextEditingController();

  final TextEditingController _seatPriceController = TextEditingController();

  List<Marker> _markers = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(33.892166,  9.561555499999997),
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
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                      Center(
                        child: Text(
                          "Add New Offer",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF009C77),
                          ),
                        ),),
                          const SizedBox(height: 10),
                          Text(
                            "From *",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF009C77),
                            ),
                          ),
                          DepartureLocationfield(),
                          const SizedBox(height: 10),

                          Text(
                            "To *",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF009C77),
                            ),
                          ),
                          Destinationfield(),

                          Center(
                            child:Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF009C77),
                            ),

                          ),
                          ),
                          const SizedBox(height: 10),
                          departureDateTimeField(context),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              Expanded(
                                child: SeatPricefield(),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: SeatAvailablefield(),
                              ),

                            ],
                          ),
                          const SizedBox(height: 10),
                          widgetStatus(),
                          const SizedBox(height: 20),
                          Center (
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
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
                                "Add",
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

  Widget DepartureLocationfield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: _departureLocationController,
        onChanged: (value) {
          if (value.isNotEmpty) {
            _addDepartureMarker(value);
          }
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Departure Location',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: TextStyle(color: Color(0xFF009C77)),
          suffixIcon: IconButton(
            onPressed: () {
              _departureLocationController.clear();
            },
            icon: Icon(Icons.clear),
          ),
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: Colors.black,
          ),
          hintStyle: TextStyle(color: Colors.black38),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Departure location  can\'t be empty!";
          }
          return null;
        },
      ),
    );
  }

  void _addDepartureMarker(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);


      _markers.removeWhere((marker) => marker.markerId.value == 'departure');

      setState(() {
        _departureLocationController.text = address;
        _markers.add(
          Marker(
            markerId: MarkerId('departure'),
            position: latLng,
            infoWindow: InfoWindow(title: 'Departure'),
          ),
        );
      });
    }
  }

  Widget departureDateTimeField(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: _departureDateTimeController,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Departure Date & Time',
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
          prefixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () =>
                _selectDateTime(context, _departureDateTimeController),
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "Departure date & time can't be empty!";
          }
          return null;
        },
      ),
    );
  }

  Widget Destinationfield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: _destinationLocationController,
        onChanged: (value) {
          // Call a method to add marker when text changes
          if (value.isNotEmpty) {
            _addDestinationMarker(value);
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Destination Location',
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _destinationLocationController.clear();
              });
            },
            icon: const Icon(Icons.clear),
          ),
          prefixIcon: const Icon(
            Icons.location_on_outlined,
            color: Colors.black,
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Destination location  can\'t be empty!";
          }
          return null;
        },
      ),
    );
  }

  void _addDestinationMarker(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);

      _markers.removeWhere((marker) => marker.markerId.value == 'destination');

      setState(() {
        _destinationLocationController.text = address;
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: latLng,
            infoWindow: InfoWindow(title: 'Destination'),
          ),
        );
      });
    }
  }



  Widget SeatPricefield() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextFormField(
        controller: _seatPriceController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Seat Price',
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _seatPriceController.clear();
              });
            },
            icon: const Icon(Icons.clear),
          ),
          prefixIcon: const Icon(
            Icons.price_change,
            color: Colors.black,
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Seat Price can\'t be empty!";
          }
          return null;
        },
      ),
    );
  }

  Widget SeatAvailablefield() {
    return Container(
      alignment: Alignment.centerLeft,
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
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: TextStyle(color: Color(0xFF009C77)),
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
    );
  }
  Widget widgetStatus() {
    return Container(
      alignment: Alignment.centerLeft,
      child: DropdownButtonFormField<String>(
        value: status,
        onChanged: (String? newValue) {
          setState(() {
            status = newValue!;
          });
        },
        items: ['Disponible ', 'En cours', 'Indisponible'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Status',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: TextStyle(color: Color(0xFF009C77)),
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
    );
  }


  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (pickedDate == null) {
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) {
      return;
    }

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      controller.text = finalDateTime.toUtc().toIso8601String();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found');
      return;
    }

    final apiUrl = 'http://192.168.1.15:5000/api/car/';

    Map<String, dynamic> carData = {
      'userId': userId,
      'departureLocation': _departureLocationController.text,
      'destinationLocation': _destinationLocationController.text,
      'departureDateTime': _departureDateTimeController.text,
      'seatPrice': _seatPriceController.text,
      'seatAvailable': selectedSeats.toString(),
      'status': status,
    };
    print('Creating car with data: $carData');
    _showSuccessDialog();
    Marker departureMarker = Marker(
      markerId: MarkerId('departure'),
      position: _getLocationFromAddress(_departureLocationController.text),
      infoWindow: InfoWindow(title: 'Departure'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: _getLocationFromAddress(_destinationLocationController.text),
      infoWindow: InfoWindow(title: 'Destination'),
    );

    setState(() {
      _markers.clear();
      _markers.add(departureMarker);
      _markers.add(destinationMarker);
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(carData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
      } else {
        final errorResponse = json.decode(response.body);
        print('Error creating car: ${errorResponse['message']}');
        _showErrorDialog();
      }
    } catch (e) {
      _showErrorDialog();
      print('An unexpected error occurred: $e');

    }
  }

  LatLng _getLocationFromAddress(String address) {
    return LatLng(33.892166,  9.561555499999997);
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

      _markers.add(
        Marker(
          markerId: MarkerId('departure'),
          position: latLng,
          infoWindow: InfoWindow(title: 'Departure'),
        ),
      );
    } else if (_destinationLocationController.text.isEmpty) {
      setState(() {
        _destinationLocationController.text = address;
      });

      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: latLng,
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
    } else {

      print('Both departure and destination are already set.');
    }
  }

  void _showSuccessDialog() {
    AwesomeDialog(
      context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
      title: 'Success',
      desc: 'Offer added successfully!',
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
}