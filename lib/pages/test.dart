import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class CarsListPage extends StatefulWidget {
  const CarsListPage({Key? key}) : super(key: key);

  @override
  _CarsListPageState createState() => _CarsListPageState();
}

class _CarsListPageState extends State<CarsListPage> {
  late Future<List<CarRide>> futureCars;

  @override
  void initState() {
    super.initState();
    futureCars = fetchCars();
  }

  Future<List<CarRide>> fetchCars() async {
    const String apiUrl = 'http://localhost:5000/api/car/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<CarRide> cars = body
            .map((dynamic item) => CarRide.fromJson(item as Map<String, dynamic>))
            .toList();
        return cars;
      } else {
        throw Exception('Failed to load cars with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cars: $e');
    }
  }

  Future<void> deleteCar(String carId) async {
    final url = 'http://localhost:5000/api/car/$carId';
    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          futureCars = fetchCars();
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Car deleted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
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
      body: FutureBuilder<List<CarRide>>(
        future: futureCars,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                CarRide car = snapshot.data![index];
                return ListTile(
                  title: Text('${car.departureLocation} to ${car.destinationLocation}'),
                  subtitle: Text('Price: \$${car.seatPrice.toString()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteCar(car.id),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No cars found'));
          }
        },
      ),
    );
  }
}

// Ensure this matches the structure of the JSON data you're working with.
// Adjustments might be needed based on the actual data and requirements.
class CarRide {
  final String id;
  final String image;
  final DateTime departureDateTime;
  final String departureLocation;
  final String destinationLocation;
  final DateTime? destinationDateTime; // Making this optional
  final double seatPrice;
  final int seatAvailable;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarRide({
    required this.id,
    required this.image,
    required this.departureDateTime,
    required this.departureLocation,
    required this.destinationLocation,
    this.destinationDateTime, // Adjusted for optional
    required this.seatPrice,
    required this.seatAvailable,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarRide.fromJson(Map<String, dynamic> json) {
    return CarRide(
      id: json['_id'],
      image: json['image'],
      departureDateTime: DateTime.parse(json['departureDateTime']),
      departureLocation: json['departureLocation'],
      destinationLocation: json['destinationLocation'],
      destinationDateTime: json['destinationDateTime'] != null
          ? DateTime.parse(json['destinationDateTime'])
          : null, // Handle optional destinationDateTime
      seatPrice: (json['seatPrice'] as num).toDouble(),
      seatAvailable: json['seatAvailable'],
      user: json['user'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
