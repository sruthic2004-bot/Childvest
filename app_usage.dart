import 'package:hive/hive.dart';

part 'app_usage.g.dart';

@HiveType(typeId: 2)
class AppUsage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String childId;

  @HiveField(2)
  String appPackageName;

  @HiveField(3)
  String appName;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  int minutesUsed;

  @HiveField(6)
  int launchCount;

  AppUsage({
    required this.id,
    required this.childId,
    required this.appPackageName,
    required this.appName,
    required this.date,
    this.minutesUsed = 0,
    this.launchCount = 0,
    required icon,
    required String appCategory,
    required durationMinutes,
    required Map<String, int> timeByHour,
  });
}
