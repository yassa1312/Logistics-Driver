import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginScreen.dart';
import 'Home.dart'; // Make sure to import your Home screen widget

class AuthService {
  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> clearUserData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}

class TestImage extends StatefulWidget {
  @override
  _TestImageState createState() => _TestImageState();
}

class _TestImageState extends State<TestImage> {
  TextEditingController _imageUrlController = TextEditingController();
  late String? _accessToken;

  @override
  void initState() {
    super.initState();
    _loadAccessToken();
  }

  Future<void> _loadAccessToken() async {
    _accessToken = await AuthService.getAccessToken();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageUrlController.text = pickedImage.path;
      });
    }
  }
  Future<bool> _sendImage(BuildContext context) async {
    final url = Uri.parse('http://www.logistics-api.somee.com/api/Admin/UploadFileApi');

    // Check if access token and image URL are available
    String? token = await AuthService.getAccessToken();
    if (token == null || _imageUrlController.text.isEmpty) {
      print('Access token or image URL is missing.');
      displayToast(context, 'Access token or image URL is missing.');
      return false;
    }

    // Create a File object from the image URL
    File imageFile = File(_imageUrlController.text);

    // Check if the image file exists
    if (!imageFile.existsSync()) {
      print('Image file does not exist.');
      displayToast(context, 'Image file does not exist.');
      return false;
    }

    // Read image file as bytes
    List<int> bytes = await imageFile.readAsBytes();

    // Extract filename from image path
    String fileName = imageFile.path.split('/').last; // Extracts the last part of the path as the filename

    try {
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        url,
      );

      // Set authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file to the request
      var image = await http.MultipartFile.fromPath(
        'File', // field name expected by the server
        imageFile.path,
      );
      request.files.add(image);

      // Add filename to the request
      request.fields['FileName'] = fileName;

      // Send the request
      var response = await request.send();

      // Print entire response
      print('Response Status Code: ${response.statusCode}');

      // Check response status
      if (response.statusCode == 200) {
        print('Image sent successfully!');
        displayToast(context, 'Image sent successfully!');
        return true;
      } else {
        print('Error sending image: ${response.statusCode}');
        displayToast(context, 'Error sending image: ${response.statusCode}');
        return false;
      }
    } catch (exception) {
      print('Error sending image: $exception');
      displayToast(context, 'Error sending image');
      return false;
    }
  }


  void _logout() async {
    await AuthService.clearUserData1();
    await AuthService.clearUserData(); // Clear user data from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Image Upload', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_imageUrlController.text.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
                    color: Colors.orange,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Match the container's border radius
                    child: Image.file(
                      File(_imageUrlController.text),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_imageUrlController.text.isNotEmpty) {
                    _sendImage(context).then((success) {
                      if (success) {
                        // Handle success
                      } else {
                        // Handle failure
                      }
                    }).catchError((error) {
                      // Handle error
                    });
                  }
                },
                child: Text('Send Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void displayToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}

