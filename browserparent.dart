import 'package:chidvest/models/child.dart';
import 'package:chidvest/models/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class ParentPanel extends StatefulWidget {
  final String childId;
  ParentPanel({
    super.key, required this.childId,
  });

  @override
  _ParentPanelState createState() => _ParentPanelState();
}

class _ParentPanelState extends State<ParentPanel> {
  Box<SearchHistory> searchBox = Hive.box<SearchHistory>('search_history');
  Box<BlockedWebsite> blockedBox = Hive.box<BlockedWebsite>('blocked_websites');

  TextEditingController blockController = TextEditingController();
  int _currentIndex = 0; // Track the selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parent Control Panel")),
      body: _currentIndex == 0 ? buildBlockedWebsites() : buildSearchHistory(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: "Blocked Sites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Search History",
          ),
        ],
      ),
    );
  }

  Widget buildBlockedWebsites() {
    return Column(
      children: [
        ListTile(
          title: Text("Blocked Websites"),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showBlockDialog(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: blockedBox.length,
            itemBuilder: (context, index) {
              var blocked = blockedBox.getAt(index) as BlockedWebsite;
              return ListTile(
                title: Text(truncateUrl(blocked.url)),
                // tooltip: blocked.url, // Show full URL on hover/long press
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    blockedBox.deleteAt(index);
                    setState(() {}); // Update UI after deletion
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Set<int> expandedIndexes = {}; // Stores indexes of expanded items
  Widget buildSearchHistory() {
    return Column(
      children: [
        ListTile(
          title: Text("Search History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: searchBox.length,
            itemBuilder: (context, index) {
              var history = searchBox.getAt(index) as SearchHistory;
              bool isExpanded = expandedIndexes.contains(index);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedIndexes.remove(index); 
                    } else {
                      expandedIndexes.add(index); 
                    }
                  });
                },
                onLongPress: () {
                  copyToClipboard(history.url);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isExpanded ? history.url : truncateUrl(history.url),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          history.timestamp.toString(),
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        if (isExpanded) SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String truncateUrl(String url, {int maxLength = 30}) {
    return url.length > maxLength ? "${url.substring(0, maxLength)}..." : url;
  }

  void showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Block Website"),
          content: TextField(
            controller: blockController,
            decoration: InputDecoration(hintText: "Enter website URL"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (blockController.text.isNotEmpty) {
                  blockedBox.add(BlockedWebsite(
                      url: blockController.text, timestamp: DateTime.now()));
                  blockController.clear();
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text("Block"),
            ),
          ],
        );
      },
    );
  }

  // Function to shorten long URLs
  // String truncateUrl(String url, {int maxLength = 30}) {
  //   return url.length > maxLength ? '${url.substring(0, maxLength)}...' : url;
  // }
}
