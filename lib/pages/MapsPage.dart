import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(45.521563, -122.677433),
    zoom: 11.5,
  );

  late GoogleMapController mapController;

  Set<Marker> markers = {};

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            mapController = controller;
            // Add markers when map is created
            _addMarkers();
          },
          initialCameraPosition: _initialCameraPosition,
          markers: markers,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.deepOrange,
        onPressed: () => mapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarkers() {
    // Add your markers here
    Marker departureMarker = Marker(
      markerId: MarkerId('departure'),
      position: LatLng(45.521563, -122.677433), // Example coordinates
      infoWindow: InfoWindow(title: 'Departure'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: LatLng(45.531563, -122.687433), // Example coordinates
      infoWindow: InfoWindow(title: 'Destination'),
    );

    setState(() {
      markers.add(departureMarker);
      markers.add(destinationMarker);
    });
  }
}
