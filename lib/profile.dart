import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String _error = '';

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _userData = userData;
          _usernameController.text = _userData!['username'] ?? '';
          _emailController.text = _userData!['email'] ?? '';
          _ageController.text = _userData!['age'] ?? '';
          _phoneController.text = _userData!['phone'] ?? '';
          _firstnameController.text = _userData!['firstname'] ?? '';
          _lastnameController.text = _userData!['lastname'] ?? '';
          _addressController.text = _userData!['address'] ?? '';
          _selectedStatus = _userData!['etat'];
        });
      } else {
        _setError('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user data: $e');
      _setError('An error occurred while loading user data. $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setError(String errorMessage) {
    setState(() {
      _error = errorMessage;
    });
  }

  Future<void> _updateProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/users/update/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': _usernameController.text,
          'email': _emailController.text,
          'age': _ageController.text,
          'phone': _phoneController.text,
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'address': _addressController.text,
          'etat': _selectedStatus ?? _userData!['etat'],
        }),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success'),
            content: Text('Profile updated successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while updating the profile. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error updating profile: $error');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while updating the profile. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Page'),
        backgroundColor: Color(0xFFD9D9D9),
      ),
      backgroundColor: Color(0xFFD9D9D9),
      body: SingleChildScrollView(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? Center(child: Text(_error))
            : _userData != null
            ? Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/img.png'),
                radius: 50,
              ),
              SizedBox(height: 20),
              Text(
                _userData!['username'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedStatus ?? _userData!['etat'],
                decoration: InputDecoration(
                  labelText: 'Status',

                  prefixIcon: Icon(Icons.medical_information_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white70, // Set the background color to white

                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                items: <String>['PASSENGER', 'DRIVER'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              _buildTextField('Username', _usernameController, Icons.accessibility),
              _buildTextField('Email', _emailController, Icons.email),
              _buildTextField('Age', _ageController, Icons.person),
              _buildTextField('Phone', _phoneController, Icons.phone),
              _buildTextField('First Name', _firstnameController, Icons.person),
              _buildTextField('Last Name', _lastnameController, Icons.person),
              _buildTextField('Address', _addressController, Icons.location_on),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text(
                  'Update Profile',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF009C77), // Set button color
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        )
            : Center(
          child: Text('No user data available.'),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextStyle? inputStyle, TextStyle? labelStyle}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: inputStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true, // Add this line to enable filling
          fillColor: Colors.white70, // Set the background color to white
        ),
      ),
    );
  }
}
