import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liveuserlocation/consts.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  PolylinePoints polylinePoints = PolylinePoints();
  final Completer<GoogleMapController> _mapController =
  Completer<GoogleMapController>();
  static LatLng _pGooglePlex = LatLng(31.345394, 73.429810);
  static LatLng _pApplePark = LatLng(31.345396, 73.429812);
  Location _locationController = new Location();
  LatLng? _currentP = _pGooglePlex;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) {
      getPolyLinePoints().then((coordinates) {
        if (coordinates.isNotEmpty) {
          generatePolyLinePoints(coordinates);
          debugPrint(coordinates.toString());
        } else {
          debugPrint("No polyline points received.");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _currentP == null
            ? Center(
          child: Text('Loading...'),
        )
            : GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: _pGooglePlex,
              zoom: 13,
            ),
            markers: {
              Marker(
                  markerId: MarkerId('_currentLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentP!),
              Marker(
                  markerId: MarkerId('_sourceLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pGooglePlex),
              Marker(
                  markerId: MarkerId('_destinationLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _pApplePark)
            }));
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    try {
      final GoogleMapController controller = await _mapController.future;
      CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_newCameraPosition),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> getLocationUpdates() async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await _locationController.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await _locationController.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await _locationController.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await _locationController.requestPermission();
      }

      if (_permissionGranted == PermissionStatus.granted ||
          _permissionGranted == PermissionStatus.grantedLimited) {
        _locationController.onLocationChanged.listen((LocationData currentLocation) {
          if (currentLocation.latitude != null && currentLocation.longitude != null) {
            setState(() {
              _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
              _cameraToPosition(_currentP!);
            });
          }
        });
      } else {
        debugPrint("Location permission denied.");
      }
    } catch (e) {
      debugPrint("Error in getLocationUpdates: $e");
    }
  }

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polyLineCoordinates = [];

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: GOOGLE_MAPS_API_KEY,
        request: PolylineRequest(
          origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
          destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
          mode: TravelMode.driving,
          //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
        ),
      );

      if (result.errorMessage?.isNotEmpty ?? false) {
        debugPrint("Error in API request: ${result.errorMessage}");
        return polyLineCoordinates; // Return empty list if there's an error
      }

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        debugPrint("No points returned from API.");
      }

      debugPrint("Polyline coordinates: $polyLineCoordinates");
      return polyLineCoordinates; // Return the coordinates

    } catch (e) {
      debugPrint("Error in getPolyLinePoints: $e");
      return polyLineCoordinates; // Return empty list on error
    }
  }

  void generatePolyLinePoints(List<LatLng> polyLineCoordinates) async {
    PolylineId id = PolylineId('poly');
    Polyline line = Polyline(
      polylineId: id,
      width: 8,
      points: polyLineCoordinates,
      color: Colors.black,
    );

    setState(() {
      polylines[id] = line;
    });
  }
}
