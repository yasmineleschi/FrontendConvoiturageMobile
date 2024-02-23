import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
class AddTrajet extends StatefulWidget {
  const AddTrajet({super.key});

  @override
  _AddTrajetState createState() => _AddTrajetState();
}

class _AddTrajetState extends State<AddTrajet> {
  String? destinationLocation;
  DateTime? destinationDateTime;
  DateTime? departureDateTime;
  String? departureLocation;
  int? seatPrice;
  int? seatAvailable;
  String? image;

  GlobalKey<FormState> formadd = GlobalKey<FormState>();

  TextEditingController DepartureLocation = TextEditingController();
  TextEditingController DeparturedateTime = TextEditingController();
  TextEditingController destination = TextEditingController();
  TextEditingController DestinationdateTime = TextEditingController();
  TextEditingController SeatPrice = TextEditingController();
  TextEditingController SeatAvailable = TextEditingController();
  TextEditingController Image = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF009C77),
        title: const Text(
          "Add Offer" ,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 25,
            fontWeight: FontWeight.bold,
             color: Colors.white),
          textAlign: TextAlign.center,),
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

      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF009C77),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Drawer Header',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              buildMenuItems(context),
            ],
          ),
        ),
      ),

      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SingleChildScrollView(
                child: Form(
                  key: formadd,
                  child: _formadd(context),

                ),
              ),
            ],
          ),
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
          DepartureDateTimeLield(),
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
          DestinationDateTimeLfield(),
          const SizedBox(height: 10),
          SeatPricefield(),
          const SizedBox(height: 10),
          SeatAvailblefield(),
          const SizedBox(height: 10),
          imagefield(),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 50,
            width: 150,
            child: ElevatedButton(
              onPressed: () async {
                if (validateandsave()) {
                  await add(destinationLocation!, destinationDateTime!, departureDateTime!,departureLocation!,seatPrice!,seatAvailable!, image!, context);
                }
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),

                  ),
                ),
              ),
              child: const Text(
                "Post Offer",
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
        controller: DepartureLocation,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Departure Location',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  DepartureLocation.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Depature location  can\'t be empty!";
          }
          return null;
        },

      ),
    );
  }
  Widget DepartureDateTimeLield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: DeparturedateTime,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Departure Date & Time',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),


            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Depature location  can\'t be empty!";
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
        controller: destination,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Departure Date & Time',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  destination.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Depature location  can\'t be empty!";
          }
          return null;
        },

      ),
    );
  }
  Widget DestinationDateTimeLfield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: DestinationdateTime,
        decoration:  const InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Destination Date & Time',
            focusedBorder: const OutlineInputBorder(
              borderSide:  BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),


            prefixIcon: const Icon(
              Icons.date_range,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.datetime,
        validator: (value) {
          if (value!.isEmpty) {
            return "  destionation  date & time can\'t be empty!";
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
        controller: SeatPrice,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Seat Price',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  SeatPrice.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.price_change,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
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
  Widget SeatAvailblefield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: SeatAvailable,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: ' Seat Available',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  SeatAvailable.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.airline_seat_recline_extra_rounded,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return "  seat available can\'t be empty!";
          }
          return null;
        },

      ),
    );
  }
  Widget imagefield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: Image,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'add image',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  Image.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.image,
              color: Colors.black,
            ),

            hintStyle: const TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  destionation  date & time can\'t be empty!";
          }
          return null;
        },

      ),
    );
  }
  bool validateandsave() {
    final form = formadd.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Add Offer'),
          onTap: () {
            Navigator.pushNamed(context, '/addOffer'); // Close the drawer
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {

          },
        ),

      ],
    );
  }
}





Future<void> add(
    String destinationLocation,
    DateTime destinationDateTime ,
    DateTime departureDateTime, String departureLocation,
    int seatPrice ,
    int seatAvailable,
    String image,
    BuildContext context) async {
  const url = 'http://localhost:5000/api/cars/';

  Map<String, dynamic> body = {
  "destinationLocation" : destinationLocation,
  "destinationDateTime" :destinationDateTime,
  "departureDateTime" :departureDateTime,
  "departureLocation" : departureLocation,
  "seatPrice" : seatPrice ,
  "seatAvailable" : seatAvailable ,
  "image" : image

  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {

      final jsonResponse = jsonDecode(response.body);
      print("offer added: $jsonResponse");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'add offer Successful',
        desc: 'Welcome, ! Your traject has been successfully created.',
        btnOkOnPress: () {},
      )..show();
    } else {
      // Error
      final errorResponse = jsonDecode(response.body);
      print("Error: $errorResponse");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'Error: ${errorResponse['message']}',
        btnOkOnPress: () {},
      )..show();
    }
  } catch (e) {
    print("Error: $e");
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: 'An error occurred during added.',
      btnOkOnPress: () {},
    )..show();
  }

}