import 'package:flutter/material.dart';

class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Account', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        decoration: BoxDecoration(border: Border.all()),
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey, // Provide the color here
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 40.0, color: Colors.white),
                    SizedBox(height: 8.0),
                    Text(
                      "Help",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey, // Provide the color here
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 40.0, color: Colors.white),
                    SizedBox(height: 8.0),
                    Text(
                      "Payment",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey, // Provide the color here
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 40.0, color: Colors.white),
                    SizedBox(height: 8.0),
                    Text(
                      "Activity",
                      style: TextStyle(color: Colors.white),
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
}
