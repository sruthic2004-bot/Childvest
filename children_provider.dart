import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../models/child.dart';
import '../../models/screen_time.dart';
import '../../models/app_usage.dart';
import '../../models/location_history.dart';

class ChildrenProvider with ChangeNotifier {
  final Box<Child> _childrenBox = Hive.box<Child>('children');
  final Box<ScreenTime> _screenTimeBox = Hive.box<ScreenTime>('screenTime');
  // final Box<AppUsage> _appUsageBox = Hive.box<AppUsage>('appUsage');
  // final Box<BrowsingHistor1y> _browsingHistoryBox =
  //     Hive.box<BrowsingHistory>('browsingHistory');
  final Box<LocationHistory> _locationHistoryBox =
      Hive.box<LocationHistory>('locationHistory');

  List<Child> get children => _childrenBox.values.toList();
  Child? findChildByCode(String code) {
    try {
      return _childrenBox.values.firstWhere(
        (child) => child.uniqueCode == code,
      );
    } catch (e) {
      // If no child is found with this code
      return null;
    }
  }

  Future<void> addChild(
    String name,
    int age,
    String? profileImagePath,
  ) async {
    final child = Child(
      uniqueCode: '',
      id: const Uuid().v4(),
      name: name,
      age: age,
      profileImagePath: profileImagePath ?? '',
    );

    await _childrenBox.add(child);
    notifyListeners();
  }

  Future<void> updateChild(Child child) async {
    await child.save();
    notifyListeners();
  }

  Future<void> deleteChild(Child child) async {
    // Delete all related data
    final childId = child.id;

    final screenTimeToDelete =
        _screenTimeBox.values.where((st) => st.childId == childId).toList();

    // final appUsageToDelete =
    //     _appUsageBox.values.where((au) => au.childId == childId).toList();

    // final browsingHistoryToDelete = _browsingHistoryBox.values
    //     .where((bh) => bh.childId == childId)
    //     .toList();

    final locationHistoryToDelete = _locationHistoryBox.values
        .where((lh) => lh.childId == childId)
        .toList();

    for (var screenTime in screenTimeToDelete) {
      await screenTime.delete();
    }

    // for (var appUsage in appUsageToDelete) {
    //   await appUsage.delete();
    // }

    // for (var browsingHistory in browsingHistoryToDelete) {
    //   await browsingHistory.delete();
    // }

    for (var locationHistory in locationHistoryToDelete) {
      await locationHistory.delete();
    }

    await child.delete();
    notifyListeners();
  }

  // Screen Time Methods
  Future<void> addScreenTime(String childId, DateTime date, int minutes) async {
    final existingScreenTime = _screenTimeBox.values
        .where((st) =>
            st.childId == childId &&
            st.date.day == date.day &&
            st.date.month == date.month &&
            st.date.year == date.year)
        .toList();

    if (existingScreenTime.isNotEmpty) {
      final screenTime = existingScreenTime.first;
      screenTime.totalMinutes += minutes;

      // Update hourly breakdown
      final hour = date.hour;
      screenTime.timeByHour[hour.toString()] =
          (screenTime.timeByHour[hour.toString()] ?? 0) + minutes;

      await screenTime.save();
    } else {
      final newScreenTime = ScreenTime(
        id: const Uuid().v4(),
        childId: childId,
        date: DateTime(date.year, date.month, date.day),
        totalMinutes: minutes,
        timeByHour: {date.hour.toString(): minutes},
      );

      await _screenTimeBox.add(newScreenTime);
    }

    notifyListeners();
  }

  List<ScreenTime> getScreenTimeForChild(String childId,
      {DateTime? startDate, DateTime? endDate}) {
    var screenTimes =
        _screenTimeBox.values.where((st) => st.childId == childId).toList();

    if (startDate != null) {
      screenTimes = screenTimes
          .where((st) =>
              st.date.isAfter(startDate) || st.date.isAtSameMomentAs(startDate))
          .toList();
    }

    if (endDate != null) {
      screenTimes = screenTimes
          .where((st) =>
              st.date.isBefore(endDate) || st.date.isAtSameMomentAs(endDate))
          .toList();
    }

    return screenTimes;
  }

