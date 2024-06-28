import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logistics/OrderViewRequests.dart';
import 'package:logistics/PasswordChange.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/confirmPage.dart';
import 'package:logistics/main.dart';
import 'LoginScreen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _caR_VINController = TextEditingController();
  final TextEditingController _plateNumController = TextEditingController();
  final TextEditingController _rideTypeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  late Uint8List _imageBytes = Uint8List(0);
  Uint8List? _carImageBytes;
  Uint8List? _idImage1Bytes;
  Uint8List? _idImage2Bytes;
  String base64String = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    _imageBytes = Uint8List(0);
  }
  void ImagetoBase64(File imageFile) async {
    Uint8List bytes = await imageFile.readAsBytes();
    String base64String = base64Encode(bytes);
    setState(() {
      this.base64String = base64String;
      _imageBytes = bytes;
    });
  }
  void fetchProfileData() async {
    try {
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {'Authorization': 'Bearer $token'};
        String? baseUrl = await AuthService.getURL();
        var response = await http.get(
          Uri.parse('$baseUrl/api/Account/MyProfileDriver'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);

          setState(() {
            _nameController.text = responseData['name'] ?? '';
            _emailController.text = responseData['email'] ?? '';
            _phoneNumberController.text = responseData['phoneNumber'] ?? '';
            setState(() {
              if (responseData["profile_Image"] != null) {
                _imageBytes = base64Decode(responseData["profile_Image"]);
              } else {
                _imageBytes.isEmpty;
              }
            });;


            if (responseData.containsKey('car')) {
              Map<String, dynamic> carData = responseData['car'];
              _caR_VINController.text = carData['caR_VIN'] ?? '';
              _plateNumController.text = carData['plate_Num'] ?? '';
              _rideTypeController.text = carData['ride_Type'] ?? '';
              _colorController.text = carData['color'] ?? '';
              _carModelController.text = carData['car_Model'] ?? '';
              _capacityController.text = carData['capacity']?.toString() ?? '';

              _rateController.text = carData['driver_Rating']?.toString() ?? '';

              if (carData["carImage"] != null) {
                _carImageBytes = base64Decode(carData["carImage"]);
              }

              if (carData["idIamge_1"] != null) {
                _idImage1Bytes = base64Decode(carData["idIamge_1"]);
              }

              if (carData["idIamge_2"] != null) {
                _idImage2Bytes = base64Decode(carData["idIamge_2"]);
              }
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
                foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                textStyle: TextStyle(fontSize: 18),
              ),
              child: const Text('Yes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                textStyle: TextStyle(fontSize: 18),
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
        Map<String, dynamic> requestBody = {
          'password': _passwordController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneNumberController.text,
        };

        // Add profile image only if base64String is not empty
        if (base64String.isNotEmpty) {
          requestBody['profile_Image'] = "$base64String";
        }

        request.body = jsonEncode(requestBody);
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
  Future<Map<String, dynamic>> confirmEmailCode() async {
    String url = "http://logistics-api-8.somee.com/api/Account/ConfirmEmailCode";
    String? token = await AuthService.getAccessToken();
    if (token == null) {
      // Handle case when token is not available
      return {
        'statusCode': -1,
        'error': 'Access token is null',
      };
    }
    Map<String, String> headers = {
      "accept": "*/*",
      "Authorization": "Bearer $token",
    };


    final response = await http.post(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      // Successful request
      print("${response.reasonPhrase}");
      Fluttertoast.showToast(
        msg: "An email with code has been sent to your email to confirmed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmEmail()),
      );
      return {
        'statusCode': response.statusCode,
        'data': jsonDecode(response.body),
      };
    } else {
      // Request failed
      print("${response.reasonPhrase}");
      Fluttertoast.showToast(
        msg: "Your email is already confirmed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return {
        'statusCode': response.statusCode,
        'error': response.body,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Driver Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      'Add an Image',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_imageBytes.isNotEmpty) // Check if image bytes are not empty
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.orange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            _imageBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (_imageBytes.isEmpty) // Display message if no image selected
                      Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedImage = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              ImagetoBase64(File(pickedImage.path));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Gallery'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedImage = await picker.pickImage(source: ImageSource.camera);
                            if (pickedImage != null) {
                              ImagetoBase64(File(pickedImage.path));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Camera'),
                        ),
                      ],
                    ),
                  ],
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
                maxLength: 11,
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
                  _showProfileUpdateDialog(context);
                },

                child: Text('Edit'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordChange()),
                  );
                },
                child: Text('Password Change'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  confirmEmailCode();
                },

                child: Text('Confirm Email'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.orange, // Text color
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              if (_carImageBytes==null) // Display message if no image selected
              SizedBox(height: 0),
              if (_carImageBytes != null)
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _carImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              if (_idImage1Bytes != null)
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _idImage1Bytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              if (_idImage2Bytes != null)
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.orange,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _idImage2Bytes!,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                  prefixIcon: Icon(Icons.local_shipping,color: Colors.orange,),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _rateController,
                      textInputAction: TextInputAction.next,
                     keyboardType: TextInputType.number, // Set keyboardType to accept numbers only
                      decoration: InputDecoration(
                        labelText: 'Driver Rate',
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.star_rate,color: Colors.orange,),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
