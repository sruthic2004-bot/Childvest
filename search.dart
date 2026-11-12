import 'package:hive/hive.dart';

part 'search.g.dart';

@HiveType(typeId: 10)
class SearchHistory extends HiveObject {
  @HiveField(0)
  String url;

  @HiveField(1)
  DateTime timestamp;

  SearchHistory({required this.url, required this.timestamp});
}

@HiveType(typeId: 1)
class BlockedWebsite extends HiveObject {
  @HiveField(0)
  String url;

  BlockedWebsite({required this.url, required DateTime timestamp});
}
