import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LocationTrackingScreen extends StatefulWidget {
  final String childName;
  final String childId;

  const LocationTrackingScreen({
    Key? key,
    required this.childName,
    required this.childId,
  }) : super(key: key);

  @override
  _LocationTrackingScreenState createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  final MapController _mapController = MapController();
  LatLng _childLocation = LatLng(0, 0);
  bool _isLoading = true;
  bool _hasPermission = false;
  Timer? _locationUpdateTimer;
  List<LatLng> _locationHistory = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartTracking();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissionsAndStartTracking() async {
    // Request location permissions
    final status = await Permission.location.request();

    setState(() {
      _hasPermission = status.isGranted;
    });

    if (status.isGranted) {
      // Get initial location
      await _getCurrentLocation();

      // Set up periodic location updates (every 30 seconds)
      _locationUpdateTimer = Timer.periodic(
          const Duration(seconds: 30), (_) => _updateChildLocation());
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // In a real app, this would fetch the child's location from a backend
      // For demo purposes, we'll use the device's location
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _childLocation = LatLng(position.latitude, position.longitude);
        _locationHistory.add(_childLocation);
        _isLoading = false;
      });

      _mapController.move(_childLocation, 15.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar("Couldn't get location: $e");
    }
  }

  Future<void> _updateChildLocation() async {
    // In a real app, this would fetch updated location from a backend
    try {
      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _childLocation = LatLng(position.latitude, position.longitude);
        _locationHistory.add(_childLocation);
      });
    } catch (e) {
      _showErrorSnackBar("Failed to update location");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.childName}'s Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showLocationHistory,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () => _mapController.move(_childLocation, 15.0),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Location permission is required to track your child's location.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissionsAndStartTracking,
              child: const Text("Grant Permission"),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Map widget
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _childLocation,
            initialZoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            // Path of child's movement (location history)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _locationHistory,
                  color: Colors.blue.withOpacity(0.7),
                  strokeWidth: 3.0,
                ),
              ],
            ),
            // Current location marker
            MarkerLayer(
              markers: [
                Marker(
                  point: _childLocation,
                  width: 80,
                  height: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.childName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Location info panel
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Child: ${widget.childName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Current Location: ${_childLocation.latitude.toStringAsFixed(6)}, ${_childLocation.longitude.toStringAsFixed(6)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Updated: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLocationHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Location History",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _locationHistory.length,
                itemBuilder: (context, index) {
                  final location = _locationHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(
                      "Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}",
                    ),
                    subtitle: Text(
                      "Time: ${DateTime.now().subtract(Duration(minutes: (_locationHistory.length - 1 - index) * 30)).toString().substring(11, 16)}",
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _mapController.move(location, 15.0);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main screen to list all children
class ChildrenListScreen extends StatelessWidget {
  final List<Map<String, String>> children = [];

  ChildrenListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Children'),
      ),
      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(child['name']![0]),
              ),
              title: Text(child['name']!),
              subtitle: Text('Age: ${child['age']}'),
              trailing: const Icon(Icons.location_on),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationTrackingScreen(
                      childName: child['name']!,
                      childId: child['id']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
