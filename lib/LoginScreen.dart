// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics/RegisterScreen.dart';
import 'package:logistics/ResetPassword.dart';
import 'package:logistics/auth_service.dart';
import 'package:logistics/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignUpApp extends StatelessWidget {
  const SignUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return Center(
              child: _buildDelayedWidget(
                duration: Duration(milliseconds: 1500),
                widget: CircularProgressIndicator(),
              ),
            );
          } else {
            if (snapshot.data == true) {
              return _buildDelayedWidget(
                duration: Duration(milliseconds: 500),
                widget: Home(),
              );
            } else {
              return _buildDelayedWidget(
                duration: Duration(milliseconds: 500),
                widget: LoginScreen(),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildDelayedWidget({
    required Duration duration,
    required Widget widget,
  }) {
    return FutureBuilder<bool>(
      future: Future.delayed(duration, () => true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return widget;
        }
      },
    );
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData') != null;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> checkLoggedIn() async {
    final userData = await getUserData();
    if (userData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  Future<String?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData');
  }

  void displayToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 18.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            color: Colors.orange,
            child: Column(
              children: [
                SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Image.asset(
                      'assets/Picture2.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            TextFormField(
                              controller: emailController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.orange,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.orange,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email required";
                                }
                                if (!value.contains("@") ||
                                    !value.contains(".")) {
                                  return "Invalid email!";
                                }
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.orange,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.orange,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: togglePasswordVisibility,
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                              onChanged: (_) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                loginAPI(context);
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      loginAPI(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const ResetPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  Future<void> loginAPI(BuildContext context) async {
    final userData = await getUserData();
    if (formKey.currentState!.validate()) {
      if (userData == null) {
        String email = emailController.text;
        String password = passwordController.text;
        await loginUserAPI(context, email, password);
      }
    }
  }

  Future<void> loginUserAPI(BuildContext context, String email,
      String password) async {
    String? baseUrl = await AuthService.getURL();
    final apiUrl = '$baseUrl/login'; // Replace with your actual API endpoint

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Successful login, navigate to Home page
        print('Login successful');
        print(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        // Extract and save the access token
        final responseBody = json.decode(response.body);
        final accessToken = responseBody['accessToken'];
        await prefs.setString('accessToken', accessToken); // Save access token
        await prefs.setString('userData', 'someUserData'); // Save user data or token

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        displayToast('Login successful');
      } else {
        // Handle login failure
        print('Login failed');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        displayToast('Login failed');
      }
    } catch (error) {
      // Handle any exceptions that may occur during the HTTP request
      print('Error during login request: $error');
      displayToast('Error during login request');
    }
  }
}

