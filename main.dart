import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chidvest/models/app_usage.dart';
import 'package:chidvest/models/browsing_history.dart';
import 'package:chidvest/models/child.dart';
import 'package:chidvest/models/location_history.dart';
import 'package:chidvest/models/screen_time.dart';
import 'package:chidvest/models/search.dart';
import 'package:chidvest/provider/Settings_Provider.dart';
import 'package:chidvest/provider/auth_provider.dart';
import 'package:chidvest/provider/children_provider.dart';
import 'package:chidvest/provider/usertype.dart';
import 'package:chidvest/screen.dart/login_screen.dart' show LoginScreen;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'app_limit_channel',
      channelName: 'App Limit Notifications',
      channelDescription: 'Notifications for app usage time limits',
      defaultColor: Colors.blue,
      ledColor: Colors.red,
      enableVibration: true,
      importance: NotificationImportance.High,
      playSound: true,
    ),
  ]);
  // Initialize Hive
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  // Register Hive adapters
  Hive.registerAdapter(ChildAdapter());
  Hive.registerAdapter(ScreenTimeAdapter());
  Hive.registerAdapter(AppUsageAdapter());
  Hive.registerAdapter(BrowsingHistoryAdapter());
  Hive.registerAdapter(LocationHistoryAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  Hive.registerAdapter(BlockedWebsiteAdapter());

  await Hive.openBox<SearchHistory>('search_history');
  await Hive.openBox<BlockedWebsite>('blocked_websites');

  // Open Hive boxes
  await Hive.openBox<Child>('children');
  await Hive.openBox<ScreenTime>('screenTime');
  await Hive.openBox<AppUsage>('appUsage');
  await Hive.openBox<BrowsingHistory>('browsingHistory');
  await Hive.openBox<LocationHistory>('locationHistory');
  await Hive.openBox('settings');
  await Hive.openBox('auth');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Parental Control App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: UserTypeSelectionScreen(),
      ),
    );
  }
}
