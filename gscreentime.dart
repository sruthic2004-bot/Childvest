// import 'dart:math';

// import 'package:chidvest/provider/Settings_Provider.dart';
// import 'package:chidvest/provider/children_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'package:usage_stats/usage_stats.dart';
// import '../../models/child.dart';
// import '../../models/screen_time.dart';

// class ScreenTimeScreen extends StatefulWidget {
//   final Child child;

//   const ScreenTimeScreen({Key? key, required this.child}) : super(key: key);

//   @override
//   State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
// }

// class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
//   DateTimeRange _dateRange = DateTimeRange(
//     start: DateTime.now().subtract(const Duration(days: 7)),
//     end: DateTime.now(),
//   );

//   @override
//   Widget build(BuildContext context) {
//     final childrenProvider = Provider.of<ChildrenProvider>(context);
//     final settingsProvider = Provider.of<SettingsProvider>(context);

//     final screenTimeData = childrenProvider.getScreenTimeForChild(
//       widget.child.id,
//       startDate: _dateRange.start,
//       endDate: _dateRange.end.add(const Duration(days: 1)),
//     );

//     final screenTimeLimit =
//         settingsProvider.getScreenTimeLimit(widget.child.id);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Screen Time'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.date_range),
//             onPressed: () => _selectDateRange(context),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDateRangeHeader(),
//             _buildScreenTimeOverview(screenTimeData, screenTimeLimit),
//             _buildScreenTimeChart(screenTimeData, screenTimeLimit),
//             _buildDailyBreakdown(screenTimeData),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.timer),
//         onPressed: () => _showSetLimitDialog(
//           context,
//         ),
//       ),
//     );
//   }

//   Widget _buildDateRangeHeader() {
//     final dateFormat = DateFormat('MMM d, yyyy');
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           const Icon(Icons.date_range, color: Colors.blue),
//           const SizedBox(width: 8),
//           Text(
//             '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScreenTimeOverview(List<ScreenTime> data, int limit) {
//     int totalMinutes = 0;
//     int avgMinutesPerDay = 0;
//     int daysOverLimit = 0;

//     if (data.isNotEmpty) {
//       totalMinutes = data.fold(0, (sum, item) => sum + item.totalMinutes);
//       avgMinutesPerDay = totalMinutes ~/ data.length;
//       daysOverLimit = data.where((item) => item.totalMinutes > limit).length;
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Overview',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildStat('Total', '${totalMinutes} min'),
//                   _buildStat('Daily Avg', '${avgMinutesPerDay} min'),
//                   _buildStat('Days Over Limit', '$daysOverLimit days'),
//                   _buildStat('Daily Limit', '$limit min'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStat(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[600],
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildScreenTimeChart(List<ScreenTime> data, int limit) {
//     // Sort data by date
//     final sortedData = List<ScreenTime>.from(data)
//       ..sort((a, b) => a.date.compareTo(b.date));

//     final spots = <FlSpot>[];
//     final limitLine = <FlSpot>[];
//     final dateLabels = <String>[];

//     // Create chart data points
//     for (int i = 0; i < sortedData.length; i++) {
//       final screenTime = sortedData[i];
//       spots.add(FlSpot(i.toDouble(), screenTime.totalMinutes.toDouble()));
//       limitLine.add(FlSpot(i.toDouble(), limit.toDouble()));
//       dateLabels.add(DateFormat('E').format(screenTime.date));
//     }

//     if (spots.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(16),
//         child: Center(
//           child: Text('No screen time data available for the selected period.'),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Daily Screen Time',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 250,
//                 child: LineChart(
//                   LineChartData(
//                     gridData: FlGridData(show: false),
//                     titlesData: FlTitlesData(
//                       rightTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             if (value < 0 || value >= dateLabels.length) {
//                               return const SizedBox();
//                             }
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 dateLabels[value.toInt()],
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             );
//                           },
//                           reservedSize: 28,
//                         ),
//                       ),
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               value.toInt().toString(),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             );
//                           },
//                           reservedSize: 40,
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: true),
//                     minX: 0,
//                     maxX: (spots.length - 1).toDouble(),
//                     minY: 0,
//                     maxY: _getMaxYValue(spots, limit),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: spots,
//                         isCurved: true,
//                         barWidth: 3,
//                         color: Colors.blue,
//                         belowBarData: BarAreaData(
//                           show: true,
//                           color: Colors.blue.withOpacity(0.2),
//                         ),
//                         dotData: FlDotData(show: true),
//                       ),
//                       LineChartBarData(
//                         spots: limitLine,
//                         isCurved: false,
//                         barWidth: 2,
//                         color: Colors.red,
//                         dotData: FlDotData(show: false),
//                         dashArray: [5, 5],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: 12,
//                     height: 12,
//                     color: Colors.blue,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text('Screen Time'),
//                   const SizedBox(width: 16),
//                   Container(
//                     width: 12,
//                     height: 2,
//                     color: Colors.red,
//                   ),
//                   const SizedBox(width: 8),
//                   const Text('Daily Limit'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   double _getMaxYValue(List<FlSpot> spots, int limit) {
//     double maxY = spots.isEmpty
//         ? limit.toDouble()
//         : spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
//     return max(maxY, limit.toDouble()) * 1.2;
//   }