  // App Usage Methods
  Future<void> recordAppUsage(
      String childId, String packageName, String appName, int minutes) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // final existingAppUsage = _appUsageBox.values
    //     .where((au) =>
    //         au.childId == childId &&
    //         au.appPackageName == packageName &&
    //         au.date.day == todayDate.day &&
    //         au.date.month == todayDate.month &&
    //         au.date.year == todayDate.year)
    //     .toList();

    //   if (existingAppUsage.isNotEmpty) {
    //     final appUsage = existingAppUsage.first;
    //     appUsage.minutesUsed += minutes;
    //     appUsage.launchCount += 1;
    //     await appUsage.save();
    //   } else {
    //     final newAppUsage = AppUsage(
    //       id: const Uuid().v4(),
    //       childId: childId,
    //       appPackageName: packageName,
    //       appName: appName,
    //       date: todayDate,
    //       minutesUsed: minutes,
    //       launchCount: 1,
    //       icon: null,
    //       appCategory: '',
    //       durationMinutes: null,
    //       timeByHour: {},
    //     );

    //     await _appUsageBox.add(newAppUsage);
    //   }

    //   notifyListeners();
    // }

    // List<AppUsage> getAppUsageForChild(String childId,
    //     {DateTime? startDate, DateTime? endDate}) {
    //   var appUsages =
    //       _appUsageBox.values.where((au) => au.childId == childId).toList();

    //   if (startDate != null) {
    //     appUsages = appUsages
    //         .where((au) =>
    //             au.date.isAfter(startDate) || au.date.isAtSameMomentAs(startDate))
    //         .toList();
    //   }

    //   if (endDate != null) {
    //     appUsages = appUsages
    //         .where((au) =>
    //             au.date.isBefore(endDate) || au.date.isAtSameMomentAs(endDate))
    //         .toList();
    //   }

    //   return appUsages;
    // }

    // Browsing History Methods
    Future<void> addBrowsingHistory(
        String childId, String url, String title, DateTime timestamp) async {
      // final browsingHistory = BrowsingHistory(
      //   id: const Uuid().v4(),
      //   childId: childId,
      //   url: url,
      //   title: title,
      //   timestamp: timestamp,
      // );

      //   await _browsingHistoryBox.add(browsingHistory);
      //   notifyListeners();
      // }

      // List<BrowsingHistory> getBrowsingHistoryForChild(String childId,
      //     {DateTime? startDate, DateTime? endDate}) {
      //   var history = _browsingHistoryBox.values
      //       .where((bh) => bh.childId == childId)
      //       .toList();

      //   if (startDate != null) {
      //     history = history
      //         .where((bh) =>
      //             bh.timestamp.isAfter(startDate) ||
      //             bh.timestamp.isAtSameMomentAs(startDate))
      //         .toList();
      //   }

      //   if (endDate != null) {
      //     history = history
      //         .where((bh) =>
      //             bh.timestamp.isBefore(endDate) ||
      //             bh.timestamp.isAtSameMomentAs(endDate))
      //         .toList();
      //   }

      //   return history;
      // }

      // Location History Methods
      Future<void> addLocationHistory(
          String childId, double latitude, double longitude,
          {String locationName = ''}) async {
        final locationHistory = LocationHistory(
          id: const Uuid().v4(),
          childId: childId,
          latitude: latitude,
          longitude: longitude,
          timestamp: DateTime.now(),
          locationName: locationName,
        );

        await _locationHistoryBox.add(locationHistory);
        notifyListeners();
      }

      List<LocationHistory> getLocationHistoryForChild(String childId,
          {DateTime? startDate, DateTime? endDate}) {
        var locations = _locationHistoryBox.values
            .where((lh) => lh.childId == childId)
            .toList();

        if (startDate != null) {
          locations = locations
              .where((lh) =>
                  lh.timestamp.isAfter(startDate) ||
                  lh.timestamp.isAtSameMomentAs(startDate))
              .toList();
        }

        if (endDate != null) {
          locations = locations
              .where((lh) =>
                  lh.timestamp.isBefore(endDate) ||
                  lh.timestamp.isAtSameMomentAs(endDate))
              .toList();
        }

        return locations;
      }
    }
  }
}
