import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Color(0xFFD9D9D9),
      ),
      body: Container(
        color: Color(0xFFD9D9D9),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/img.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 40,
                      ),
                    ),
                  ],
                ),
              ),
              _buildEmailField(),
              const SizedBox(height: 10),
              _buildPasswordField(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      const Text('Remember me !'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Action to be performed when the "Forgot Password" button is pressed
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLoginButton(),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Text('You Don’t Have An Account ? '),
                  TextButton(
                    onPressed: () {
                     //add routs
                    },
                    child: const Text(
                      'SignUp',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF009C77),
                      ),
                    ),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email',
        prefixIcon: Icon(Icons.person), // Add icon for email
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock), // Add icon for password
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passwordController.clear();
            });
          },
          icon: const Icon(Icons.clear),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 7) {
          return 'Password must be at least 7 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: const Color(0xFF009C77),
      ),
      onPressed: _isLoading ? null : _login,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_validateInputs()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final url = Uri.parse('http://10.0.2.2:5000/api/users/login');
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        };
        final body = jsonEncode({'email': email, 'password': password});

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final token = responseData['accessToken'];
          final userId = responseData['user']['id']; // Extract user ID

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);
          prefs.setString('userId', userId); // Store user ID

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Connecté avec succès!'),
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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          final errorMessage = json.decode(response.body)['error'];
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('An error occurred')));
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return false;
    }

    if (_passwordController.text.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 7 characters')));
      return false;
    }

    return true;
  }
}
