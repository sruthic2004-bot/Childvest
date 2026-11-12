import 'dart:io';
import 'package:chidvest/provider/children_provider.dart';
import 'package:chidvest/screen.dart/add_child_screen.dart';
import 'package:chidvest/parent/child_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Parental Control'),
      ),
      // Apply the same gradient as UserTypeSelectionScreen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade50],
          ),
        ),
        child: Consumer<ChildrenProvider>(
          builder: (ctx, childrenProvider, _) {
            final children = childrenProvider.children;

            if (children.isEmpty) {
              return const Center(
                child: Text(
                  'No child added yet. Tap the + button to add a child.',
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
              );
            }

            // Since we're only allowing one child, we'll always use the first child
            final child = children[0];
            return Center(
              child: Card(
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildDetailsScreen(
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: child.profileImagePath.isNotEmpty
                              ? FileImage(File(child.profileImagePath))
                              : null,
                          child: child.profileImagePath.isEmpty
                              ? Text(
                                  child.name[0],
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          child.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${child.age} years old',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.touch_app,
                                size: 20,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tap to view details',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Consumer<ChildrenProvider>(
        builder: (ctx, childrenProvider, _) {
          // Only show the add button if no child has been added yet
          return childrenProvider.children.isEmpty
              ? FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddChildScreen()),
                    );
                  },
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}