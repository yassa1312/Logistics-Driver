import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'OrderViewRequests.dart';
import 'auth_service.dart';


class OrderAcceptRequest extends StatefulWidget {
  final Order order;

  OrderAcceptRequest({required this.order, Key? key}) : super(key: key);

  @override
  _OrderAcceptRequestState createState() => _OrderAcceptRequestState();
}

class _OrderAcceptRequestState extends State<OrderAcceptRequest> {
  late Uint8List _imageBytes = Uint8List(0);
  String base64String = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
    _imageBytes = Uint8List(0);
  }

  void fetchProfileData() async {
    try {
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {
          'Authorization': 'Bearer $token',
        };
        String? baseUrl = await AuthService.getURL();
        var response = await http.get(
          Uri.parse('$baseUrl/api/Driver/RequestFlutter/${widget.order.requestId}'),
          headers: headers,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = jsonDecode(response.body);
          print(responseData);
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
                    _buildDetailItem('Order Id', widget.order.requestId),
                    _buildDetailItem('Pick Up Location', widget.order.pickUpLocation),
                    _buildDetailItem('Drop Off Location', widget.order.dropOffLocation),
                    _buildDetailItem('Time Stamp On Creation', widget.order.timeStampOnCreation),
                    _buildDetailItem('Ride Type', widget.order.rideType),
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
                    if (_imageBytes.isEmpty)
                      SizedBox(height: 0),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _acceptOrder(context, widget.order); // Pass widget.order here
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
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
      String? baseUrl = await AuthService.getURL();
      String url = '$baseUrl/api/Driver/AcceptRequest/$requestId';

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
          msg: 'Order ${widget.order.requestId} Accepted',
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
          msg: 'Failed to accept order ${widget.order.requestId}',
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


