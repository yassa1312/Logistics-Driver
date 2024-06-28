import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/LoginScreen.dart';
import 'package:logistics/auth_service.dart';


import 'dart:convert';

import 'package:logistics/main.dart';

class ConfirmEmail extends StatefulWidget {
  @override
  _ConfirmEmailState createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Email',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  code = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Confirmation Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                confirmEmail(code);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                textStyle: TextStyle(fontSize: 20), // Increase the font size
              ),
              child: Text('Confirm Email'),
            ),

          ],
        ),
      ),
    );
  }

  void confirmEmail(String code) async {
    var url = Uri.parse(
        'http://logistics-api-8.somee.com/api/Account/ConfirmEmail/$code');
    String? token = await AuthService.getAccessToken();
    try {
      var response = await http.post(
        url,
        headers: {
          "accept": "*/*",
          "Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print('Email confirmed successfully');
        print("${response.reasonPhrase}");
        // Perform actions upon successful confirmation, such as navigating to another screen or showing a toast
        Fluttertoast.showToast(
          msg: "Email confirmed successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print('Email confirmed Failed');
        print("${response.reasonPhrase}");
        // Perform actions upon failure, such as showing an error message or retrying
        Fluttertoast.showToast(
          msg: "Email confirmed Failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error: $e');
      // Handle any errors that occur during the API call
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}