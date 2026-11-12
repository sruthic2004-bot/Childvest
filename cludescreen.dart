import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationTrackerScreen extends StatefulWidget {
  @override
  _LocationTrackerScreenState createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  Position? _currentPosition;
  List<LatLng> _locationHistory = [];
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _loadLocationHistory();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        _locationHistory.add(newLocation);
        _saveLocationHistory();
        _mapController.move(newLocation, 15.0);
      });
    });
  }

  Future<void> _saveLocationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = _locationHistory.map((loc) => "${loc.latitude},${loc.longitude}").toList();
    await prefs.setStringList('location_history', history);
  }

  Future<void> _loadLocationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('location_history');
    if (history != null) {
      setState(() {
        _locationHistory = history.map((loc) {
          var parts = loc.split(',');
          return LatLng(double.parse(parts[0]), double.parse(parts[1]));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Tracker')),
      body: FlutterMap(
        mapController: _mapController,
       options: MapOptions(
  onTap: (tapPosition, point) {
    setState(() {
      _currentPosition = Position(
        latitude: point.latitude,
        longitude: point.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0, altitudeAccuracy:6, headingAccuracy: 56,
      );
    });
  },
  initialZoom: 15.0,
),

        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _locationHistory.map((loc) => Marker(
              width: 40.0,
              height: 40.0,
              point: loc,
              child:Icon(Icons.location_on, color: Colors.red, size: 30),
            )).toList(),
          )
        ],
      ),
    );
  }
}
