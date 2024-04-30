import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Class to represent the URL
class URL {
  String url;

  URL(this.url);
}

// Provider for the URL class
class URLProvider extends ChangeNotifier {
  static const String _defaultURL = 'http://logistics-api-8.somee.com'; // Default URL
  late URL _url; // Declaring _url as non-nullable

  URL get url => _url; // Non-nullable return type

  // Constructor to initialize with default URL
  URLProvider() {
    _url = URL(_defaultURL);
  }

  // Method to set a new URL
  void setURL(String newURL) {
    _url = URL(newURL);
    notifyListeners();
  }
}

// Example usage in a widget
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final urlProvider = Provider.of<URLProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(urlProvider.url.url), // Accessing URL directly from URLProvider
            ElevatedButton(
              onPressed: () {
                // Set a new URL
                urlProvider.setURL('${urlProvider.url.url}/api/Driver/ViewMyAcceptedRequests/1');
                // Request phone permission
              },
              child: Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}

// Main function
void main() {
  runApp(MyApp());
}

// MyApp widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => URLProvider(),
      child: MaterialApp(
        home: ExampleWidget(),
      ),
    );
  }
}
