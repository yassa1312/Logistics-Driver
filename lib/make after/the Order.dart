import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/make%20after/OrderDetailsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logistics App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const OrdersPage(),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late List<Order> _orders = []; // Initialize _orders with an empty list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Simulating API call delay
    await Future.delayed(Duration(seconds: 1));

    // Mock data
    List<Order> mockOrders = [
      Order(
        id: '1',
        productName: 'Product A',
        customerName: 'John Doe',
        deliveryLocation: '123 Main St',
        status: 'Pending',
        specialInstructions: 'Handle with care',
      ),
      Order(
        id: '2',
        productName: 'Product B',
        customerName: 'Jane Smith',
        deliveryLocation: '456 Elm St',
        status: 'Completed',
        specialInstructions: '',
      ),
      Order(
        id: '3',
        productName: 'Product C',
        customerName: 'John Doe',
        deliveryLocation: '123 Main St',
        status: 'In Progress',
        specialInstructions: 'Handle with care',
      ),
      Order(
        id: '4',
        productName: 'Product D',
        customerName: 'John Doe',
        deliveryLocation: '123 Main St',
        status: 'Cancelled',
        specialInstructions: 'Handle with care',
      ),
    ];

    setState(() {
      _orders = mockOrders;
      _isLoading = false;
    });

    // Uncomment this to fetch data from an API
    // _fetchOrdersFromAPI();
  }

  Future<void> _fetchOrdersFromAPI() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/orders'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _orders = data.map((orderJson) => Order.fromJson(orderJson)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching orders: $e');
      // You can show a snackbar or dialog to inform the user about the error
    }
  }

  Future<void> _refreshOrders() async {
    // If there's API data available, refresh from API
    if (_isLoading == false) {
      await _fetchOrdersFromAPI();
    } else {
      // Fallback to refreshing mock data
      await _fetchOrders();
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _refreshOrders,
        child: _orders != null && _orders.isNotEmpty
            ? ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (context, index) {
            return OrderTile(order: _orders[index]);
          },
        )
            : const Center(
          child: Text('No orders found'),
        ),
      ),
    );
  }
}

class Order {
  final String id;
  final String productName;
  final String customerName;
  final String deliveryLocation;
  final String status;
  final String specialInstructions;

  Order({
    required this.id,
    required this.productName,
    required this.customerName,
    required this.deliveryLocation,
    required this.status,
    required this.specialInstructions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productName: json['productName'],
      customerName: json['customerName'],
      deliveryLocation: json['deliveryLocation'],
      status: json['status'],
      specialInstructions: json['specialInstructions'],
    );
  }
}

class OrderTile extends StatelessWidget {
  final Order order;

  const OrderTile({
    required this.order,
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
              Text(
                'Order ID: ${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Product: ${order.productName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Status: ${order.status}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer: ${order.customerName}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(order: order),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
