import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'browsing_history.g.dart';

@HiveType(typeId: 3)
class BrowsingHistory extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String childId;
  
  @HiveField(2)
  String url;
  
  @HiveField(3)
  String title;
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  int timeSpentSeconds;
  
  BrowsingHistory({
    required this.id,
    required this.childId,
    required this.url,
    required this.title,
    required this.timestamp,
    this.timeSpentSeconds = 0,
  });

  // Factory constructor to create a new history entry
  factory BrowsingHistory.create({
    required String childId,
    required String url,
    required String title,
  }) {
    return BrowsingHistory(
      id: const Uuid().v4(),
      childId: childId,
      url: url,
      title: title,
      timestamp: DateTime.now(),
    );
  }

  // Method to update time spent
  void updateTimeSpent(int seconds) {
    timeSpentSeconds += seconds;
    save();
  }
}
