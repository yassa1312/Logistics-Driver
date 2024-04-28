import 'package:flutter/material.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OrderViewAcceptedRequests.dart';



class RemoveAcceptedRequest extends StatelessWidget {
  final Order order;

  const RemoveAcceptedRequest({required this.order, Key? key}) : super(key: key);

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
                    _buildOrderInfo('Request ID:', order.requestId),
                    _buildOrderInfo('Pick Up Location:', order.pickUpLocation),
                    _buildOrderInfo('Drop Off Location:', order.dropOffLocation),
                    _buildOrderInfo('Time Stamp On Creation:', order.timeStampOnCreation),
                    _buildOrderInfo('Ride Type:', order.rideType),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _StartOrder(context, order);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _refuseOrder(context, order);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text(
                            'Refuse',
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
                         _endOrder(context, order);
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

Future<void> _StartOrder(BuildContext context, Order order) async {
  try {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      print('Access token not found.');
      Fluttertoast.showToast(
        msg: 'Access token not found.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    String url = 'http://logistics-api-8.somee.com/api/Driver/StartTrip/${order.requestId}';

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
      // Unauthorized, token expired or invalid
      print('Unauthorized: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Unauthorized: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Handle token expiration or invalid token here, maybe redirect to login
    }  else if (order.startTripTime.isNotEmpty) {
      // Show a toast message indicating that the trip has already started
      Fluttertoast.showToast(
        msg: 'Trip has already started for order ${order.requestId}.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }else {
      // Other server errors
      print('Failed to start order: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Failed to start order ${order.requestId}: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  } catch (error) {
    print('Error starting order: $error');
    Fluttertoast.showToast(
      msg: 'Error starting order: $error',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
void _refuseOrder(BuildContext context, Order order) async {
  // Check if startTripTime is empty
  if (order.startTripTime.isNotEmpty) {
    Fluttertoast.showToast(
      msg: 'Cannot refuse order with start trip time',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return; // Return early if startTripTime is not empty
  }

  try {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      print('Access token not found.');
      return;
    }

    String url = 'http://logistics-api-8.somee.com/api/Driver/RemoveAcceptedRequest/${order.requestId}';

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
        msg: 'Order ${order.requestId} refused',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }  else {
      // Other server errors
      print('Failed to start order: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Failed to start order ${order.requestId}: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

  } catch (error) {
    print('Error refusing order: $error');
    Fluttertoast.showToast(
      msg: 'Error refusing order',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}
Future<void> _endOrder(BuildContext context, Order order) async {
  // Check if startTripTime is empty
  if (order.startTripTime.isEmpty) {
    Fluttertoast.showToast(
      msg: 'Cannot End order without start trip',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return; // Return early if startTripTime is not empty
  }

  try {
    String? token = await AuthService.getAccessToken();

    if (token == null) {
      print('Access token not found.');
      return;
    }

    String url = 'http://logistics-api-8.somee.com/api/Driver/EndTrip/${order.requestId}';

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
        msg: 'Order ${order.requestId} is Ended',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }  else {
      // Other server errors
      print('Failed to start order: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Failed to start order ${order.requestId}: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

  } catch (error) {
    print('Error refusing order: $error');
    Fluttertoast.showToast(
      msg: 'Error refusing order',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}