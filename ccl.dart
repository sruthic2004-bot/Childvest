// // Main structure for a Flutter-based parent-child web monitoring application

// // ===================== SHARED MODELS =====================

// // lib/models/user.dart
// class User {
//   final String id;
//   final String username;
//   final String password; // Would be hashed in production
//   final UserRole role;
//   final String? parentId; // Null for parent users

//   User({
//     required this.id,
//     required this.username,
//     required this.password,
//     required this.role,
//     this.parentId,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       password: json['password'],
//       role: json['role'] == 'parent' ? UserRole.parent : UserRole.child,
//       parentId: json['parentId'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'password': password,
//       'role': role == UserRole.parent ? 'parent' : 'child',
//       'parentId': parentId,
//     };
//   }
// }

// enum UserRole { parent, child }

// // lib/models/browsing_history.dart
// class BrowsingHistory {
//   final String id;
//   final String userId;
//   final String url;
//   final String title;
//   final DateTime timestamp;

//   BrowsingHistory({
//     required this.id,
//     required this.userId,
//     required this.url,
//     required this.title,
//     required this.timestamp,
//   });

//   factory BrowsingHistory.fromJson(Map<String, dynamic> json) {
//     return BrowsingHistory(
//       id: json['id'],
//       userId: json['userId'],
//       url: json['url'],
//       title: json['title'],
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'url': url,
//       'title': title,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }
// }

// // lib/models/search_history.dart
// class SearchHistory {
//   final String id;
//   final String userId;
//   final String searchQuery;
//   final String searchEngine;
//   final DateTime timestamp;

//   SearchHistory({
//     required this.id,
//     required this.userId,
//     required this.searchQuery,
//     required this.searchEngine,
//     required this.timestamp,
//   });

//   factory SearchHistory.fromJson(Map<String, dynamic> json) {
//     return SearchHistory(
//       id: json['id'],
//       userId: json['userId'],
//       searchQuery: json['searchQuery'],
//       searchEngine: json['searchEngine'],
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'searchQuery': searchQuery,
//       'searchEngine': searchEngine,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }
// }

// // lib/models/blocked_site.dart
// class BlockedSite {
//   final String id;
//   final String parentId;
//   final String url;
//   final String reason;

//   BlockedSite({
//     required this.id,
//     required this.parentId,
//     required this.url,
//     required this.reason,
//   });

//   factory BlockedSite.fromJson(Map<String, dynamic> json) {
//     return BlockedSite(
//       id: json['id'],
//       parentId: json['parentId'],
//       url: json['url'],
//       reason: json['reason'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'parentId': parentId,
//       'url': url,
//       'reason': reason,
//     };
//   }
// }

// // ===================== API SERVICE =====================

// // lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// class ApiService {
//   final String baseUrl;
//   final String? authToken;

//   ApiService({required this.baseUrl, this.authToken});

//   // Headers for authenticated requests
//   Map<String, String> get headers {
//     Map<String, String> headers = {'Content-Type': 'application/json'};
//     if (authToken != null) {
//       headers['Authorization'] = 'Bearer $authToken';
//     }
//     return headers;
//   }

//   // Generic methods
//   Future<dynamic> get(String endpoint) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load data: ${response.statusCode}');
//     }
//   }

//   Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//       body: jsonEncode(data),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to post data: ${response.statusCode}');
//     }
//   }

//   Future<dynamic> delete(String endpoint) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: headers,
//     );

//     if (response.statusCode == 200 || response.statusCode == 204) {
//       if (response.body.isNotEmpty) {
//         return jsonDecode(response.body);
//       } else {
//         return true;
//       }
//     } else {
//       throw Exception('Failed to delete: ${response.statusCode}');
//     }
//   }

//   // Specific API calls - Parent
//   Future<List<User>> getChildren(String parentId) async {
//     final response = await get('/parent/$parentId/children');
//     return (response as List).map((json) => User.fromJson(json)).toList();
//   }

//   Future<List<BrowsingHistory>> getChildBrowsingHistory(String childId) async {
//     final response = await get('/child/$childId/history');
//     return (response as List)
//         .map((json) => BrowsingHistory.fromJson(json))
//         .toList();
//   }

