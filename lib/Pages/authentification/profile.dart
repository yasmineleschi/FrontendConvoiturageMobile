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

  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
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

          // Check if _userData!['image'] is a String (image path)
          if (_userData!['image'] is String) {
            // Load image from path and assign it to _image
            _image = File(_userData!['image']);
          } else {
            // If it's not a String, assume it's already a File and assign it directly
            _image = _userData!['image'];
          }
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
                backgroundImage: AssetImage('assets/images/car.png'),
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
              imageField(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text(
                  'Update Profile',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009C77), // Set button color
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
  Widget imageField() {
    return InkWell(
      onTap: pickImage,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50),
        ),
        child: _image == null
            ? IconButton(
          icon: Icon(
            Icons.image,
            color: Colors.black,
          ),
          onPressed: pickImage,
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(

            'http://192.168.1.14:5000/uploads/${_userData!['image']}',

            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
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
          fillColor: Colors.white, // Set the background color to white
        ),
      ),
    );
  }
}
