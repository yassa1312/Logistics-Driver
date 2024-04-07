import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List<Order> orders = [];
  bool isLoading = false; // Track whether data is being fetched

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders when the widget initializes
  }

  // Function to fetch orders
  Future<void> fetchOrders() async {
    // Show the loading indicator
    setState(() {
      isLoading = true;
    });

    // Simulate a delay to show the loading indicator
    await Future.delayed(Duration(seconds: 1));

    // Sample list of orders (for demonstration)
    List<Order> sampleOrders = [
      Order(
        id: 1,
        productName: 'Product 1',
        date: '2024-04-07',
        comment: 'Great product!',
        rating: 5,
      ),
      Order(
        id: 2,
        productName: 'Product 2',
        date: '2024-04-06',
        comment: 'Could be better',
        rating: 3,
      ),
    ];

    // Set the orders from the list
    setState(() {
      orders = sampleOrders;
    });

    // Fetch orders from the API in the background
    fetchOrdersFromAPI();
  }

  // Function to fetch orders from API
  Future<void> fetchOrdersFromAPI() async {
    try {
      // Make HTTP GET request to your API
      var response = await http.get(Uri.parse('YOUR_API_ENDPOINT_HERE'));

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        var jsonData = json.decode(response.body);

        // Clear previous orders
        orders.clear();

        // Extract order data from JSON and add to the orders list
        for (var item in jsonData) {
          orders.add(Order(
            id: item['id'],
            productName: item['productName'],
            date: item['date'],
            comment: item['comment'],
            rating: item['rating'],
          ));
        }
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      // Handle error
      print('Error fetching orders from API: $e');
    } finally {
      // Hide the loading indicator
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Activity',
          style: TextStyle(color: Colors.black, fontSize: 24.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(), // Show loading indicator
        )
            : orders.isEmpty
            ? Center(
          child: Text(
            'No orders available',
            style: TextStyle(fontSize: 20.0),
          ),
        )
            : ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text(
                  order.productName,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.blue,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ID: ${order.id}\nDate: ${order.date}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    RatingStars(rating: order.rating),
                    Text(
                      'Comment: ${order.comment}',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailsScreen(order: order),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Order {
  final int id;
  final String productName;
  final String date;
  final String comment;
  final int rating;

  Order({
    required this.id,
    required this.productName,
    required this.date,
    required this.comment,
    required this.rating,
  });
}

class RatingStars extends StatelessWidget {
  final int rating;

  RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
            (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.orange,
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Product Name', order.productName),
            _buildDetailItem('Order ID', order.id.toString()),
            _buildDetailItem('Date', order.date),
            RatingStars(rating:order.rating),
            _buildDetailItem('Comment', order.comment),
            // Add more details here if needed
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
