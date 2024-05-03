import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/PasswordChange.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/main.dart';
import 'LoginScreen.dart';

class ProfilePageUser extends StatefulWidget {
  final String? requestId; // Add this line

  ProfilePageUser({Key? key, this.requestId}) : super(key: key); // Add this constructor

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePageUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _imageBytes;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }
  // Declare a variable to store the image data as bytes


  void editUserProfile() async {
    try {
      // Retrieve access token
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Specify content type
        };
        String? baseUrl = await AuthService.getURL();
        var request = http.Request(
            'PUT',
            Uri.parse(
                '$baseUrl/api/Account/EditMyProfile'));

        // Prepare request body
        request.headers.addAll(headers);
        request.body = jsonEncode({
          'password': _passwordController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
          // Add other fields as needed
        });

        // Print request body for debugging
        print('Request Body: ${request.body}');

        // Send the request
        http.StreamedResponse response = await request.send();
        String responseString = await response.stream.bytesToString();

        print('Response Status Code: ${response.statusCode}');
        print('Response Reason Phrase: ${response.reasonPhrase}');
        print('Response Body: $responseString');

        if (response.statusCode == 200) {
          print('Response: $responseString');
          Fluttertoast.showToast(
            msg: "Profile updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          print('Failed to edit profile: ${response.reasonPhrase}');
          Fluttertoast.showToast(
            msg: "Failed to update profile: ${response.reasonPhrase}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        print('Access token is null.');
      }
    } catch (error) {
      print("Error editing profile: $error");
    }
  }

  void fetchProfileData() async {
    try {
      // Retrieve access token
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {
          'Authorization': 'Bearer $token',
        };
        String? baseUrl = await AuthService.getURL();
        var response = await http.get(
          Uri.parse('$baseUrl/api/Driver/UserProfile/${widget.requestId}'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          // Decode and handle the response
          Map<String, dynamic> responseData = jsonDecode(response.body);
          // Do something with responseData
          print(responseData);

          setState(() {
            // Example: Assign fetched data to controllers
            _nameController.text = responseData['name'] ?? '';
            _emailController.text = responseData['email'] ?? '';
            _phoneNumberController.text = responseData['phoneNumber'] ?? '';
            setState(() {
              if (responseData["profile_Image"] != null) {
                _imageBytes = base64Decode(responseData["profile_Image"]);
              } else {
                _imageBytes = null;
              }
            });

          });
        } else {
          print('Failed to fetch profile data: ${response.reasonPhrase}');
        }
      } else {
        print('Access token is null.');
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }
  void _showProfileUpdateDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController(); // Controller for the password field

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to update your profile?',
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Hide the entered text
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                String password = _passwordController.text;
                if (password.isEmpty) {
                  // Display toast indicating that password is required
                  displayToast('Password is required');
                } else {
                  // Proceed with updating the profile
                  editUserProfile();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                textStyle: TextStyle(color: Colors.white),
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void displayToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageBytes == null)
                SizedBox(height: 0),
              if (_imageBytes != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.account_box, color: Colors.orange),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.orange),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.orange),
                  labelStyle: TextStyle(color: Colors.orange),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.orange),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
