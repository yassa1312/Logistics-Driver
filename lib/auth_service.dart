import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _accessTokenKey = 'accessToken';
  static const String _urlKey = 'url'; // Key for storing URL in shared preferences
  static const String _defaultURL = 'http://logistics-api-8.somee.com'; // Default URL

  // Method to save URL to shared preferences
  static Future<void> saveURL(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
  }

  // Method to retrieve URL from shared preferences
  // String? baseUrl = await AuthService.getURL(); // Retrieve base URL from AuthService
  static Future<String> getURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_urlKey) ?? _defaultURL;
  }

  static Future<void> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> clearAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }
  static Future<void> clearUserData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }
}
