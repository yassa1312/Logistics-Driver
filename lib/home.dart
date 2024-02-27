import 'package:flutter/material.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'services.dart';

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

final List<Widget> _pages = [

  HomePage(),
  services(),
];

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SPLT',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                LoginScreenState loginScreenState = LoginScreenState();
                await loginScreenState.clearUserData();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen()), // Replace LoginScreen with your actual login screen widget
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // Open Google Maps
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shopping_bag, color: Colors.orange),
                        SizedBox(width: 10.0),
                        Text('The Orders'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),



                //SUGGESSTIONS
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          'Suggestions',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 150),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => services()),
                            );
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 120.0,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 100.0,
                                margin: EdgeInsets.only(right: 10.0),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                //MORE WAYS TO USE

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More ways to use SPLT',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      SizedBox(height: 10.0),

                      //pictures, titles, descriptions scrollable horizentaly
                      Container(
                        height: 200.0,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 150.0,
                                margin: EdgeInsets.only(right: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //container specific for image
                                    Container(
                                      width: double.infinity,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image:
                                              AssetImage(imageUrls[index + 3]),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      textTitle[index + 3],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Text(
                                      Description[index],
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
