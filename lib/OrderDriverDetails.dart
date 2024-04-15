import 'package:flutter/material.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/main.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'OrderDriver.dart';

class OrderDriverDetails extends StatelessWidget {
  final Order order;

  const OrderDriverDetails({required this.order, Key? key}) : super(key: key);

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
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _acceptOrder(context, order);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Text(
                            'Accept',
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



  void _acceptOrder(BuildContext context, Order order) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? requestId = prefs.getString('requestId');
      String? token = await AuthService.getAccessToken();

      if (requestId == null) {
        print('Request ID not found in shared preferences.');
        return;
      }

      String url = 'http://www.logistics-api.somee.com/api/Driver/AcceptRequest/$requestId';

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
          msg: 'Order ${order.requestId} Accepted',
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
          msg: 'Failed to accept order ${order.requestId}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (error) {
      print('Error accepting order: $error');
      Fluttertoast.showToast(
        msg: 'Error accepting order',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


  }

  void _launchMap(String location) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not launch $googleUrl';
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

    String url = 'http://www.logistics-api.somee.com/api/Trip/Start/${order.requestId}';

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
      print('Unauthorized: ${response.body}');
      Fluttertoast.showToast(
        msg: 'Unauthorized: ${response.statusCode}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // Handle token expiration or invalid token here, maybe redirect to login
    } else {
      // Other server errors
      print('Failed to start order: ${response.statusCode}');
      print('Failed to start order: ${response.body}');
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
