import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/LoginScreen.dart';
import 'package:logistics/OrderAcceptRequest.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


import 'auth_service.dart'; // Make sure this import is correct

class Order {
  final String requestId;
  final String pickUpLocation;
  final String dropOffLocation;
  final String timeStampOnCreation;
  final String rideType;
  final int cost;
  Order({
    required this.requestId,
    required this.pickUpLocation,
    required this.dropOffLocation,
    required this.timeStampOnCreation,
    required this.rideType,
    required this.cost,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      requestId: json['request_Id'] ?? '',
      cost:json['cost'] ?? '' ,
      pickUpLocation: json['pick_Up_Location'] ?? '',
      dropOffLocation: json['drop_Off_Location'] ?? '',
      timeStampOnCreation: json['time_Stamp_On_Creation'] != null
          ? DateTime.parse(json['time_Stamp_On_Creation']).toString()
          : '',
      rideType: json['ride_Type'] ?? '',
    );
  }
}

class OrderViewRequests extends StatefulWidget {
  const OrderViewRequests({Key? key}) : super(key: key);

  @override
  _OrderViewRequestsState createState() => _OrderViewRequestsState();


}

class _OrderViewRequestsState extends State<OrderViewRequests> {
  late List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Initially fetch orders
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
        String? baseUrl = await AuthService.getURL();
        final url = '$baseUrl/api/Driver/ViewRequests/1';

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
        } else if (response.statusCode == 400) {
          Fluttertoast.showToast(
              msg: "${response.body}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          // Log error if API call fails
          print('${response.reasonPhrase}');
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
        pickUpLocation: 'Location A',
        dropOffLocation: 'Location B',
        timeStampOnCreation: '2022-04-10 10:00:00',
        rideType: 'Normal',cost: 50,
      ),
      Order(
        requestId: '2',
        pickUpLocation: 'Location C',
        dropOffLocation: 'Location D',
        timeStampOnCreation: '2022-04-11 12:00:00',
        rideType: 'Average Classic Box Truck', cost: 50,
      ),
      // Add more dummy orders as needed
    ];

    // Set the dummy data to the state variable
    setState(() {
      _orders = dummyOrders;
      _isLoading = false;
    });
  }
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('The Orders', style: TextStyle(color: Colors.black)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await clearUserData(); // Call the function to clear user data
              // Navigate to the login screen or any other screen after logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // Replace LoginScreen with your actual login screen widget
              );
            },
          ),
        ],
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
  final Function refreshOrders; // Define this callback function

  const OrderTile({
    required this.order,
    required this.refreshOrders, // Pass this callback through constructor
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
              //_buildOrderInfo('Request ID:', order.requestId),
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
          SizedBox(height: 4), // Add a SizedBox for spacing
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

  void _showOrderDetails(BuildContext context, Order order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('requestId', order.requestId);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderAcceptRequest(order: order)),
    ).then((result) {
      if (result == true) {
        refreshOrders(); // Call the refreshOrders function when needed
      }
    });
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
