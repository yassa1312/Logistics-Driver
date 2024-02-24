import 'package:flutter/material.dart';

class NoteLine {
  final String text1;
  final TextStyle style1;

  NoteLine({
    required this.text1,
    required this.style1,
  });
}

// Class representing a single note containing a list of NoteLine objects
class Note {
  final List<NoteLine> lines;

  Note({
    required this.lines,
  });
}

List<Note> notes = [
  Note(
    lines: [
      NoteLine(
        text1: "Laurent 20:18",
        style1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ],
  ),
  // Add more notes as needed...
];

List<List<NoteLine>> deletedNotes = [];


class Account extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Account', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //Navigator.push(
                        //context,
                        //MaterialPageRoute(
                        //builder: (context) => HelpPage(),
                        // ),
                        //);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey, // Provide the color here
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        height: 100,
                        child: const Column(
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
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //Navigator.push(
                        //contex
                        //MaterialPageRoute(
                        //builder: (context) => PaymentPage(),
                        //),
                        //);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey, // Provide the color here
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        height: 100,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, size: 40.0,
                                color: Colors.white),
                            SizedBox(height: 8.0),
                            Text(
                              "Payment",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        //Navigator.push(
                        // context,
                        // MaterialPageRoute(
                        //  builder: (context) => ActivityPage(),
                        //),
                        //);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey, // Provide the color here
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        height: 100,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.music_note, size: 40.0,
                                color: Colors.white),
                            SizedBox(height: 8.0),
                            Text(
                              "Activity",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
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
    );
  }
}