//   Future<List<SearchHistory>> getChildSearchHistory(String childId) async {
//     final response = await get('/child/$childId/searches');
//     return (response as List)
//         .map((json) => SearchHistory.fromJson(json))
//         .toList();
//   }

//   Future<List<BlockedSite>> getBlockedSites(String parentId) async {
//     final response = await get('/parent/$parentId/blocked-sites');
//     return (response as List).map((json) => BlockedSite.fromJson(json)).toList();
//   }

//   Future<BlockedSite> blockSite(
//       String parentId, String url, String reason) async {
//     final response = await post('/block-site', {
//       'parentId': parentId,
//       'url': url,
//       'reason': reason,
//     });
//     return BlockedSite.fromJson(response);
//   }

//   Future<bool> unblockSite(String blockId) async {
//     return await delete('/unblock-site/$blockId');
//   }

//   // Specific API calls - Child
//   Future<bool> logBrowserActivity(
//       String userId, String url, String title) async {
//     await post('/log-activity', {
//       'userId': userId,
//       'url': url,
//       'title': title,
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//     return true;
//   }

//   Future<bool> logSearchQuery(
//       String userId, String searchQuery, String searchEngine) async {
//     await post('/log-search', {
//       'userId': userId,
//       'searchQuery': searchQuery,
//       'searchEngine': searchEngine,
//       'timestamp': DateTime.now().toIso8601String(),
//     });
//     return true;
//   }

//   Future<bool> isUrlBlocked(String userId, String url) async {
//     final response = await post('/check-blocked', {
//       'userId': userId,
//       'url': url,
//     });
//     return response['isBlocked'] == true;
//   }
// }

// // ===================== PARENT APP =====================

// // lib/parent/main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'parent_dashboard.dart';
// import '../services/auth_service.dart';
// import '../services/api_service.dart';

// void main() {
//   runApp(ParentApp());
// }

// class ParentApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         Provider<ApiService>(
//           create: (_) => ApiService(
//             baseUrl: 'https://your-api-server.com/api',
//             // In a real app, this would come from secure storage
//             authToken: 'sample-auth-token',
//           ),
//         ),
//         Provider<AuthService>(
//           create: (context) => AuthService(
//             apiService: Provider.of<ApiService>(context, listen: false),
//           ),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Parent Monitor',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           visualDensity: VisualDensity.adaptivePlatformDensity,
//         ),
//         home: ParentDashboard(),
//       ),
//     );
//   }
// }

// // lib/parent/parent_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../models/user.dart';
// import 'browsing_history_screen.dart';
// import 'search_history_screen.dart';
// import 'blocked_sites_screen.dart';
// import 'settings_screen.dart';

// class ParentDashboard extends StatefulWidget {
//   @override
//   _ParentDashboardState createState() => _ParentDashboardState();
// }

// class _ParentDashboardState extends State<ParentDashboard> {
//   int _selectedIndex = 0;
//   List<User> _children = [];
//   String? _selectedChildId;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadChildren();
//   }

//   Future<void> _loadChildren() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       // In a real app, parent ID would come from authentication
//       final String parentId = 'parent123';
//       final children = await apiService.getChildren(parentId);
      
