import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List<Order> orders = [];

  // Function to fetch orders from API
  Future<void> fetchOrders() async {
    try {
      Response response = await Dio().get('YOUR_API_ENDPOINT_HERE');
      List<Order> fetchedOrders = (response.data as List)
          .map((json) => Order.fromJson(json))
          .toList();
      setState(() {
        orders = fetchedOrders;
      });
    } catch (e) {
      // Handle error
      print('Error fetching orders: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Activity', style: TextStyle(color: Colors.black)),
      ),
      body: orders.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order.productName),
            subtitle: Text('Order ID: ${order.id}'),
            trailing: Text(order.date),
            onTap: () {
              // Add functionality to view order details
            },
          );
        },
      ),
    );
  }
}

class Order {
  final int id;
  final String productName;
  final String date;

  Order({
    required this.id,
    required this.productName,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productName: json['productName'],
      date: json['date'],
    );
  }
}
