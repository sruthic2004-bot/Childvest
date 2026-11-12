// import 'package:flutter/material.dart';
// import 'package:usage_stats/usage_stats.dart';

// class UsageStatsScreen55 extends StatefulWidget {
//   @override
//   _UsageStatsScreenState createState() => _UsageStatsScreenState();
// }

// class _UsageStatsScreenState extends State<UsageStatsScreen55> {
//   List<UsageInfo> _usageStats = [];

//   @override
//   void initState() {
//     super.initState();
//     _initUsageStats();
//   }

//   Future<void> _initUsageStats() async {
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 1));

//     List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
//       startDate,
//       endDate,
//     );

//     setState(() {
//       _usageStats = usageStats;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('App Usage'),
//       ),
//       body: _usageStats.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _usageStats.length,
//               itemBuilder: (context, index) {
//                 UsageInfo usageInfo = _usageStats[index];
//                 return ListTile(
//                   title: Text(usageInfo.packageName ?? 'Unknown'),
//                   subtitle: Text(
//                       'Usage: ${Duration(milliseconds: int.tryParse(usageInfo.totalTimeInForeground ?? '0') ?? 0).inMinutes} minutes'),
//                 );
//               },
//             ),
//     );
//   }
// }

// class ScreenTimeApp55 extends StatefulWidget {
//   @override
//   _ScreenTimeAppState createState() => _ScreenTimeAppState();
// }

// class _ScreenTimeAppState extends State<ScreenTimeApp55> {
//   Duration _screenTime = Duration.zero;

//   @override
//   void initState() {
//     super.initState();
//     _initScreenTime();
//   }

//   Future<void> _initScreenTime() async {
//     DateTime endDate = DateTime.now();
//     DateTime startDate = endDate.subtract(Duration(days: 1));

//     List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
//       startDate,
//       endDate,
//     );

//     Duration totalScreenTime = usageStats.fold(
//       Duration.zero,
//       (previousValue, element) =>
//           previousValue + Duration(milliseconds: int.tryParse(element.totalTimeInForeground ?? '0') ?? 0),
//     );

//     setState(() {
//       _screenTime = totalScreenTime;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Screen Time'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Total Screen Time:',
//               style: TextStyle(fontSize: 24),
//             ),
//             Text(
//               '${_screenTime.inHours} hours ${_screenTime.inMinutes.remainder(60)} minutes',
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }