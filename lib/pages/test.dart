import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CarsListPage extends StatefulWidget {
  const CarsListPage({Key? key}) : super(key: key);

  @override
  _CarsListPageState createState() => _CarsListPageState();
}

class _CarsListPageState extends State<CarsListPage> {
  List<dynamic> cars = []; // Assume this is filled with your cars data

  @override
  void initState() {
    super.initState();
    // Load your cars data here from your API and assign it to `cars`
  }

  // Function to delete a car
  Future<void> deleteCar(String carId) async {
    final url = 'http://yourapi.com/api/cars/$carId'; // Your API endpoint
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          cars.removeWhere((car) => car['id'] == carId); // Update your local list
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Car deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars List'),
      ),
      body: ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          final car = cars[index];
          return ListTile(
            title: Text(car['name']), // Assuming each car has a name
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteCar(car['id']), // Assuming each car has an id
            ),
          );
        },
      ),
    );
  }
}
