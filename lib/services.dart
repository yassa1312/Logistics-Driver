import 'package:flutter/material.dart';

final List<String> imageUrls = [
  'assets/icon1.jpeg',
  'assets/icon2.jpeg',
  'assets/icon3.jpeg',
  'assets/portrait1.jpg',
  'assets/portrait2.jpeg',
  'assets/portrait3.jpeg',
];

final List<String> textTitle = [
  'Normal Transportation',
  'Packaging',
  'Scheduling',
  'Insured Transportation',
  'TakeCare',
  'Wrapper'
];

final List<String> Description = [
  'Transport your goods in safety without any concerns about the damage of your goods',
  'A special option for those who want their goods handled with extra care',
  'Additional wrapping options to protect fragile or valuable items'
];


class services extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Services',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deliver anything, anywhere',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    width: 100.0,
                    child: Column(
                      children: [
                        Image.asset(
                          imageUrls[index],
                          height: 80.0,
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          textTitle[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
