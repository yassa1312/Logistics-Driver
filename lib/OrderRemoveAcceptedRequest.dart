import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logistics/GiveReason.dart';
import 'package:logistics/ProfilePageUser.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/main.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'OrderViewAcceptedRequests.dart';

class RemoveAcceptedRequest extends StatefulWidget {
  final Order order;

  RemoveAcceptedRequest({required this.order, Key? key}) : super(key: key);

  @override
  _RemoveAcceptedRequestState createState() => _RemoveAcceptedRequestState();
}

class _RemoveAcceptedRequestState extends State<RemoveAcceptedRequest> {
  late Uint8List _imageBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    try {
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {'Authorization': 'Bearer $token'};
        String? baseUrl = await AuthService.getURL();
        var response = await http.get(
          Uri.parse('$baseUrl/api/Driver/RequestFlutter/${widget.order.requestId}'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData["load_Image"] != null) {
            setState(() {
              _imageBytes = base64Decode(responseData["load_Image"]);
            });
          } else {
            setState(() {
              _imageBytes = Uint8List(0);
            });
          }
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
        title: Text(
          'Order Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //_buildOrderInfo('Request ID:', widget.order.requestId),
                    _buildOrderInfo('Pick Up Location:', widget.order.pickUpLocation),
                    _buildOrderInfo('Drop Off Location:', widget.order.dropOffLocation),
                    _buildOrderInfo('Time Stamp On Creation:', widget.order.timeStampOnCreation),
                    _buildOrderInfo('Ride Type:', widget.order.rideType),
                    if (_imageBytes.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.orange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
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
                    SizedBox(height: 10),
                    if (_imageBytes.isEmpty) SizedBox(height: 0),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _startOrder(context, widget.order);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Text(
                                'Start',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.order.timeStampOnAcceptance.isEmpty) {
                                Fluttertoast.showToast(
                                  msg: 'Trip has not Acceptance yet.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                              else if (widget.order.startTripTime.isNotEmpty) {
                                Fluttertoast.showToast(
                                  msg: 'Trip has already started.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.blue,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GiveReason(requestId: widget.order.requestId),
                                  ),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                              elevation: MaterialStateProperty.all<double>(10),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.order.timeStampOnAcceptance.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePageUser(requestId: widget.order.requestId),
                                  ),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Trip has not been accepted yet.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                              elevation: MaterialStateProperty.all<double>(10),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Text(
                                'User Data',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _endOrder(context, widget.order);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Text(
                                'End Trip',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildOrderInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: title == 'Delivery Location'
              ? InkWell(
            onTap: () {
              _launchMap(value);
            },
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
            ),
          )
              : Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _launchMap(String location) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not launch $googleUrl';
    }
  }
}

Future<void> _startOrder(BuildContext context, Order order) async {
  try {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      Fluttertoast.showToast(
        msg: 'Access token not found.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    String? baseUrl = await AuthService.getURL();

    String url = '$baseUrl/api/Driver/StartTrip/${order.requestId}';

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };

    var response = await http.put(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Order ${order.requestId} started successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(
        msg: 'Unauthorized: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (order.startTripTime.isNotEmpty) {
      Fluttertoast.showToast(
        msg: 'Trip has already started for order ${order.requestId}.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to start order ${order.requestId}: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: 'Error starting order: $error',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

Future<void> _endOrder(BuildContext context, Order order) async {
  if (order.startTripTime.isEmpty) {
    Fluttertoast.showToast(
      msg: 'Cannot end order without starting trip',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return;
  }

  try {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      Fluttertoast.showToast(
        msg: 'Access token not found.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    String? baseUrl = await AuthService.getURL();
    String url = '$baseUrl/api/Driver/EndTrip/${order.requestId}';

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };

    var response = await http.put(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'Order ${order.requestId} ended successfully',
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
      Fluttertoast.showToast(
        msg: 'Failed to end order ${order.requestId}: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    Fluttertoast.showToast(
      msg: 'Error ending order: $error',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
