import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasPermission = false;
  int _totalUsageMinutes = 0;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    setState(() => _isLoading = true);

    // Check current permission status
    var status = await Permission.activityRecognition.status;

    // If permission is not granted, request it
    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
    }

    // Update permission state
    setState(() {
      _hasPermission = status.isGranted;
    });

    // Only fetch usage if permission is granted
    if (_hasPermission) {
      await _getAppUsageInfo();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAppUsageInfo() async {
    try {
      // Get app usage info
      final appUsage = AppUsage();
      var appUsageList = await appUsage.getAppUsage(_startDate, _endDate);

      // Calculate total usage time only
      int totalMinutes = 0;
      for (var info in appUsageList) {
        totalMinutes += info.usage.inMinutes;
      }

      setState(() {
        _totalUsageMinutes = totalMinutes;
        _isLoading = false;
      });

      // Save today's usage
      _saveUsageData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching app usage: $e')));
    }
  }

  Future<void> _saveUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setInt('screen_time_$today', _totalUsageMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen Time'),
        actions: [
          if (_hasPermission)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _getAppUsageInfo,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasPermission
              ? _buildScreenTimeView()
              : _buildPermissionDeniedView(),
    );
  }

  Widget _buildScreenTimeView() {
    final hours = _totalUsageMinutes ~/ 60;
    final minutes = _totalUsageMinutes % 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Screen Time Today',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '$hours h $minutes min',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: _totalUsageMinutes / (60 * 12), // 12 hours max
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _totalUsageMinutes > 60 * 4 ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _totalUsageMinutes > 60 * 4
                      ? 'High usage today'
                      : 'Moderate usage today',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _totalUsageMinutes > 60 * 4 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_encryption_gmailerrorred,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app needs usage statistics permission to show your screen time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkAndRequestPermission,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Open app settings
                openAppSettings();
              },
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
