import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingsProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  
  // Screen time limits (in minutes)
  int getScreenTimeLimit(String childId) {
    return _settingsBox.get('screenTimeLimit_$childId', defaultValue: 120);
  }
  
  Future<void> setScreenTimeLimit(String childId, int minutes) async {
    await _settingsBox.put('screenTimeLimit_$childId', minutes);
    notifyListeners();
  }
  
  // App blocking settings
  List<String> getBlockedApps(String childId) {
    return List<String>.from(_settingsBox.get('blockedApps_$childId', defaultValue: <String>[]));
  }
  
  Future<void> addBlockedApp(String childId, String packageName) async {
    final blockedApps = getBlockedApps(childId);
    if (!blockedApps.contains(packageName)) {
      blockedApps.add(packageName);
      await _settingsBox.put('blockedApps_$childId', blockedApps);
      notifyListeners();
    }
  }
  
  Future<void> removeBlockedApp(String childId, String packageName) async {
    final blockedApps = getBlockedApps(childId);
    if (blockedApps.contains(packageName)) {
      blockedApps.remove(packageName);
      await _settingsBox.put('blockedApps_$childId', blockedApps);
      notifyListeners();
    }
  }
  
  // Web filtering settings
  List<String> getBlockedWebsites(String childId) {
    return List<String>.from(_settingsBox.get('blockedWebsites_$childId', defaultValue: <String>[]));
  }
  
  Future<void> addBlockedWebsite(String childId, String website) async {
    final blockedWebsites = getBlockedWebsites(childId);
    if (!blockedWebsites.contains(website)) {
      blockedWebsites.add(website);
      await _settingsBox.put('blockedWebsites_$childId', blockedWebsites);
      notifyListeners();
    }
  }
  
  Future<void> removeBlockedWebsite(String childId, String website) async {
    final blockedWebsites = getBlockedWebsites(childId);
    if (blockedWebsites.contains(website)) {
      blockedWebsites.remove(website);
      await _settingsBox.put('blockedWebsites_$childId', blockedWebsites);
      notifyListeners();
    }
  }
  
  // Geofencing settings
  List<Map<String, dynamic>> getGeofences(String childId) {
    return List<Map<String, dynamic>>.from(_settingsBox.get(
      'geofences_$childId', 
      defaultValue: <Map<String, dynamic>>[]
    ));
  }
  
  Future<void> addGeofence(String childId, String name, double latitude, double longitude, double radius) async {
    final geofences = getGeofences(childId);
    geofences.add({
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    });
    await _settingsBox.put('geofences_$childId', geofences);
    notifyListeners();
  }
  
  Future<void> removeGeofence(String childId, String name) async {
    final geofences = getGeofences(childId);
    geofences.removeWhere((fence) => fence['name'] == name);
    await _settingsBox.put('geofences_$childId', geofences);
    notifyListeners();
  }
  
  // Notification settings
  bool getNotificationEnabled(String type) {
    return _settingsBox.get('notification_$type', defaultValue: true);
  }
  
  Future<void> setNotificationEnabled(String type, bool enabled) async {
    await _settingsBox.put('notification_$type', enabled);
    notifyListeners();
  }
}
