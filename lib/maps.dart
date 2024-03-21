import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Position currentPosition;
  late GoogleMapController _controller;
  var geoLocator = Geolocator();
  double bottomPaddingofMap = 0;
  Set<Marker> _markers = {};

  void locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show dialog or enable them programmatically
      return;
    } else {
      // Location services are enabled, attempt to locate position immediately
      try {
        // Check location permissions
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, request permission
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // Permissions are still denied, show explanation dialog or handle it accordingly
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          // Permissions are permanently denied, show settings dialog
          await showSettingsDialog();
          return;
        }
        if (permission == LocationPermission.whileInUse) {
          // Get current position
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          currentPosition = position;

          LatLng latLngPosition = LatLng(position.latitude, position.longitude);
          CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
          _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

          // Add a marker for the current position
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId('current_position'),
                position: latLngPosition,
                infoWindow: const InfoWindow(
                  title: 'Your Location',
                  snippet: 'Please move to rotation of Google map',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Customize marker icon if needed
              ),
            );
          });
        }
      } catch (e) {
        // Handle errors, such as no GPS signal or other location-related issues
        print('Error getting current position: $e');
      }
    }
  }

  Future<void> showSettingsDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission Required'),
          content: Text('Location permission is required to use this app. Please grant the permission in the app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings(); // Open app settings
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to clear user data
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Map', style: TextStyle(color: Colors.black)),
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
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingofMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              _controller = controller;
              locatePosition();
              setState(() {
                bottomPaddingofMap = 0;
              });
            },
            markers: _markers, // Set markers
          ),
        ],
      ),
    );
  }
}

