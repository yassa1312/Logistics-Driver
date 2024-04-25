import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:logistics/OrderViewMyDeliveredRequests..dart';
import 'package:logistics/OrderViewRequests.dart';
import 'package:logistics/maps.dart';
import 'package:logistics/test.dart';

import 'OrderViewAcceptedRequests.dart';
import 'activity.dart';
import 'account.dart';

void main() {
  runApp( SignUpApp());//SignUpApp
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPLT App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = [

    OrderViewRequests(),
    OrderDriverViewAcceptedRequests(),
    OrderViewMyDeliveredRequests(),
    Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _pages[_currentIndex], // Display the selected screen here
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            
            BottomNavigationBarItem(
              icon: Icon(Icons.content_paste),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Working Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
