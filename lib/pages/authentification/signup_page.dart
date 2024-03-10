import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isAPIcallProcess = false;
  bool hidepassword = true;
  GlobalKey<FormState> gfk = GlobalKey<FormState>();
  String? username;
  String? password;
  String? email;

  int? id;

  TextEditingController u = TextEditingController();
  TextEditingController p = TextEditingController();
  TextEditingController e = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
            SingleChildScrollView(
              child: Form(
                key: gfk,
                child: _SIGNUPUI(context),

            ),
            ),
          ],
        ),

    );
  }


  Widget _SIGNUPUI(BuildContext context) {
    return     Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/car.png",
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "REGISTRATION",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          usernamefield(),
          const SizedBox(height: 10),
          emailfield(),
          const SizedBox(height: 10),
          passwordfield(),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 50,
            width: 250,
            child: ElevatedButton(
              onPressed: () async {
                if (validateandsave()) {
                  await signup(username!, password!, email!, context);
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Color(0xFFECEAEA)),
                  ),
                ),
              ),
              child: const Text(
                "SIGN UP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "You Already Have An Account?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'LogIn',
                  style: TextStyle(
                    color: Color(0xFF009C77),
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }

  Widget usernamefield() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: u,
        decoration:  InputDecoration(
            border: const OutlineInputBorder(  ),
            labelText: 'Username',
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),
            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),

            suffixIcon: IconButton(
               onPressed: () {
             setState(() {
               u.clear();
               });
               },
               icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.person,
              color: Colors.black,
            ),

            hintStyle: TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Username can\'t be empty!";
          }
          return null;
        },
        onSaved: (val) {
          username = val;
        },
      ),
    );
  }

  Widget emailfield() {
    return Container(

      child: TextFormField(
        controller: e,
        decoration:  InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),

            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  e.clear();
                });
              },
              icon: const Icon(Icons.clear),),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.black,
            ),
           labelText: "Email",

            hintStyle: TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Email can\'t be empty!";
          } if (value == null || value.isEmpty || !value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
        onSaved: (val) {
          email = val;
        },
      ),
    );
  }

  Widget passwordfield() {
    return Container(
      child: TextFormField(
        controller: p,
        obscureText: hidepassword,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide( color :Color(0xFF009C77)),
            ),

            floatingLabelStyle: const TextStyle(color:Color(0xFF009C77)),
            prefixIcon: const Icon(
              Icons.lock,
              color: Colors.black,
            ),
            labelText: 'Password',
            hintStyle: const TextStyle(color: Colors.black38),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  hidepassword = !hidepassword;
                });
              },
              color: Colors.black.withOpacity(0.7),
              icon:
                  Icon(hidepassword ? Icons.visibility_off : Icons.visibility),
            )),
        validator: (value) {
          if (value!.isEmpty) {
            return "  Password can\'t be empty!";
          }
    if (value == null || value.isEmpty || value.length < 7 || !RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must be at least 7 characters long \n and include at least one uppercase letter.';
    }
    return null;
    },

        onSaved: (val) {
          password = val;
        },
      ),
    );
  }

  bool validateandsave() {
    final form = gfk.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}

Future<void> signup(String username, String password, String email,
    BuildContext context) async {
  const url = 'http://localhost:5000/api/users/register';

  Map<String, String> body = {
    'username': username,
    'password': password,
    'email': email,
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      final jsonResponse = jsonDecode(response.body);
      print("User registered: $jsonResponse");
      // Using AwesomeDialog for success message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Registration Successful',
        desc: 'Welcome, $username! Your account has been successfully created.',
        btnOkOnPress: () {},
      )..show();
    } else {
      // Error
      final errorResponse = jsonDecode(response.body);
      print("Error: $errorResponse");
      // Using AwesomeDialog for error message
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Error',
        desc: 'Error: ${errorResponse['message']}',
        btnOkOnPress: () {},
      )..show();
    }
  } catch (e) {
    print("Error: $e");
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Error',
      desc: 'An error occurred during registration.',
      btnOkOnPress: () {},
    )..show();
  }
}
