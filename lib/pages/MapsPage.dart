
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({Key? key}) : super(key: key);

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  var myMarkers = HashSet<Marker>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
    ),
    onMapCreated: (GoogleMapController controller) {
    setState(() {
    myMarkers.add(
    Marker(
    markerId: MarkerId('1'),
    position: LatLng(37.42796133580664, -122.085749655962),
    infoWindow: InfoWindow(
    title: 'covoiturage',
    ),
    onTap: () {
    // Handle marker tap
    },
    ),
    );
    });
    },
    markers: myMarkers,
    ),
    );
  }
}
