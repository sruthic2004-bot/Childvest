// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:hive/hive.dart';
// import '../models/browsing_history.dart';

// class ChildBrowser extends StatefulWidget {
//   final String childId; // Unique ID for the child user

//   ChildBrowser({required this.childId});

//   @override
//   _ChildBrowserState createState() => _ChildBrowserState();
// }

// class _ChildBrowserState extends State<ChildBrowser> {
//   late final WebViewController _controller;
//   Box<BrowsingHistory> historyBox = Hive.box<BrowsingHistory>('browsing_history');
//   DateTime? startTime;

//   @override
//   void initState() {
//     super.initState();

//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onPageStarted: (url) {
//           startTime = DateTime.now();
//         },
//         onPageFinished: (url) async {
//           if (startTime != null) {
//             int timeSpent = DateTime.now().difference(startTime!).inSeconds;
//             saveBrowsingHistory(url, timeSpent);
//           }
//         },
//       ))
//       ..loadRequest(Uri.parse("https://www.google.com"));
//   }

//   void saveBrowsingHistory(String url, int timeSpent) async {
//     final title = await _controller.getTitle() ?? "Unknown Page";
//     final history = BrowsingHistory.create(
//       childId: widget.childId,
//       url: url,
//       title: title,
//     );
//     history.updateTimeSpent(timeSpent);
//     historyBox.add(history);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Safe Browser")),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
