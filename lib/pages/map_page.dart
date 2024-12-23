import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static LatLng _pApplePark = LatLng(37.3226, -122.0098);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pGooglePlex,
          zoom: 13,

        ),
      markers:{
          Marker(markerId: MarkerId('_currentLocation'), icon: BitmapDescriptor.defaultMarker, position: _pGooglePlex ),
          Marker(markerId: MarkerId('_secondLocation'), icon: BitmapDescriptor.defaultMarker, position: _pApplePark )
      }
      )

    );
  }
}
