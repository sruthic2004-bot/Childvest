import 'package:chidvest/screntimr/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenTimeStats extends StatefulWidget {
  @override
  _ScreenTimeStatsState createState() => _ScreenTimeStatsState();
}

class _ScreenTimeStatsState extends State<ScreenTimeStats> {
  Map<String, int> screenTime = {};

  @override
  void initState() {
    super.initState();
    fetchScreenTime();
  }

  Future<void> fetchScreenTime() async {
    final data = await ScreenTimeService.getScreenTime();
    setState(() {
      screenTime = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen Time Stats")),
      body: screenTime.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: screenTime.entries
                  .map((entry) => ListTile(
                        title: Text(entry.key),
                        subtitle: Text("Usage: ${entry.value ~/ 60000} min"),
                      ))
                  .toList(),
            ),
    );
  }
}
