import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontendcovoituragemobile/pages/SideBar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddTrajet extends StatefulWidget {
  const AddTrajet({super.key});

  @override
  _AddTrajetState createState() => _AddTrajetState();
}

class _AddTrajetState extends State<AddTrajet> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _departureLocationController = TextEditingController();
  final TextEditingController _destinationLocationController = TextEditingController();
  final TextEditingController _departureDateTimeController = TextEditingController();
  final TextEditingController _destinationDateTimeController = TextEditingController();
  final TextEditingController _seatPriceController = TextEditingController();
  final TextEditingController _seatAvailableController = TextEditingController();
  File? _image;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF009C77),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open the sidebar
          },
          icon: Icon(Icons.menu),
        ),

        title: const Text(
          "Add Offer",
          style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white),
          textAlign: TextAlign.center,
        ),
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
      body: Stack(
          children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: _formadd(context),
                ),
              ),
            ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SeatPricefield(),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SeatAvailblefield(),
            ),
          ],
        ),
          const SizedBox(height: 10),
          imageField(),
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
        controller: _departureLocationController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Departure Location',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _departureLocationController.clear();
                });
              },
              icon: const Icon(Icons.clear),
            ),
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
            onPressed: () => _selectDateTime(context, _departureDateTimeController),
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
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
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Departure Date & Time',
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
            icon: const Icon(Icons.calendar_today, color: Colors.black,),
            onPressed: () => _selectDateTime(context, _destinationDateTimeController),
          ),
          hintStyle: const TextStyle(color: Colors.black38),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
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
        controller: _seatAvailableController,
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: ' Seat Available',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color: Color(0xFF009C77)),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _seatAvailableController.clear();
                });
              },
              icon: const Icon(Icons.clear),
            ),
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
  Widget imageField() {
    return InkWell(
      onTap: () {
        pickImage();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        child: _image == null
            ? IconButton(
          icon: Icon(
            Icons.image,
            color: Colors.black,
          ),
          onPressed: () {
            pickImage();
          },
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.file(
            _image!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          controller.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
        });
      }
    }
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

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.15:5000/api/car/'),
    );

    request.fields['departureLocation'] = _departureLocationController.text;
    request.fields['destinationLocation'] = _destinationLocationController.text;
    request.fields['departureDateTime'] = _departureDateTimeController.text;
    request.fields['destinationDateTime'] = _destinationDateTimeController.text;
    request.fields['seatPrice'] = _seatPriceController.text;
    request.fields['seatAvailable'] = _seatAvailableController.text;
    request.fields['userId'] = userId;

    if (_image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ));
    }

    try {
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Car offer added successfully');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.bottomSlide,
          title: 'Success',
          desc: 'Car offer added successfully',
          btnOkOnPress: () {},
        )..show();
      } else {
        print('Failed to add car offer');
        final errorResponse = json.decode(response.body);
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
      print(e.toString());
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'An unexpected error occurred',
        btnOkOnPress: () {},
      )..show();
    }
  }

}
