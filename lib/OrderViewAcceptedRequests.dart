import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/OrderRemoveAcceptedRequest.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';


import 'auth_service.dart'; // Make sure this import is correct

class Order {
  final String requestId;
  final String userName; // Add userName property
  final String userPhone; // Add userPhone property
  final String pickUpLocation;
  final String dropOffLocation;
  final String timeStampOnCreation;
  final String endTripTime;
  final String timeStampOnAcceptance;
  final String startTripTime;
  final String rideType;
  final int cost;
  Order({
    required this.requestId,
    required this.userName,
    required this.userPhone,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.timeStampOnCreation,
    required this.endTripTime,
    required this.timeStampOnAcceptance,
    required this.startTripTime,
    required this.rideType,
    required this.cost,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      requestId: json['request_Id'] ?? '',
      cost: json['cost'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      pickUpLocation: json['pick_Up_Location'] ?? '',
      dropOffLocation: json['drop_Off_Location'] ?? '',
      timeStampOnCreation: json['time_Stamp_On_Creation'] != null
          ? DateTime.parse(json['time_Stamp_On_Creation']).toString()
          : '',
      startTripTime: json['start_Trip_Time'] != null
          ? DateTime.parse(json['start_Trip_Time']).toString()
          : '',
      rideType: json['ride_Type'] ?? '',
      endTripTime: json['end_Trip_Time'] != null
          ? DateTime.parse(json['end_Trip_Time']).toString()
          : '',
      timeStampOnAcceptance: json['time_Stamp_On_Acceptance'] != null
          ? DateTime.parse(json['time_Stamp_On_Acceptance']).toString()
          : '',

    );
  }
}



class OrderDriverViewAcceptedRequests extends StatefulWidget {
  const OrderDriverViewAcceptedRequests({Key? key}) : super(key: key);

  @override
  _OrderDriverViewAcceptedRequestsState createState() => _OrderDriverViewAcceptedRequestsState();


}

class _OrderDriverViewAcceptedRequestsState extends State<OrderDriverViewAcceptedRequests> {
  late List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _requestPhonePermission();
    fetchOrders(); // Initially fetch orders
  }
  Future<void> _requestPhonePermission() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      // Permission is granted
      print("Phone permission is granted");
    } else {
      // Permission is not granted
      print("Phone permission is not granted");
    }
  }


  Future<void> fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String? token = await AuthService.getAccessToken();

      if (token != null) {
        var headers = {
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        };
        String? baseUrl = await AuthService.getURL(); // Retrieve base URL from AuthService

        final url = '$baseUrl/api/Driver/ViewMyAcceptedRequests/1';

        final response = await http.get(
          Uri.parse(url),
          headers: headers,
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> responseData = json.decode(response.body);
          List<Order> apiOrders = responseData.map((data) => Order.fromJson(data)).toList();

          setState(() {
            _orders = apiOrders;
            _isLoading = false;
          });
        } else {
          // Log error if API call fails
          print('Failed to fetch orders. Status code: ${response.statusCode}');
          // Fallback to dummy data if API call fails
          _loadDummyOrders();
        }
      } else {
        // Log error if token is null
        print('Token is null');
        // Fallback to dummy data if token is null
        _loadDummyOrders();
      }
    } catch (e) {
      // Log error if exception occurs
      print('Exception during API call: $e');
      // Fallback to dummy data if exception occurs
      _loadDummyOrders();
    }
  }

  void _loadDummyOrders() {
    // Simulate API call by creating a list of dummy data
    List<Order> dummyOrders = [
      Order(
        requestId: '1',
        userName:"yassa",
        userPhone:"1234",
        endTripTime: '2022-04-10 10:00:00',
        timeStampOnAcceptance: '2022-04-10 10:00:00',
        pickUpLocation: 'Location A',
        dropOffLocation: 'Location B',
        timeStampOnCreation: '2022-04-10 10:00:00',
        startTripTime: '2022-04-10 10:00:00',
        rideType: 'Normal',
        cost: 50,
      ),
      Order(
        requestId: '2',
        userName:"yassa",
        userPhone:"1234",
        pickUpLocation: 'Location C',
        dropOffLocation: 'Location D',
        endTripTime: '',
        timeStampOnAcceptance: '2022-04-10 10:00:00',
        timeStampOnCreation: '2022-04-11 12:00:00',
        startTripTime: '',
        rideType: 'Premium',
        cost: 50,
      ),
      // Add more dummy orders as needed
    ];

    // Set the dummy data to the state variable
    setState(() {
      _orders = dummyOrders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : _errorMessage.isNotEmpty
            ? Center(
          child: Text(_errorMessage),
        )
            : _orders.isNotEmpty
            ? ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            return OrderTile(
              order: _orders[index],
              refreshOrders: fetchOrders, // Pass the fetchOrders function
            );
          },
        )
            : Center(
          child: Text('No orders found'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchOrders,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;
  final Function refreshOrders;

  const OrderTile({
    required this.order,
    required this.refreshOrders,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showOrderDetails(context, order),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo('Request ID:', order.requestId),
              _buildOrderInfo('User Name:', order.userName),
              _buildOrderInfo('User Phone:', order.userPhone),//TODO in phone
              MapLocationWidget(
                locationLabel: 'Pick Up Location:',
                location: order.pickUpLocation,
              ),
              MapLocationWidget(
                locationLabel: 'Drop Off Location:',
                location: order.dropOffLocation,
              ),
              _buildOrderInfo('Time Stamp On Creation:', order.timeStampOnCreation),
              _buildOrderInfo('Ride Type:', order.rideType),
              _buildStatusInfo2(order),
              _buildOrderInfo3('Cost', order.cost, "EPG"),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildOrderInfo3(String title, int value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4), // Add a SizedBox for spacing
          Row(
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 4), // Add a SizedBox for spacing
              Text(
                unit,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPhoneInfo(BuildContext context, String title, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () => _launchPhoneCall(context, phoneNumber),
            child: Text(
              phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusInfo2(Order order) {
    String status = '';

   if (order.timeStampOnCreation.isNotEmpty &&
        order.startTripTime.isNotEmpty) {
      status = 'It Started';
    } else if (order.timeStampOnAcceptance.isNotEmpty) {
      status = 'Had Accepted';
    }

    Color statusColor = _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 4), // Add a SizedBox for spacing
        Text(
          status,
          style: TextStyle(
            fontSize: 16,
            color: statusColor, // Change the color here
          ),
        ),
      ],
    );
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'It Started':
        return Colors.deepOrange;
      case 'In Progress':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  void _showOrderDetails(BuildContext context, Order order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('requestId', order.requestId);
    prefs.setString('startTripTime', order.startTripTime);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RemoveAcceptedRequest(order: order)),
    ).then((result) {
      if (result == true) {
        refreshOrders();
      }
    });
  }

  void _launchPhoneCall(BuildContext context, String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }
}

class MapLocationWidget extends StatelessWidget {
  final String locationLabel;
  final String location;

  const MapLocationWidget({
    Key? key,
    required this.locationLabel,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchMapUrl(location);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$locationLabel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4), // Add a SizedBox for spacing
          Text(
            '$location',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _launchMapUrl(String location) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$location';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }
}
