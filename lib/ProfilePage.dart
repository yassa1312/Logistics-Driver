import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logistics/PasswordChange.dart';
import 'package:logistics/auth_service.dart';
import 'LoginScreen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _caR_VINController = TextEditingController();
  final TextEditingController _plateNumController = TextEditingController();
  final TextEditingController _rideTypeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  @override
  void initState() {
    super.initState();
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
          'password': _passwordController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
          // Add other fields as needed
        });

        // Send the request
        http.StreamedResponse response = await request.send();
        String responseString = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: "Profile updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
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

        var response = await http.get(
          Uri.parse('http://logistics-api-8.somee.com/api/Account/MyProfileDriver'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          // Decode and handle the response
          Map<String, dynamic> responseData = jsonDecode(response.body);

          setState(() {
            // Assign fetched data to controllers
            _nameController.text = responseData['name'] ?? '';
            _emailController.text = responseData['email'] ?? '';
            _phoneNumberController.text = responseData['phoneNumber'] ?? '';

            // Access and assign car-related data if available
            if (responseData.containsKey('car')) {
              Map<String, dynamic> carData = responseData['car'];
              _caR_VINController.text = carData['caR_VIN'] ?? '';
              _plateNumController.text = carData['plate_Num'] ?? '';
              _rideTypeController.text = carData['ride_Type'] ?? '';
              _colorController.text = carData['color'] ?? '';
              _carModelController.text = carData['car_Model'] ?? '';
              _capacityController.text = carData['capacity']?.toString() ?? '';
            }
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

  Future<bool> _sendImage(BuildContext context) async {
    final url = Uri.parse('http://logistics-api-8.somee.com/api/Admin/UploadFileApi');

    // Check if access token and image URL are available
    String? token = await AuthService.getAccessToken();
    if (token == null || _imageUrlController.text.isEmpty) {
      print('Access token or image URL is missing.');
      displayToast('Access token or image URL is missing.');
      return false;
    }

    // Create a File object from the image URL
    File imageFile = File(_imageUrlController.text);

    // Check if the image file exists
    if (!imageFile.existsSync()) {
      print('Image file does not exist.');
      displayToast('Image file does not exist.');
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
        displayToast( 'Image sent successfully!');
        return true;
      } else {
        print('Error sending image: ${response.statusCode}');
        displayToast('Error sending image: ${response.statusCode}');
        return false;
      }
    } catch (exception) {
      print('Error sending image: $exception');
      displayToast( 'Error sending image');
      return false;
    }
  }


  void _showProfileUpdateDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

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

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageUrlController.text = pickedImage.path;
      });
    }
  }

  Future<List<int>> fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Widget imageFromBytes(BuildContext context, List<int> bytes) {
    return Image.memory(
      Uint8List.fromList(bytes),
      fit: BoxFit.cover,
    );
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
              SizedBox(height: 10),
              TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                controller: _plateNumController,
                decoration: const InputDecoration(
                  labelText: 'Plate Num',
                  prefixIcon: Icon(Icons.confirmation_num_outlined,color: Colors.orange,),
                  labelStyle: TextStyle(
                    color: Colors.orange,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                controller: _caR_VINController,
                decoration: const InputDecoration(
                  labelText: 'CAR_VIN',
                  prefixIcon: Icon(Icons.numbers,color: Colors.orange,),
                  labelStyle: TextStyle(
                    color: Colors.orange,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                controller: _rideTypeController,
                decoration: const InputDecoration(
                  labelText: 'Ride_Type',
                  prefixIcon: Icon(Icons.numbers,color: Colors.orange,),
                  labelStyle: TextStyle(
                    color: Colors.orange,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _colorController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Color',
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.color_lens,color: Colors.orange,),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _carModelController,
                      textInputAction: TextInputAction.next,
                      onChanged: (password) {
                      },
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.directions_car,color: Colors.orange,),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _capacityController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number, // Set keyboardType to accept numbers only
                      decoration: InputDecoration(
                        labelText: 'Capacity',
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.front_loader,color: Colors.orange,),
                      ),
                    ),

                  ],
                ),
              ),
              SizedBox(height: 20),
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
      ),
    );
  }
}
