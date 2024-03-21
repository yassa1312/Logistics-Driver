import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics/LoginScreen.dart';
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
  final List<String> shipmentList = [
    'Normal Truck',
    'Large Truck',
    'Flatbed',
    'Refrigerated',
    'Box',
    'Tanker',
    'Dump',
    'Van Step',
  ];


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
      body: Container(
        color: Colors.orange,
        child: Column(
          children: [
            const SizedBox(height: 30,),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Image.asset(
                  'assets/Picture2.png', // Replace 'assets/Picture1.png' with your actual PNG file path
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
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
      parsedCapacity = int.parse(capacity);
    } catch (e) {
      displayToast("Capacity must be a number");
      return;
    }

    // Check if capacity is 0
    if (parsedCapacity == 0) {
      displayToast("Capacity cannot be 0");
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
          "capacity": capacity
        };

        // Send registration request
        var response = await http.post(
          Uri.parse('http://www.logistics-api.somee.com/api/Account/RegisterCar'),
          headers: headers,
          body: json.encode(data),
        );

        // Print the response here to view it
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          displayToast("Car registered successfully!");
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

  static Future<bool> registerCar(String caR_VIN,String plateNum, String rideType, String color, String carModel, int capacity) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var data = {
      "caR_VIN": caR_VIN,
      "plateNum": plateNum,
      "rideType": rideType,
      "color": color,
      "carModel": carModel,
      "capacity": capacity
    };

    try {
      var response = await http.post(
        Uri.parse('http://www.logistics-api.somee.com/api/Car/Register'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return true; // Successful registration
      } else {
        print(response.body);
        return false; // Unsuccessful registration
      }
    } catch (error) {
      print('Error during registration: $error');
      return false; // Error during registration
    }
  }


  Future<void> saveUserData(String userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', userData);
  }
}