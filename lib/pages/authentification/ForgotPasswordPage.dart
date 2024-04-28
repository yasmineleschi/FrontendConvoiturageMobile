import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _showResetFields = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/back.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                SizedBox(height: 30),
                Image.asset(
                  'assets/images/car.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(), // Add border
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF009C77), // Text color
                  ),
                  onPressed: _sendResetCode,
                  child: const Text('Send Reset Code'),
                ),
                if (_showResetFields) ...[
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _resetCodeController,
                    decoration: InputDecoration(
                      labelText: 'Reset Code',
                      border: OutlineInputBorder(), // Add border
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(), // Add border
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF009C77), // Text color
                    ),
                    onPressed: _resetPassword,
                    child: const Text('Reset Password'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to send reset code
  Future<void> _sendResetCode() async {
    final email = _emailController.text;

    try {
      final url = Uri.parse('http://localhost:5000/api/users/forgot-password');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final body = jsonEncode({'email': email});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Reset code sent successfully
        setState(() {
          _showResetFields = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset code sent successfully')));
      } else if (response.statusCode == 404) {
        // User not found
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('User not found'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  // Method to reset password
  Future<void> _resetPassword() async {
    final email = _emailController.text;
    final resetCode = _resetCodeController.text;
    final newPassword = _newPasswordController.text;

    try {
      final url = Uri.parse('http://localhost:5000/api/users/reset-password');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final body = jsonEncode({'email': email, 'resetCode': resetCode, 'newPassword': newPassword});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Password reset successfully'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst); // Navigate back to the first route (usually login)
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 400) {
        // Invalid email or reset code
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid email or reset code'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Other errors
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }
}
