// import 'package:flutter/material.dart';
// import 'package:installed_apps/app_info.dart';
// import 'package:installed_apps/installed_apps.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:app_usage/app_usage.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'App Usage Limiter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const AppListScreen(),
//     );
//   }
// }

// class AppListScreen extends StatefulWidget {
//   const AppListScreen({Key? key}) : super(key: key);

//   @override
//   State<AppListScreen> createState() => _AppListScreenState();
// }

// class _AppListScreenState extends State<AppListScreen> with WidgetsBindingObserver {
//   List<AppInfo> _apps = [];
//   bool _isLoading = true;
//   Map<String, int> _appLimits = {};  // Minutes per day
//   Map<String, int> _appUsage = {};   // Minutes used today

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initialize();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _loadUsageStats();
//     }
//   }

//   Future<void> _initialize() async {
//     await _requestPermissions();
//     await _loadApps();
//     await _loadLimits();
//     await _loadUsageStats();
//   }

//   Future<void> _requestPermissions() async {
//     // Request necessary permissions
//     var status = await Permission.appTrackingTransparency.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Permission required to track app usage')),
//       );
//     }
//   }

//   Future<void> _loadApps() async {
//     try {
//       List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
//       setState(() {
//         _apps = apps;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading apps: $e');
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load apps: $e')),
//       );
//     }
//   }

//   Future<void> _loadLimits() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       Map<String, int> limits = {};
      
//       for (var app in _apps) {
//         int limit = prefs.getInt('limit_${app.packageName}') ?? 0;
//         limits[app.packageName] = limit;
//       }
      
//       setState(() {
//         _appLimits = limits;
//       });
//     } catch (e) {
//       print('Error loading limits: $e');
//     }
//   }

//   Future<void> _saveLimit(String packageName, int limitMinutes) async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setInt('limit_${packageName}', limitMinutes);
      
//       setState(() {
//         _appLimits[packageName] = limitMinutes;
//       });
//     } catch (e) {
//       print('Error saving limit: $e');
//     }
//   }

//   Future<void> _loadUsageStats() async {
//     // Get today's start time
//     DateTime now = DateTime.now();
//     DateTime startOfDay = DateTime(now.year, now.month, now.day);
    
//     try {
//       // Get app usage statistics
//       List<AppUsageInfo> appUsageInfo = await AppUsage().getAppUsage(
//         startOfDay, 
//         now,
//       );
      
//       Map<String, int> usage = {};
      
//       for (var info in appUsageInfo) {
//         // Convert duration to minutes
//         int minutes = info.usage.inMinutes;
//         usage[info.packageName] = minutes;
//       }
      
//       setState(() {
//         _appUsage = usage;
//       });
      
//       // Check if any app has reached its limit
//       _checkLimits();
//     } catch (e) {
//       print('Failed to get app usage: $e');
//       // Show error message to user
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load usage stats: $e')),
//       );
//     }
//   }

//   void _checkLimits() {
//     for (var app in _apps) {
//       String packageName = app.packageName;
//       int limit = _appLimits[packageName] ?? 0;
//       int usage = _appUsage[packageName] ?? 0;
      
//       if (limit > 0 && usage >= limit) {
//         // App has reached its limit
//         _showLimitReachedDialog(app.name ?? 'Unknown App');
//       }
//     }
//   }

//   void _showLimitReachedDialog(String appName) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Usage Limit Reached'),
//         content: Text('You have reached your daily usage limit for $appName.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _launchApp(AppInfo app) async {
//     String packageName = app.packageName;
//     int limit = _appLimits[packageName] ?? 0;
//     int usage = _appUsage[packageName] ?? 0;
    
//     if (limit > 0 && usage >= limit) {
//       // App has reached its limit
//       _showLimitReachedDialog(app.name ?? 'Unknown App');
//     } else {
//       // Launch the app
//       try {
//         InstalledApps.startApp(packageName);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to launch ${app.name}: $e')),
//         );
//       }
//     }
//   }

//   void _setLimit(AppInfo app) {
//     int currentLimit = _appLimits[app.packageName] ?? 0;
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController controller = TextEditingController(text: currentLimit.toString());
        
//         return AlertDialog(
//           title: Text('Set Time Limit for ${app.name}'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text('Enter the daily time limit in minutes:'),
//               TextField(
//                 controller: controller,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   hintText: 'Minutes per day',
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 int limitMinutes = int.tryParse(controller.text) ?? 0;
//                 _saveLimit(app.packageName, limitMinutes);
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('App Usage Limiter'),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await _loadUsageStats();
//               },
//               child: ListView.builder(
//                 itemCount: _apps.length,
//                 itemBuilder: (context, index) {
//                   AppInfo app = _apps[index];
//                   int usedMinutes = _appUsage[app.packageName] ?? 0;
//                   int limitMinutes = _appLimits[app.packageName] ?? 0;
                  
//                   return ListTile(
//                     leading: app.icon != null
//                         ? Image.memory(app.icon!, width: 40, height: 40)
//                         : const Icon(Icons.android),
//                     title: Text(app.name ?? 'Unknown App'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(app.packageName),
//                         limitMinutes > 0
//                             ? Text(
//                                 'Used: $usedMinutes min / Limit: $limitMinutes min',
//                                 style: TextStyle(
//                                   color: usedMinutes >= limitMinutes
//                                       ? Colors.red
//                                       : null,
//                                 ),
//                               )
//                             : const Text('No limit set'),
//                       ],
//                     ),
//                     onTap: () => _setLimit(app),
//                     onLongPress: () => _launchApp(app),
//                   );
//                 },
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadUsageStats,
//         tooltip: 'Refresh usage stats',
//         child: const Icon(Icons.refresh),
//       ),
//     );
//   }
// }