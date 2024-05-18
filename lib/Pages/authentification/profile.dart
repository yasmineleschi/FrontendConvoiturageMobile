import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String _error = '';
  File? _image;
  bool _isEditing = false;
  String? _imagePath;

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

        Uri.parse('http://192.168.1.14:5000/api/users/profile/$userId'),

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
          _imagePath = _userData!['image'];
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

      final request = http.MultipartRequest(
        'PUT',

        Uri.parse('http://192.168.1.14:5000/api/users/update/$userId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';

      request.fields.addAll({
        'username': _usernameController.text,
        'email': _emailController.text,
        'age': _ageController.text,
        'phone': _phoneController.text,
        'firstname': _firstnameController.text,
        'lastname': _lastnameController.text,
        'address': _addressController.text,
        'etat': _selectedStatus ?? _userData!['etat'],
      });

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      final response = await http.Client().send(request);

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
        title: Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _userData != null
              ? Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : _imagePath != null
                          ? NetworkImage('http://192.168.240.204:5000/uploads/$_imagePath')
                          : AssetImage('assets/images/car.png') as ImageProvider,
                      radius: 50,
                      child: _isEditing
                          ? IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () async {
                          final pickedFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _image = File(pickedFile.path);
                            });
                          }
                        },
                      )
                          : null,
                    ),
                    SizedBox(height: 20),
                    _isEditing
                        ? DropdownButtonFormField<String>(
                      value: _selectedStatus ?? _userData!['etat'],
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.medical_information_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      },
                      items: <String>['PASSENGER', 'DRIVER']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                        : _buildInfoRow(Icons.medical_information_outlined, _userData!['etat']),
                    SizedBox(height: 20),
                    _isEditing
                        ? _buildTextField('Username', _usernameController, Icons.accessibility)
                        : _buildInfoRow(Icons.accessibility, _userData!['username'] ?? ''),
                    _isEditing
                        ? _buildTextField('Email', _emailController, Icons.email)
                        : _buildInfoRow(Icons.email, _userData!['email'] ?? ''),
                    _isEditing
                        ? _buildTextField('Age', _ageController, Icons.person)
                        : _buildInfoRow(Icons.person, _userData!['age'] ?? ''),
                    _isEditing
                        ? _buildTextField('Phone', _phoneController, Icons.phone)
                        : _buildInfoRow(Icons.phone, _userData!['phone'] ?? ''),
                    _isEditing
                        ? _buildTextField('First Name', _firstnameController, Icons.text_fields)
                        : _buildInfoRow(Icons.text_fields, _userData!['firstname'] ?? ''),
                    _isEditing
                        ? _buildTextField('Last Name', _lastnameController, Icons.text_fields)
                        : _buildInfoRow(Icons.text_fields, _userData!['lastname'] ?? ''),
                    _isEditing
                        ? _buildTextField('Address', _addressController, Icons.home)
                        : _buildInfoRow(Icons.home, _userData!['address'] ?? ''),
                    if (_isEditing)
                      SizedBox(height: 20),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text('Update Profile'),
                      ),
                  ],
                ),
              ),
            ),
          )
              : Center(child: Text('No user data available')),

        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
