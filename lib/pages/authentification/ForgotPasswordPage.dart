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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetCode,
              child: const Text('Send Reset Code'),
            ),
          ],
        ),
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
        // Navigate to the ResetPasswordPage if the reset code is sent successfully
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: email),
          ),
        );
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
}

class ResetPasswordPage extends StatelessWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _resetCodeController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();

    // Method to reset password
    Future<void> _resetPassword() async {
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
                    Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the reset code sent to $email:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _resetCodeController,
              decoration: const InputDecoration(
                labelText: 'Reset Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
