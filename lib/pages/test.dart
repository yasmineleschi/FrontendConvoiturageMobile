import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCarForm extends StatefulWidget {
  @override
  _AddCarFormState createState() => _AddCarFormState();
}

class _AddCarFormState extends State<AddCarForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController destinationLocationController = TextEditingController();
  TextEditingController departureLocationController = TextEditingController();
  TextEditingController seatPriceController = TextEditingController();
  int selectedSeats = 1; // Default selected seats

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Serialize form data
      var formData = {
        "destinationLocation": destinationLocationController.text,
        "departureLocation": departureLocationController.text,
        "seatPrice": seatPriceController.text,
        "seatAvailable": selectedSeats.toString(), // Convert to string
      };

      // Send POST request
      var response = await http.post(
        'http://192.168.1.15:5000/api/car/' as Uri,
        body: formData,
      );

      // Handle response
      if (response.statusCode == 200) {
        // Car added successfully
        print('Car added successfully');
        // Optionally, navigate to another screen or show a success message
      } else {
        // Error adding car
        print('Error adding car: ${response.body}');
        // Optionally, display an error message
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: destinationLocationController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter destination location';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Destination Location',
                ),
              ),
              TextFormField(
                controller: departureLocationController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter departure location';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Departure Location',
                ),
              ),
              TextFormField(
                controller: seatPriceController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter seat price';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Seat Price',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Dropdown for selecting available seats
              DropdownButtonFormField<int>(
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
                decoration: InputDecoration(
                  labelText: 'Available Seats',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