//   Widget _buildDailyBreakdown(List<ScreenTime> data) {
//     // Sort data by date (newest first)
//     final sortedData = List<ScreenTime>.from(data)
//       ..sort((a, b) => b.date.compareTo(a.date));

//     if (sortedData.isEmpty) {
//       return const SizedBox();
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Daily Breakdown',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: sortedData.length,
//                 separatorBuilder: (context, index) => const Divider(),
//                 itemBuilder: (context, index) {
//                   final screenTime = sortedData[index];
//                   return ListTile(
//                     title: Text(
//                       DateFormat('EEEE, MMM d').format(screenTime.date),
//                     ),
//                     subtitle: Text('${screenTime.totalMinutes} minutes'),
//                     trailing: Icon(
//                       Icons.info_outline,
//                       color: Colors.blue,
//                     ),
//                     onTap: () => _showDailyDetail(context, screenTime),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDailyDetail(BuildContext context, ScreenTime screenTime) {
//     final hourData = <int, int>{};

//     // Fill in all hours
//     for (int i = 0; i < 24; i++) {
//       hourData[i] = 0;
//     }

//     // Add actual data
//     screenTime.timeByHour.forEach((hourStr, minutes) {
//       final hour = int.tryParse(hourStr) ?? 0;
//       hourData[hour] = minutes;
//     });

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text(DateFormat('EEEE, MMM d').format(screenTime.date)),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Total Screen Time: ${screenTime.totalMinutes} minutes',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: BarChart(
//                   BarChartData(
//                     alignment: BarChartAlignment.spaceAround,
//                     maxY: hourData.values.isEmpty
//                         ? 10
//                         : hourData.values.reduce((a, b) => a > b ? a : b) * 1.2,
//               
//      barTouchData: BarTouchData(enabled: false),
//                     titlesData: FlTitlesData(
//                       rightTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (value, meta) {
//                             if (value % 4 != 0) return const SizedBox();
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 '${value.toInt()}:00',
//                                 style: const TextStyle(fontSize: 10),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: false),
//                     barGroups: hourData.entries.map((entry) {
//                       return BarChartGroupData(
//                         x: entry.key,
//                         barRods: [
//                           BarChartRodData(
//                             toY: entry.value.toDouble(),
//                             color: Colors.blue,
//                             width: 8,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ],
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDateRange(BuildContext context) async {
//     final newDateRange = await showDateRangePicker(
//       context: context,
//       initialDateRange: _dateRange,
//       firstDate: DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: DateTime.now(),
//     );

//     if (newDateRange != null) {
//       setState(() {
//         _dateRange = newDateRange;
//       });
//     }
//   }

//   void _showSetLimitDialog(BuildContext context) {
//     final settingsProvider =
//         Provider.of<SettingsProvider>(context, listen: false);
//     final limitController = TextEditingController(
//       text: settingsProvider.getScreenTimeLimit(widget.child.id).toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Set Screen Time Limit'),
//         content: TextField(
//           controller: limitController,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: 'Minutes per day'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final newLimit = int.tryParse(limitController.text) ?? 0;
//               if (newLimit > 0) {
//                 settingsProvider.setScreenTimeLimit(widget.child.id, newLimit);
//                 setState(() {}); // Refresh UI
//               }
//               Navigator.of(ctx).pop();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       ),
//     );
//   }
// }
