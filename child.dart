import 'package:hive/hive.dart';

part 'child.g.dart';

@HiveType(typeId: 0)
class Child extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int age;
  
  @HiveField(3)
  String profileImagePath;
  
  @HiveField(4)
  String uniqueCode;
  
  @HiveField(5)
  bool isScreenTimeEnabled;
  
  @HiveField(6)
  bool isAppMonitoringEnabled;
  
  @HiveField(7)
  bool isWebMonitoringEnabled;
  
  @HiveField(8)
  bool isLocationTrackingEnabled;
  
  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.uniqueCode,
    this.profileImagePath = '',
    this.isScreenTimeEnabled = true,
    this.isAppMonitoringEnabled = true,
    this.isWebMonitoringEnabled = true,
    this.isLocationTrackingEnabled = true,
  });
}