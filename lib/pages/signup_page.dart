import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
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

  late Map<String, dynamic> jwt_decoder_token;
  int? id;

  TextEditingController u = TextEditingController();
  TextEditingController p = TextEditingController();
  TextEditingController e = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return
          Scaffold(
          backgroundColor: Color(0xFFD9D9D9),
          body: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: ProgressHUD(
              inAsyncCall: isAPIcallProcess,
              opacity: 0.3,
              key: UniqueKey(),
              child: Form(
                key: gfk,
                child: _SIGNUPUI(context),
              ),
            ),

        )
    );
  }

  Widget _SIGNUPUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/car.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "REGISTARTION",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          usernamefield(),
          emailfield(),
          passwordfield(),
          Container(
              margin: const EdgeInsets.only(top: 20),
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (validateandsave()) {

                    await signup(username!, password!, email!, context);

                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF009C77)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.white)
                        )
                    )
                ),
                child: const Text(
                  "SIGN UP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              )
          ),

          const SizedBox(
            height: 10,
          ),
          Container(
            child:const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Text(" You Already Have An Account ?", style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,),
                ),
                Text(" LogIn", style: TextStyle(
                  color: Color(0xFF009C77),
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
                ),
              ]
            ),
          )
        ],
      ),
    );
  }

  Widget usernamefield() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow:const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ]),
      height: 60,
      child: TextFormField(
        controller: u,
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.person,
              color:  Colors.black,
            ),
            hintText: 'Username',
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
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ]),
      height: 60,
      child: TextFormField(
        controller: e,
        decoration: const  InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            prefixIcon: Icon(
              Icons.email_outlined,
              color:  Colors.black,
            ),
            hintText: 'Email',
            hintStyle: TextStyle(color: Colors.black38)),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return "  Email can\'t be empty!";
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
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ]),
      height: 60,
      child: TextFormField(
        controller: p,
        obscureText: hidepassword,
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 14),
            prefixIcon: const Icon(
              Icons.password_outlined,
              color: Colors.black,
            ),
            hintText: 'Password',
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





Future<void> signup(String username, String password, String email, BuildContext context) async {
  const url = 'http://192.168.1.15:5000/api/users/register';

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
