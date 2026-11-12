import 'package:hive/hive.dart';

part 'screen_time.g.dart';

@HiveType(typeId: 11)
class ScreenTime extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String childId;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int totalMinutes;

  @HiveField(4)
  Map<String, int> timeByHour;

  ScreenTime({
    required this.id,
    required this.childId,
    required this.date,
    this.totalMinutes = 0,
    required this.timeByHour,
  });
}
