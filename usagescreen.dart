import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart'; // Add this import

class AppData {
  final String packageName;
  final String appName;
  final String iconBase64;
  int? limitMinutes;
  Duration usage;
  bool isCurrentlyForeground;
  bool isBlocked;

  AppData({
    required this.packageName,
    required this.appName,
    required this.iconBase64,
    this.limitMinutes,
    required this.usage,
    this.isCurrentlyForeground = false,
    this.isBlocked = false,
  });

  factory AppData.fromJson(Map<String, dynamic> json) {
    return AppData(
      packageName: json['packageName'],
      appName: json['appName'],
      iconBase64: json['iconBase64'],
      limitMinutes: json['limitMinutes'],
      usage: Duration(minutes: json['usageMinutes'] ?? 0),
      isCurrentlyForeground: json['isCurrentlyForeground'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'iconBase64': iconBase64,
      'limitMinutes': limitMinutes,
      'usageMinutes': usage.inMinutes,
      'isCurrentlyForeground': isCurrentlyForeground,
      'isBlocked': isBlocked,
    };
  }
}

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({Key? key}) : super(key: key);

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen>
    with WidgetsBindingObserver {
  List<AppData> _appDataList = [];
  bool _isLoading = true;
  int _totalUsageTime = 0;
  String _timeRange = 'Today';
  bool _hasPermission = false;
  Timer? _periodicTimer;
  Timer? _foregroundCheckTimer;
  String _currentForegroundApp = '';

  static const _methodChannel = MethodChannel('app_usage_tracker/methods');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndFetchData();
    _initializeNotifications();
    _startBackgroundChecking();
    _startForegroundAppTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicTimer?.cancel();
    _foregroundCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUsageStats();
      _checkCurrentForegroundApp();
    }
  }

  Future<void> openUsageAccessSettings() async {
    try {
      await _methodChannel.invokeMethod('openUsageAccessSettings');
    } catch (e) {
      print('Error opening usage access settings: $e');
    }
  }

  Future<void> closeApp(String packageName) async {
    try {
      await _methodChannel
          .invokeMethod('closeApp', {'packageName': packageName});
    } catch (e) {
      print('Error closing app: $e');
    }
  }

  Future<void> lockDevice() async {
    try {
      await _methodChannel.invokeMethod('lockDevice');
    } catch (e) {
      print('Error locking device: $e');
    }
  }

  Future<void> enableDeviceAdmin() async {
    try {
      await _methodChannel.invokeMethod('enableDeviceAdmin');
    } catch (e) {
      print('Error enabling device admin: $e');
    }
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _methodChannel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print('Error requesting ignore battery optimizations: $e');
    }
  }

  void _startForegroundAppTracking() {
    _foregroundCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkCurrentForegroundApp();
    });
  }

  Future<void> _checkCurrentForegroundApp() async {
    if (!_hasPermission) return;

    try {
      final foregroundApp =
          await _methodChannel.invokeMethod('getCurrentForegroundApp');

      if (foregroundApp != null && foregroundApp != _currentForegroundApp) {
        setState(() {
          _currentForegroundApp = foregroundApp;

          // Update foreground status for all apps
          for (var app in _appDataList) {
            app.isCurrentlyForeground = app.packageName == foregroundApp;

            // Check if this app is blocked and in foreground
            if (app.isBlocked && app.isCurrentlyForeground) {
              print('Attempting to close blocked app: ${app.packageName}');
              _methodChannel.invokeMethod('closeApp', {
                'packageName': app.packageName,
              });
              // Show a notification to inform the user
              _showLimitNotification(
                app.packageName,
                app.appName,
                app.limitMinutes ?? 0,
                app.usage.inMinutes,
              );
            }

            // If this app has reached its limit but is not yet blocked
            else if (app.limitMinutes != null &&
                app.usage.inMinutes >= app.limitMinutes! &&
                !app.isBlocked &&
                app.isCurrentlyForeground) {
              print(
                  'App ${app.appName} has reached limit. Blocking and closing.');
              app.isBlocked = true;
              _saveAppLimits();
              _methodChannel.invokeMethod('lockDevice');
              // First try to block the app
              _methodChannel.invokeMethod('blockApp', {
                'packageName': app.packageName,
              });

              // Then show notification
              _showLimitNotification(
                app.packageName,
                app.appName,
                app.limitMinutes!,
                app.usage.inMinutes,
              );

              // Finally try to close it
              _methodChannel.invokeMethod('closeApp', {
                'packageName': app.packageName,
              });
            }
          }
        });
      }
    } catch (e) {
      print('Error checking foreground app: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'app_limit_channel',
          channelName: 'App Limit Notifications',
          channelDescription: 'Notifications for app usage limits',
          importance: NotificationImportance.High,
        ),
      ],
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _startBackgroundChecking() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAppLimits();
    });
  }

  Future<void> _checkAppLimits() async {
    if (!_hasPermission) return;

    try {
      final appUsage = AppUsage();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final stats = await appUsage.getAppUsage(startOfDay, now);
      final prefs = await SharedPreferences.getInstance();
      final limitsData = prefs.getString('app_limits') ?? '{}';
      final Map<String, dynamic> limits = jsonDecode(limitsData);

      for (var stat in stats) {
        // Check if the app has a limit set
        if (limits.containsKey(stat.packageName)) {
          final Map<String, dynamic> appLimit = limits[stat.packageName];
          final limitMinutes = appLimit['limitMinutes'];

          if (limitMinutes != null && stat.usage.inMinutes >= limitMinutes) {
            // Show notification for exceeded limit
            await _showLimitNotification(
              stat.packageName,
              _getAppName(stat.packageName),
              limitMinutes,
              stat.usage.inMinutes,
            );

            // Try to block the app
            try {
              await _methodChannel.invokeMethod('blockApp', {
                'packageName': stat.packageName,
              });

              // Update UI status
              final app = _appDataList.firstWhereOrNull(
                (app) => app.packageName == stat.packageName,
              );
              if (app != null) {
                setState(() {
                  app.isBlocked = true;
                });
                await _saveAppLimits(); // Save blocked status
              }

              // If this app is currently in foreground, close it
              if (stat.packageName == _currentForegroundApp) {
                await _methodChannel.invokeMethod('closeApp', {
                  'packageName': stat.packageName,
                });
              }

              // Lock the device
              await _methodChannel.invokeMethod('lockDevice');
            } catch (e) {
              print('Failed to block app or lock device: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error checking limits: $e');
    }
  }

  Future<void> _showLimitNotification(
    String packageName,
    String appName,
    int limitMinutes,
    int usedMinutes,
  ) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: packageName.hashCode,
          channelKey: 'app_limit_channel',
          title: 'Time Limit Reached',
          body:
              'You\'ve used $appName for $usedMinutes minutes (limit: $limitMinutes minutes)',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          // importance: NotificationImportance.High,
          // priority: NotificationPriority.High,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'OPEN_SETTINGS',
            label: 'Adjust Limit',
            actionType: ActionType.Default,
          ),
        ],
      );
      print('Notification sent for $appName');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> _checkPermissionAndFetchData() async {
    if (await Permission.ignoreBatteryOptimizations.isGranted &&
        await _requestUsageStatsPermission()) {
      setState(() {
        _hasPermission = true;
      });
      await Future.delayed(Duration(seconds: 3));
      await _loadAppLimits();
      _fetchUsageStats();
      _checkCurrentForegroundApp();
    } else {
      setState(() {
        _isLoading = false;
        _hasPermission = false;
      });
    }
  }

  Future<bool> _requestUsageStatsPermission() async {
    try {
      final result = await _methodChannel.invokeMethod('checkUsagePermission');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _openUsageSettings() async {
    try {
      await _methodChannel.invokeMethod('openUsageSettings');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening settings: $e')));
      }
    }
  }

  Future<void> _openAppSettings(String packageName) async {
    try {
      await _methodChannel.invokeMethod('openAppSettings', {
        'packageName': packageName,
      });
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.ignoreBatteryOptimizations.request();

    if (status.isGranted) {
      bool hasUsagePermission = await _requestUsageStatsPermission();

      if (!hasUsagePermission) {
        await openUsageAccessSettings();
        // Check again after settings were opened
        hasUsagePermission = await _requestUsageStatsPermission();
      }

      setState(() {
        _hasPermission = hasUsagePermission;
      });

      if (hasUsagePermission) {
        await _loadAppLimits();
        _fetchUsageStats();
        _checkCurrentForegroundApp();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Cannot fetch usage statistics.'),
          ),
        );
      }
    }
  }

  Future<void> _loadAppLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limitsData = prefs.getString('app_limits') ?? '{}';
      final Map<String, dynamic> limits = jsonDecode(limitsData);

      // Update app data list with saved limits
      for (var app in _appDataList) {
        if (limits.containsKey(app.packageName)) {
          final Map<String, dynamic> appLimit = limits[app.packageName];
          app.limitMinutes = appLimit['limitMinutes'];
          app.isBlocked = appLimit['isBlocked'] ?? false;
        }
      }

      print('Loaded app limits: $limits');
    } catch (e) {
      print('Error loading app limits: $e');
    }
  }

  Future<void> _saveAppLimits() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> limits = {};
    for (var app in _appDataList) {
      if (app.limitMinutes != null || app.isBlocked) {
        limits[app.packageName] = {
          'limitMinutes': app.limitMinutes,
          'isBlocked': app.isBlocked,
        };
      }
    }

    await prefs.setString('app_limits', jsonEncode(limits));
  }

  Future<void> _fetchUsageStats() async {
    setState(() {
      _isLoading = true;
    });

    // Define time range
    DateTime endDate = DateTime.now();
    DateTime startDate;

    switch (_timeRange) {
      case 'Today':
        startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
        break;
      case 'Yesterday':
        final yesterday = endDate.subtract(const Duration(days: 1));
        startDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          0,
          0,
          0,
        );
        endDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
        );
        break;
      case 'This Week':
        startDate = endDate.subtract(Duration(days: endDate.weekday - 1));
        startDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          0,
          0,
          0,
        );
        break;
      default:
        startDate = DateTime(endDate.year, endDate.month, endDate.day, 0, 0, 0);
    }

    try {
      // Create an instance of AppUsage and then call the method
      final appUsage = AppUsage();
      final usageStats = await appUsage.getAppUsage(startDate, endDate);

      // Get app icons and info
      List<AppData> appDataList = [];

      for (var stat in usageStats) {
        if (stat.usage.inMinutes == 0) continue;

        String iconBase64 = '';
        try {
          final iconResult = await _methodChannel.invokeMethod('getAppIcon', {
            'packageName': stat.packageName,
          });
          iconBase64 = iconResult ?? '';
        } catch (e) {
          print('Error getting icon for ${stat.packageName}: $e');
        }

        appDataList.add(
          AppData(
            packageName: stat.packageName,
            appName: _getAppName(stat.packageName),
            iconBase64: iconBase64,
            usage: stat.usage,
            isCurrentlyForeground: stat.packageName == _currentForegroundApp,
          ),
        );
      }

      // Sort by usage time in descending order
      appDataList.sort(
        (a, b) => b.usage.inMinutes.compareTo(a.usage.inMinutes),
      );

      // Calculate total usage time
      int totalMinutes = 0;
      for (var app in appDataList) {
        totalMinutes += app.usage.inMinutes;
      }

      // Load saved limits
      await _loadAppLimits();

      setState(() {
        _appDataList = appDataList;
        _totalUsageTime = totalMinutes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching usage data: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  String _getAppName(String packageName) {
    // Extract app name from package name
    // Example: com.whatsapp -> WhatsApp
    final parts = packageName.split('.');
    if (parts.isNotEmpty) {
      String name = parts.last;

      // Convert first letter to uppercase and add spaces before capital letters
      name = name.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => ' ${match.group(0)}',
      );

      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
      }

      return name.trim();
    }
    return packageName;
  }

  Future<void> _showLimitDialog(AppData app) async {
    int? limitMinutes = app.limitMinutes;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Time Limit for ${app.appName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current usage: ${_formatDuration(app.usage)}'),
            if (app.isBlocked) // Add this block
              Text(
                'This app is currently blocked by parent.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Time Limit (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(
                text: limitMinutes?.toString() ?? '',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  limitMinutes = int.tryParse(value);
                } else {
                  limitMinutes = null;
                }
              },
            ),
          ],
        ),
        actions: [
          if (app.isBlocked) // Add this block
            TextButton(
              onPressed: () async {
                try {
                  await _methodChannel.invokeMethod('unblockApp', {
                    'packageName': app.packageName,
                  });

                  setState(() {
                    app.isBlocked = false;
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  print('Failed to unblock app: $e');
                }
              },
              child: const Text('Unblock App'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (limitMinutes != null && limitMinutes! < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Limit must be at least 1 minute'),
                  ),
                );
                return;
              }

              setState(() {
                app.limitMinutes = limitMinutes;
              });

              _saveAppLimits();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Usage Tracker'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _timeRange = value;
              });
              _fetchUsageStats();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(
                value: 'Yesterday',
                child: Text('Yesterday'),
              ),
              const PopupMenuItem(
                value: 'This Week',
                child: Text('This Week'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [Text(_timeRange), const Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildPermissionRequest()
              : _buildUsageStatsList(),
    );
  }

  Widget _buildPermissionRequest() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Usage statistics permission is required',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _requestPermission,
            child: const Text('Grant Permission'),
          ),
          ElevatedButton(
            onPressed: openUsageAccessSettings,
            child: const Text('Open Usage Access Settings'),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You may need to enable usage access in your phone settings:\n'
              'Settings > Apps > Special access > Usage access',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatsList() {
    if (_appDataList.isEmpty) {
      return const Center(
        child: Text('No usage data available for selected time period'),
      );
    }

    return Column(
      children: [
        // Current foreground app card
        if (_currentForegroundApp.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Currently Active App',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.circle, color: Colors.green, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          _getAppName(_currentForegroundApp),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentForegroundApp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Total usage card

        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Screen Time',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(Duration(minutes: _totalUsageTime)),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.yMMMd().format(DateTime.now()),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),

        // App list
        Expanded(
          child: ListView.builder(
            itemCount: _appDataList.length,
            itemBuilder: (context, index) {
              final app = _appDataList[index];

              // Calculate percentage of total
              double percentage = _totalUsageTime > 0
                  ? (app.usage.inMinutes / _totalUsageTime) * 100
                  : 0;

              // Icon widget
              Widget iconWidget;
              if (app.iconBase64.isNotEmpty) {
                try {
                  final iconBytes = base64Decode(app.iconBase64);
                  iconWidget = Image.memory(iconBytes, width: 40, height: 40);
                } catch (e) {
                  // Fallback to letter avatar
                  iconWidget = _buildLetterAvatar(app);
                }
              } else {
                iconWidget = _buildLetterAvatar(app);
              }

              return ListTile(
                leading: Stack(
                  children: [
                    iconWidget,
                    if (app.isCurrentlyForeground)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(app.appName),
                    if (app.isCurrentlyForeground)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (app.isBlocked) // Add this block
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Blocked by Parent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.packageName),
                    if (app.limitMinutes != null)
                      Text(
                        'Limit: ${_formatDuration(Duration(minutes: app.limitMinutes!))}',
                        style: TextStyle(
                          color: app.usage.inMinutes >= (app.limitMinutes ?? 0)
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_formatDuration(app.usage)),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () => _showLimitDialog(app),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLetterAvatar(AppData app) {
    final color =
        Colors.primaries[app.packageName.hashCode % Colors.primaries.length];

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          app.appName[0].toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
