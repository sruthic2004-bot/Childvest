import 'package:hive/hive.dart';

part 'location_history.g.dart';

@HiveType(typeId: 4)
class LocationHistory extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String childId;
  
  @HiveField(2)
  double latitude;
  
  @HiveField(3)
  double longitude;
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  String locationName;
  
  LocationHistory({
    required this.id,
    required this.childId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.locationName = '',
  });
}
