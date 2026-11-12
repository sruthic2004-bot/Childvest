// import 'package:chidvest/screen.dart/childpage.dart';
// import 'package:chidvest/screen.dart/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:chidvest/models/child.dart';

// class ChildLoginScreen extends StatefulWidget {
//   const ChildLoginScreen({Key? key}) : super(key: key);

//   @override
//   State<ChildLoginScreen> createState() => _ChildLoginScreenState();
// }

// class _ChildLoginScreenState extends State<ChildLoginScreen> {
//   final _codeController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   String? _errorMessage;

//   // Mocked list of children for demonstration purposes
//   final List<Child> _children = [
//     Child(code: 'CH-123456', name: 'John Doe'),
//     Child(code: 'CH-654321', name: 'Jane Doe'),
//   ];

//   @override
//   void dispose() {
//     _codeController.dispose();
//     super.dispose();
//   }

//   Child? _findChildByCode(String code) {
//     return _children.firstWhere((child) => child.code == code, orElse: () => null);
//   }

//   Future<void> _login() async {
//     if (_formKey.currentState?.validate() != true) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     final code = _codeController.text.trim();

//     try {
//       // Get the child with the matching code
//       final child = _findChildByCode(code);

//       if (child != null) {
//         // Pass the child object to the KidsActivitiesPage
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => KidsActivitiesPage(child: child),
//           ),
//         );
//       } else {
//         setState(() {
//           _errorMessage = 'Invalid login code. Please try again.';
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'An error occurred. Please try again.';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Child Login')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // App logo or icon
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 40),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: Colors.blue.withOpacity(0.1),
//                         radius: 50,
//                         child: const Icon(
//                           Icons.child_care,
//                           size: 60,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'ChidVest',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Enter your unique login code',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Code input field
//                 TextFormField(
//                   controller: _codeController,
//                   decoration: InputDecoration(
//                     labelText: 'Login Code',
//                     hintText: 'Example: CH-123456',
//                     prefixIcon: const Icon(Icons.lock),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Please enter your login code';
//                     }
//                     if (!value.startsWith('CH-') || value.length < 9) {
//                       return 'Please enter a valid login code';
//                     }
//                     return null;
//                   },
//                 ),

//                 if (_errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 12),
//                     child: Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),

//                 const SizedBox(height: 30),

//                 // Login button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _login,
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text('Login', style: TextStyle(fontSize: 16)),
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Parent login option
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                   child: const Text('I am a parent'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }