import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/auth_service.dart';
import 'dart:convert';

import 'package:logistics/main.dart';


class GiveReason extends StatefulWidget {
  final String requestId;

  GiveReason({required this.requestId});

  @override
  _GiveReasonState createState() => _GiveReasonState();
}

class _GiveReasonState extends State<GiveReason> {
  String comment = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Give reason',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Request Id', widget.requestId),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  comment = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await endTrip(widget.requestId, comment);
              },
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 20), // Increase the font size
              ),
              child: Text('Cancel Trip'),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
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

  Future<void> endTrip(String requestId, String comment) async {
    try {
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        String url = 'http://logistics-api-8.somee.com/api/Driver/CancelRequest';

        // Define request body
        Map<String, dynamic> requestBody = {
          'request_Id': widget.requestId,
          'comment': comment,
        };

        // Encode request body to JSON
        String body = json.encode(requestBody);

        // Define headers
        Map<String, String> headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': '*/*',
        };

        // Make PUT request
        var response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: body,
        );

        // Handle response
        if (response.statusCode == 200) {
          print('Trip Cancel successfully');
          Fluttertoast.showToast(
            msg: "Trip Cancel successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
          // Handle success as needed
        } else {
          print('Failed to end trip: ${response.body}');
          print('Failed to end trip: ${response.statusCode}');
          Fluttertoast.showToast(
            msg: "Failed to end trip: ${response.statusCode}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Handle failure as needed
        }
      } else {
        print('Access token is null.');
      }
    } catch (error) {
      print("Error ending trip: $error");
      Fluttertoast.showToast(
        msg: "Error ending trip: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Handle error as needed
    }
  }
}