//       setState(() {
//         _children = children;
//         if (children.isNotEmpty && _selectedChildId == null) {
//           _selectedChildId = children[0].id;
//         }
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load children: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Parent Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _loadChildren,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 if (_children.isEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           'No children accounts found. Add a child account in settings.',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Select Child',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedChildId,
//                       items: _children.map((User child) {
//                         return DropdownMenuItem<String>(
//                           value: child.id,
//                           child: Text(child.username),
//                         );
//                       }).toList(),
//                       onChanged: (String? value) {
//                         setState(() {
//                           _selectedChildId = value;
//                         });
//                       },
//                     ),
//                   ),
//                 Expanded(
//                   child: _selectedChildId == null
//                       ? Center(child: Text('Select a child to view data'))
//                       : IndexedStack(
//                           index: _selectedIndex,
//                           children: [
//                             BrowsingHistoryScreen(childId: _selectedChildId!),
//                             SearchHistoryScreen(childId: _selectedChildId!),
//                             BlockedSitesScreen(),
//                             SettingsScreen(),
//                           ],
//                         ),
//                 ),
//               ],
//             ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'Browsing',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Searches',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.block),
//             label: 'Blocked',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

// // lib/parent/browsing_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../models/browsing_history.dart';
// import 'package:intl/intl.dart';

// class BrowsingHistoryScreen extends StatefulWidget {
//   final String childId;

//   BrowsingHistoryScreen({required this.childId});

//   @override
//   _BrowsingHistoryScreenState createState() => _BrowsingHistoryScreenState();
// }

// class _BrowsingHistoryScreenState extends State<BrowsingHistoryScreen> {
//   List<BrowsingHistory> _history = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadBrowsingHistory();
//   }

//   @override
//   void didUpdateWidget(BrowsingHistoryScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.childId != oldWidget.childId) {
//       _loadBrowsingHistory();
//     }
//   }

//   Future<void> _loadBrowsingHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       final history = await apiService.getChildBrowsingHistory(widget.childId);
      
//       setState(() {
//         _history = history;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load browsing history: $e')),
//       );
//     }
//   }

//   Future<void> _blockSite(String url) async {
//     final reason = await _showBlockDialog();
//     if (reason != null) {
//       try {
//         final apiService = Provider.of<ApiService>(context, listen: false);
//         // In a real app, parent ID would come from authentication
//         final String parentId = 'parent123';
//         await apiService.blockSite(parentId, url, reason);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Site blocked successfully')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to block site: $e')),
//         );
//       }
//     }
//   }

//   Future<String?> _showBlockDialog() async {
//     final TextEditingController controller = TextEditingController();
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Block Site'),
//         content: TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             labelText: 'Reason for blocking',
//             hintText: 'e.g., Inappropriate content',
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(controller.text),
//             child: Text('Block'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _loadBrowsingHistory,
//       child: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _history.isEmpty
//               ? Center(
//                   child: Text('No browsing history yet'),
//                 )
//               : ListView.builder(
//                   itemCount: _history.length,
//                   itemBuilder: (context, index) {
//                     final item = _history[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: ListTile(
//                         title: Text(item.title.isNotEmpty 
//                           ? item.title 
//                           : item.url),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(item.url, 
//                               maxLines: 1, 
//                               overflow: TextOverflow.ellipsis),
//                             Text(DateFormat('MMM d, yyyy - h:mm a')
//                               .format(item.timestamp)),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: Icon(Icons.block, color: Colors.red),
//                           onPressed: () => _blockSite(item.url),
//                         ),
//                         isThreeLine: true,
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // lib/parent/search_history_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../models/search_history.dart';
// import 'package:intl/intl.dart';

// class SearchHistoryScreen extends StatefulWidget {
//   final String childId;

//   SearchHistoryScreen({required this.childId});

//   @override
//   _SearchHistoryScreenState createState() => _SearchHistoryScreenState();
// }

// class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
//   List<SearchHistory> _searches = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadSearchHistory();
//   }

//   @override
//   void didUpdateWidget(SearchHistoryScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.childId != oldWidget.childId) {
//       _loadSearchHistory();
//     }
//   }

//   Future<void> _loadSearchHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       final searches = await apiService.getChildSearchHistory(widget.childId);
      
//       setState(() {
//         _searches = searches;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load search history: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _loadSearchHistory,
//       child: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _searches.isEmpty
//               ? Center(
//                   child: Text('No search history yet'),
//                 )
//               : ListView.builder(
//                   itemCount: _searches.length,
//                   itemBuilder: (context, index) {
//                     final item = _searches[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: ListTile(
//                         title: Text(item.searchQuery),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Search Engine: ${item.searchEngine}"),
//                             Text(DateFormat('MMM d, yyyy - h:mm a')
//                               .format(item.timestamp)),
//                           ],
//                         ),
//                         isThreeLine: true,
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // lib/parent/blocked_sites_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../services/api_service.dart';
// import '../models/blocked_site.dart';

// class BlockedSitesScreen extends StatefulWidget {
//   @override
//   _BlockedSitesScreenState createState() => _BlockedSitesScreenState();
// }

// class _BlockedSitesScreenState extends State<BlockedSitesScreen> {
//   List<BlockedSite> _blockedSites = [];
//   bool _isLoading = true;
//   final _urlController = TextEditingController();
//   final _reasonController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadBlockedSites();
//   }

//   @override
//   void dispose() {
//     _urlController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBlockedSites() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       // In a real app, parent ID would come from authentication
//       final String parentId = 'parent123';
//       final blockedSites = await apiService.getBlockedSites(parentId);
      
//       setState(() {
//         _blockedSites = blockedSites;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load blocked sites: $e')),
//       );
//     }
//   }

//   Future<void> _unblockSite(BlockedSite site) async {
//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       await apiService.unblockSite(site.id);
      
//       setState(() {
//         _blockedSites.removeWhere((s) => s.id == site.id);
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Site unblocked successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to unblock site: $e')),
//       );
//     }
//   }

//   Future<void> _blockNewSite() async {
//     if (_urlController.text.isEmpty || _reasonController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }

//     try {
//       final apiService = Provider.of<ApiService>(context, listen: false);
//       // In a real app, parent ID would come from authentication
//       final String parentId = 'parent123';
//       final newSite = await apiService.blockSite(
//         parentId,
//         _urlController.text,
//         _reasonController.text,
//       );
      
//       setState(() {
//         _blockedSites.add(newSite);
//         _urlController.clear();
//         _reasonController.clear();
//       });
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Site blocked successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to block site: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _loadBlockedSites,
//         child: _isLoading
//             ? Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Block new site form
//                     Card(
//                       child: Padding(
//                         padding: EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Text(
//                               'Block New Website',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             TextFormField(
//                               controller: _urlController,
//                               decoration: InputDecoration(
//                                 labelText: 'Website URL',
//                                 hintText: 'e.g., example.com',
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             TextFormField(
//                               controller: _reasonController,
//                               decoration: InputDecoration(
//                                 labelText: 'Reason for blocking',
//                                 hintText: 'e.g., Inappropriate content',
//                                 border: OutlineInputBorder(),
//                               ),
//                             ),
//                             SizedBox(height: 16),
//                             ElevatedButton(
//                               onPressed: _blockNewSite,
//                               child: Text('Block Website'),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 24),
//                     Text(
//                       'Currently Blocked Websites',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     _blockedSites.isEmpty
//                         ? Card(
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Center(
//                                 child: Text('No blocked websites yet'),
//                               ),
//                             ),
//                           )
//                         : ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: _blockedSites.length,
//                             itemBuilder: (context, index) {
//                               final site = _blockedSites[index];
//                               return Card(
//                                 margin: EdgeInsets.only(bottom: 8),
//                                 child: ListTile(
//                                   title: Text(site.url),
//                                   subtitle: Text(site.reason),
//                                   trailing: IconButton(
//                                     icon: Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () => _unblockSite(site),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

// // lib/parent/settings_screen.dart
// import 'package:flutter/material.dart';

// class SettingsScreen extends StatefulWidget {
//   @override
//   _SettingsScreenState createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _emailNotifications = true;
//   bool _alertSearchTerms = true;
//   bool _dailyReports = false;
//   double _weekdayLimit = 2.0;
//   double _weekendLimit = 4.0;

//   void _saveSettings() {
//     // In a real app, this would call the API to save settings
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Settings saved successfully')),
//     );
//   }

//   void _saveLimits() {
//     // In a real app, this would call the API to save time limits
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Time limits saved successfully')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Notification Settings',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SwitchListTile(
//                     title: Text('Email notifications for suspicious activity'),
//                     value: _emailNotifications,
//                     onChanged: (value) {
//                       setState(() {
//                         _emailNotifications = value;
//                       });
//                     },
//                   ),
//                   SwitchListTile(
//                     title: Text('Alert me about concerning search terms'),
//                     value: _alertSearchTerms,
//                     onChanged: (value) {
//                       setState(() {
//                         _alertSearchTerms = value;
//                       });
//                     },
//                   ),
//                   SwitchListTile(
//                     title: Text('Send daily activity reports'),
//                     value: _dailyReports,
//                     onChanged: (value) {
//                       setState(() {
//                         _dailyReports = value;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 16),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: _saveSettings,
//                       child: Text('Save Settings'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 16),
//           Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Time Limits',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),)])))}