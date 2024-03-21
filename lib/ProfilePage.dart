import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logistics/PasswordChange.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/auth_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();


    // Fetch data from the API
    fetchProfileData();
  }

  void editUserProfile() async {
    try {
      // Retrieve access token
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Specify content type
        };

        var request = http.Request(
            'PUT',
            Uri.parse(
                'http://www.logistics-api.somee.com/api/Account/EditMyProfile'));

        // Prepare request body
        request.headers.addAll(headers);
        request.body = jsonEncode({
          'password': 'Passw0rd', //TODO// Provide a valid password here
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
        // Get response

        if (response.statusCode == 200) {
          print('Response: $responseString');
          // Optionally, you can update UI or show a success message here
        } else {
          print('Failed to edit profile: ${response.reasonPhrase}');
          // Optionally, you can handle error response here
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

        var response = await http.get(
          Uri.parse('http://www.logistics-api.somee.com/api/Account/MyProfileDriver'),
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
            _imageUrlController.text = responseData['imageUrl'] ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _imageUrlController.text.isNotEmpty
                  ? NetworkImage(_imageUrlController.text)
                  : null,
              child: _imageUrlController.text.isEmpty
                  ? Icon(Icons.person, size: 50)
                  : null,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                editUserProfile();
              },
              child: Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordChange()),
                );
              },
              child: Text('Password Change'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
