import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static LatLng _pGooglePlex = LatLng(37.4223, -122.0848);
  static LatLng _pApplePark = LatLng(37.3226, -122.0098);
  Location _locationController = new Location();
  LatLng? _currentP = LatLng(37.4223, -122.0848);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _currentP == null
            ? Center(
                child: Text('Loading...'),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _pGooglePlex,
                  zoom: 13,
                ),
                markers: {
                    Marker(
                        markerId: MarkerId('_currentLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _pGooglePlex),
                    Marker(
                        markerId: MarkerId('_secondLocation'),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _pApplePark)
                  }));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    }else{
      return;
    }
    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
    }
    if (_permissionGranted == PermissionStatus.granted) {
      return;
    }
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }
}
