import 'package:chidvest/delete/gptne.dart';
import 'package:chidvest/parent/browserparent.dart';
import 'package:chidvest/parent/loc_screen.dart';
import 'package:chidvest/delete/screentime55.dart';
import 'package:chidvest/parent/usagescreen.dart';
import 'package:chidvest/parent/usagescreen.dart' as usage_screen;
import 'package:chidvest/provider/children_provider.dart';
import 'package:chidvest/screen.dart/screen_time_screen.dart';
import 'package:chidvest/screntimr/screentimesss.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/child.dart';

class ChildDetailsScreen extends StatelessWidget {
  final Child child;

  const ChildDetailsScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditChildDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: child.profileImagePath.isNotEmpty
                  ? FileImage(File(child.profileImagePath))
                  : null,
              child: child.profileImagePath.isEmpty
                  ? Text(
                      child.name[0],
                      style: const TextStyle(fontSize: 36),
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              child.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${child.age} years old',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // _buildOverviewCard(context),
            const SizedBox(height: 20),
            _buildMenuOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        _buildOptionTile(
          context,
          Icons.timer,
          'Screen Time',
          'Monitor daily usage',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        _buildOptionTile(
          context,
          Icons.apps,
          'App Usage',
          'Track app activity',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsageStatsScreen(),
              ),
            );
          },
        ),
        _buildOptionTile(
          context,
          Icons.web,
          'Web History',
          'Monitor browsing activity',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ParentPanel(
                        childId: '',
                      )),
            );
          },
        ),
        _buildOptionTile(
          context,
          Icons.location_on,
          'Location Tracking',
          'View location history',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationTrackingScreen(
                  childId: child.id,
                  childName: child.name,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEditChildDialog(BuildContext context) {
    final nameController = TextEditingController(text: child.name);
    final ageController = TextEditingController(text: child.age.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Child'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final childrenProvider =
                  Provider.of<ChildrenProvider>(context, listen: false);

              child.name = nameController.text.trim();
              child.age = int.tryParse(ageController.text.trim()) ?? child.age;

              childrenProvider.updateChild(child);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Child'),
        content: Text(
          'Are you sure you want to delete ${child.name}\'s profile? This will delete all monitoring data and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final childrenProvider =
                  Provider.of<ChildrenProvider>(context, listen: false);

              childrenProvider.deleteChild(child);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Go back to home screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
