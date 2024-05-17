import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:logistics/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class RegisterCar extends StatefulWidget {
  const RegisterCar({Key? key}) : super(key: key);
  @override
  State<RegisterCar> createState() => _RegisterCarState();
}
class _RegisterCarState extends State<RegisterCar> {
  final TextEditingController caR_VINController = TextEditingController();
  final TextEditingController plateNumController = TextEditingController();
  final TextEditingController rideTypeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  late Uint8List _imageBytes1 = Uint8List(0);
  late Uint8List _imageBytes2 = Uint8List(0);
  late Uint8List _imageBytes3 = Uint8List(0);
  String base64String1 = '';
  String base64String2 = '';
  String base64String3 = '';
  final List<String> shipmentList = [
    'Average Classic Box Truck',
    'Large Truck',
    'Motor Tri-cycle',
    'Pickup Truck',
    'Refrigerated Truck',
    'Platform Truck',
    'Half-ton Classic Truck',
  ];
  void ImagetoBase64(File imageFile, int imageIndex) async {
    Uint8List bytes = await imageFile.readAsBytes();
    String base64String = base64Encode(bytes);
    setState(() {
      if (imageIndex == 1) {
        base64String1 = base64String;
        _imageBytes1 = bytes;
      } else if (imageIndex == 2) {
        base64String2 = base64String;
        _imageBytes2 = bytes;
      } else if (imageIndex == 3) {
        base64String3 = base64String;
        _imageBytes3 = bytes;
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _imageBytes1 = Uint8List(0);
    _imageBytes2 = Uint8List(0);
    _imageBytes3 = Uint8List(0);
  }
  @override
  void dispose() {
    super.dispose();
    caR_VINController.dispose();
    plateNumController.dispose();
    rideTypeController.dispose();
    colorController.dispose();
    carModelController.dispose();
    capacityController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Register Car', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Pop the current screen
          },
        ),
      ),
      body: Container(
        color: Colors.orange,
        child: Column(
          children: [
            Expanded(
              child:
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        // Container 1
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Add an Image of your Car :',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              if (_imageBytes1.isNotEmpty) // Check if image bytes are not empty
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
                                      _imageBytes1,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (_imageBytes1.isEmpty) // Display message if no image selected
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
                                        ImagetoBase64(File(pickedImage.path), 1);
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
                                        ImagetoBase64(File(pickedImage.path), 1);
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
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Add an Image Id and License Front:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              if (_imageBytes2.isNotEmpty) // Check if image bytes are not empty
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
                                      _imageBytes2,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (_imageBytes2.isEmpty) // Display message if no image selected
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
                                        ImagetoBase64(File(pickedImage.path), 2);
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
                                        ImagetoBase64(File(pickedImage.path), 2);
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
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Add an Image of Id and License Back:',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              if (_imageBytes3.isNotEmpty) // Check if image bytes are not empty
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
                                      _imageBytes3,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (_imageBytes3.isEmpty) // Display message if no image selected
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
                                        ImagetoBase64(File(pickedImage.path), 3);
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
                                        ImagetoBase64(File(pickedImage.path), 2);
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
                      ],
                    ),


                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select your Truck'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: shipmentList.map((location) {
                                    return ListTile(
                                      title: Text(location),
                                      onTap: () {
                                        setState(() {
                                          rideTypeController.text = location;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                rideTypeController.text.isEmpty ? 'Select Truck' : rideTypeController.text,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      controller: caR_VINController,
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
                      controller: plateNumController,
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
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            controller: colorController,
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
                            controller: carModelController,
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
                            controller: capacityController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number, // Set keyboardType to accept numbers only
                            decoration: InputDecoration(
                              labelText: 'Capacity in Ton',
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
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ), backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                          onRegisterSuccess();
                        },
                        child: const Text(
                          "RegisterCar",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void onRegisterSuccess() async {
    String caR_VIN = caR_VINController.text;
    String plateNum = plateNumController.text;
    String rideType = rideTypeController.text;
    String color = colorController.text;
    String carModel = carModelController.text;
    String capacity = capacityController.text; // Convert to string

    // Check if any required field is empty
    if (caR_VIN.isEmpty || plateNum.isEmpty || rideType.isEmpty || color.isEmpty || carModel.isEmpty || capacity.isEmpty) {
      displayToast("Please fill in all fields");
      return;
    }

    // Attempt to parse capacity to int
    int? parsedCapacity;
    try {
      parsedCapacity = int.parse(capacityController.text);
    } catch (e) {
      displayToast("Capacity must be 1, 2, 4, 8, or 10 tons only");
      return;
    }

    if (![1, 2, 4, 8, 10].contains(parsedCapacity)) {
      displayToast("Capacity must be 1, 2, 4, 8, or 10 tons only");
      return;
    }


    // Attempt API registration
    try {
      // Retrieve access token
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        // Set up headers with token
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        };

        // Prepare data for registration
        var data = {
          "caR_VIN": caR_VIN,
          "Plate_Num": plateNum,
          "Ride_Type": rideType,
          "color": color,
          "Car_Model": carModel,
          "capacity": capacity,
          "carImage": "$base64String1",
          "idIamge_1": "$base64String2",
          "idIamge_2": "$base64String3"
        };
        String? baseUrl = await AuthService.getURL();
        // Send registration request
        var response = await http.post(
          Uri.parse('$baseUrl/api/Account/RegisterCar'),
          headers: headers,
          body: json.encode(data),
        );

        // Print the response here to view it
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          displayToast("Car registered successfully!");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          // You can add navigation or any other action here upon successful registration
        } else {
          displayToast("Car registration failed. Please try again.");
        }
      } else {
        displayToast('Access token is null.');
      }
    } catch (error) {
      displayToast("Error during registration: $error");
    }
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


  Future<void> saveUserData(String userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', userData);
  }
}