import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontendcovoituragemobile/pages/SideBar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddTrajet extends StatefulWidget {
  const AddTrajet({Key? key}) : super(key: key);

  @override
  _AddTrajetState createState() => _AddTrajetState();
}

class _AddTrajetState extends State<AddTrajet> {
  late GoogleMapController mapController;
  int selectedSeats = 1;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureLocationController =
      TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
  final TextEditingController _departureDateTimeController =
      TextEditingController();
  final TextEditingController _destinationDateTimeController =
      TextEditingController();
  final TextEditingController _seatPriceController = TextEditingController();

  List<Marker> _markers = [];

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF009C77),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: Icon(Icons.menu),
        ),
        title: const Text(
          "Add Offer",
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const CircleAvatar(
              backgroundImage: AssetImage('assets/images/car.png'),
            ),
          ),
        ],
      ),
      drawer: SideBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: _formadd(context),
        ),
      ),
    );
  }

  Widget _formadd(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 5),
          const Text(
            "From *",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          DepartureLocationfield(),
          const SizedBox(height: 10),
          departureDateTimeField(context),
          const SizedBox(height: 10),
          const Text(
            "To *",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Destinationfield(),
          const SizedBox(height: 10),
          destinationDateTimeField(context),
          const SizedBox(height: 10),
          const Text(
            "Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
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
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 400,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 11.5,
              ),
              onMapCreated: (controller) {
                mapController = controller;
              },
              onTap: _onMapTap,
              markers: _markers.toSet(),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
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

  Widget destinationDateTimeField(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: _destinationDateTimeController,
        readOnly: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Destination Date & Time',
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF009C77)),
          ),
          floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
          prefixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () =>
                _selectDateTime(context, _destinationDateTimeController),
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "Destination date & time can't be empty!";
          }
          return null;
        },
      ),
    );
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

    final apiUrl = 'http://localhost:5000/api/car/';

    Map<String, dynamic> carData = {
      'userId': userId,
      'departureLocation': _departureLocationController.text,
      'destinationLocation': _destinationLocationController.text,
      'departureDateTime': _departureDateTimeController.text,
      'destinationDateTime': _destinationDateTimeController.text,
      'seatPrice': _seatPriceController.text,
      'seatAvailable': selectedSeats.toString(),
    };
    print('Creating car with data: $carData');
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
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  LatLng _getLocationFromAddress(String address) {
    return LatLng(0, 0);
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
    }
  }
}
