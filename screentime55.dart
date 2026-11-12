// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'dart:math' as math;
// import 'package:intl/intl.dart';

// class ScreenTimeApp extends StatefulWidget {
//   final String childId;
//   final String childName;

//   const ScreenTimeApp(
//       {Key? key, required this.childId, required this.childName})
//       : super(key: key);

//   @override
//   State<ScreenTimeApp> createState() => _ScreenTimeAppState();
// }

// class _ScreenTimeAppState extends State<ScreenTimeApp>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<int> screenTimeHours = [];
//   DateTime selectedDate = DateTime.now();
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadScreenTimeData();
//   }

//   Future<void> _loadScreenTimeData() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // In a real app, you would load this data from a database or API
//       // For demonstration, we'll generate some random data
//       screenTimeHours =
//           List.generate(7, (index) => math.Random().nextInt(5) + 1);

//       await Future.delayed(
//           const Duration(milliseconds: 800)); // Simulate network delay

//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       // Handle errors
//     }
//   }

//   String _getDayOfWeek(int index) {
//     final now = DateTime.now();
//     final date = now.subtract(Duration(days: 6 - index));
//     return DateFormat('E').format(date);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.childName}\'s Screen Time'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Daily Overview'),
//             Tab(text: 'Weekly Analysis'),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildDailyOverview(),
//                 _buildWeeklyAnalysis(),
//               ],
//             ),
//     );
//   }

//   Widget _buildDailyOverview() {
//     // Calculate today's screen time (last item in the list)
//     final todayHours = screenTimeHours.isNotEmpty ? screenTimeHours.last : 0;
//     final todayMinutes = (todayHours * 60 * math.Random().nextDouble()).round();

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Today\'s Screen Time',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '$todayHours hr ${todayMinutes % 60} min',
//                         style: const TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   LinearProgressIndicator(
//                     value: todayHours /
//                         8, // Using 8 hours as the max for demonstration
//                     minHeight: 12,
//                     backgroundColor: Colors.grey[200],
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       todayHours > 4 ? Colors.red : Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     todayHours > 4
//                         ? 'Screen time exceeds recommended limit'
//                         : 'Screen time within recommended limit',
//                     style: TextStyle(
//                       color: todayHours > 4 ? Colors.red : Colors.green,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Daily Breakdown',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildTimeDistributionList(),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildLimitsCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeDistributionList() {
//     // Sample data for demonstration
//     final categories = [
//       {
//         'name': 'Social Media',
//         'minutes': 45,
//         'icon': Icons.public,
//         'color': Colors.blue
//       },
//       {
//         'name': 'Games',
//         'minutes': 32,
//         'icon': Icons.sports_esports,
//         'color': Colors.red
//       },
//       {
//         'name': 'Education',
//         'minutes': 27,
//         'icon': Icons.school,
//         'color': Colors.green
//       },
//       {
//         'name': 'Entertainment',
//         'minutes': 18,
//         'icon': Icons.movie,
//         'color': Colors.orange
//       },
//     ];

//     return Column(
//       children: categories.map((category) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: category['color'] as Color,
//             child: Icon(category['icon'] as IconData,
//                 color: Colors.white, size: 20),
//           ),
//           title: Text(category['name'] as String),
//           trailing: Text(
//             '${category['minutes']} min',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildLimitsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Screen Time Limits',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             SwitchListTile(
//               title: const Text('Daily Limit'),
//               subtitle: const Text('2 hours per day'),
//               value: true,
//               onChanged: (value) {},
//             ),
//             SwitchListTile(
//               title: const Text('Bedtime'),
//               subtitle: const Text('No screen time after 8:00 PM'),
//               value: true,
//               onChanged: (value) {},
//             ),
//             const SizedBox(height: 10),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Show dialog to change limits
//                 },
//                 child: const Text('Adjust Limits'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeeklyAnalysis() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Weekly Overview',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     height: 200,
//                     child: _buildBarChart(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Weekly Stats',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildWeeklyStatsTiles(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBarChart() {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: 8,
//         barTouchData: BarTouchData(
//           enabled: false,
//         ),
//         // titlesData: FlTitlesData(
//         //   show: true,
//         //   bottomTitles: AxisTitles(
//         //     sideTitles: SideTitles(
//         //       showTitles: true,
//         //       textStyle: const TextStyle(
//         //           color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
//         //       margin: 8,
//         //       getTitlesWidget: (double value, TitleMeta meta) {
//         //         return Text(
//         //           _getDayOfWeek(value.toInt()),
//         //           style: meta.textStyle,
//         //         );
//         //       },
//         //     ),
//         //   ),
//         //   leftTitles: AxisTitles(
//         //     sideTitles: SideTitles(
//         //       showTitles: true,
//         //       getTextStyles: (context, value) =>
//         //           const TextStyle(color: Colors.grey, fontSize: 10),
//         //       margin: 10,
//         //       reservedSize: 30,
//         //       getTitlesWidget: (value, meta) {
//         //         if (value == 0) return Text('0h', style: meta.textStyle);
//         //         if (value == 4) return Text('4h', style: meta.textStyle);
//         //         if (value == 8) return Text('8h', style: meta.textStyle);
//         //         return const SizedBox.shrink();
//         //       },
//         //     ),
//         //   ),
//         //   topTitles: SideTitles(showTitles: false),
//         //   rightTitles: SideTitles(showTitles: false),
//         // ),
//         // borderData: FlBorderData(
//         //   show: false,
//         // ),
//         gridData: FlGridData(
//             show: true,
//             checkToShowHorizontalLine: (value) =>
//                 value == 0 || value == 4 || value == 8,
//             getDrawingHorizontalLine: (value) {
//               return FlLine(
//                 color: Colors.grey.withOpacity(0.3),
//                 strokeWidth: 1,
//               );
//             }),
//         barGroups: screenTimeHours.asMap().entries.map((entry) {
//           final int index = entry.key;
//           final int value = entry.value;

//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               // BarChartRodData(
//               //   fromY: value.toDouble(),
//               //   color: [value > 4 ? Colors.red : Colors.blue],
//               //   width: 22,
//               //   borderRadius: const BorderRadius.only(
//               //     topLeft: Radius.circular(6),
//               //     topRight: Radius.circular(6),
//               //   ),
//               // )
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildWeeklyStatsTiles() {
//     // Calculate weekly stats from screen time hours
//     final totalHours =
//         screenTimeHours.fold<int>(0, (sum, hours) => sum + hours);
//     final averageHours = totalHours / screenTimeHours.length;
//     final maxDay = screenTimeHours
//         .asMap()
//         .entries
//         .reduce((a, b) => a.value > b.value ? a : b);

//     return Column(
//       children: [
//         ListTile(
//           leading: const CircleAvatar(
//             backgroundColor: Colors.blue,
//             child: Icon(Icons.access_time, color: Colors.white),
//           ),
//           title: const Text('Total Screen Time'),
//           trailing: Text(
//             '$totalHours hours',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         ListTile(
//           leading: const CircleAvatar(
//             backgroundColor: Colors.green,
//             child: Icon(Icons.calculate, color: Colors.white),
//           ),
//           title: const Text('Daily Average'),
//           trailing: Text(
//             '${averageHours.toStringAsFixed(1)} hours',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         ListTile(
//           leading: const CircleAvatar(
//             backgroundColor: Colors.orange,
//             child: Icon(Icons.arrow_upward, color: Colors.white),
//           ),
//           title: const Text('Highest Usage'),
//           subtitle: Text(_getDayOfWeek(maxDay.key)),
//           trailing: Text(
//             '${maxDay.value} hours',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
// }
