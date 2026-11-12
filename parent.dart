// import 'package:chidvest/models/browsing_history.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// class ParentHomeScreen extends StatefulWidget {
//   final String childId;

//   ParentHomeScreen({required this.childId});

//   @override
//   _ParentHomeScreenState createState() => _ParentHomeScreenState();
// }

// class _ParentHomeScreenState extends State<ParentHomeScreen> {
//   int _selectedIndex = 0;

//   late List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       BlockedWebsitesScreen(), // Tab 1: Add Blocked URLs
//       BrowsingHistoryScreen(childId: widget.childId), // Tab 2: View History
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.block), label: "Block URL"),
//           BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }


// class BlockedWebsite {
//   String url;
//   BlockedWebsite({required this.url});
// }

// class BlockedWebsitesScreen extends StatefulWidget {
//   @override
//   _BlockedWebsitesScreenState createState() => _BlockedWebsitesScreenState();
// }

// class _BlockedWebsitesScreenState extends State<BlockedWebsitesScreen> {
//   final TextEditingController _urlController = TextEditingController();
//   final Box blockedBox = Hive.box('blocked_websites');

//   void _addBlockedWebsite() {
//     String url = _urlController.text.trim();
//     if (url.isNotEmpty) {
//       blockedBox.add(url);
//       _urlController.clear();
//       setState(() {});
//     }
//   }

//   void _removeBlockedWebsite(int index) {
//     blockedBox.deleteAt(index);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Block Websites")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _urlController,
//               decoration: InputDecoration(
//                 labelText: "Enter URL to Block",
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: _addBlockedWebsite,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: blockedBox.length,
//               itemBuilder: (context, index) {
//                 String url = blockedBox.getAt(index);
//                 return ListTile(
//                   title: Text(url),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete),
//                     onPressed: () => _removeBlockedWebsite(index),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class BrowsingHistoryScreen extends StatelessWidget {
//   final String childId;

//   BrowsingHistoryScreen({required this.childId});

//   @override
//   Widget build(BuildContext context) {
//     Box<BrowsingHistory> historyBox = Hive.box<BrowsingHistory>('browsing_history');
//     List<BrowsingHistory> history = historyBox.values.where((h) => h.childId == childId).toList();

//     return Scaffold(
//       appBar: AppBar(title: Text("Browsing History")),
//       body: ListView.builder(
//         itemCount: history.length,
//         itemBuilder: (context, index) {
//           BrowsingHistory entry = history[index];
//           return ListTile(
//             title: Text(entry.title),
//             subtitle: Text(entry.timestamp.toLocal().toString().split('.')[0]),
//           );
//         },
//       ),
//     );
//   }
// }
