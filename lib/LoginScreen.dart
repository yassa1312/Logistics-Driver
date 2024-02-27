// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics/RegisterScreen.dart';
import 'package:logistics/ResetPassword.dart';
import 'package:logistics/app_dio.dart';
import 'package:logistics/main.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';


void main() {
  runApp(
    const SignUpApp(),
  );
}

class SignUpApp extends StatelessWidget {
  const SignUpApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (pO, pl, p2) {
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
                    duration: Duration(milliseconds: 1500), // Increased delay to 1500 milliseconds
                    widget: Lottie.asset(
                      'assets/animation/Animation-1703323213613.json',
                      animate: true,
                    ),
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
      },
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
            child: CircularProgressIndicator(), // Placeholder while delaying
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
  bool isKeyboardVisible = false;

  @override
  void initState() {
    checkLoggedIn();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      setState(() {
        isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
      });
    });
  }

  Future<void> checkLoggedIn() async {
    final userData = await getUserData();
    if (userData != null) {
      // User is logged in, navigate to Home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

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

  Future<String?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userData');
  }


  Future<void> loginUserAPI(String email, String password) async {
    const String apiUrl = 'http://www.logistics-api.somee.com/login'; // Replace with your actual API endpoint

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
        await prefs.setString(
            'userData', 'someUserData'); // Save user data or token

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


  Future<void> login() async {
    final userData = await getUserData();
    if (formKey.currentState!.validate()) {
      if (userData == null) {
        String email = emailController.text;
        String password = passwordController.text;
        await loginUserAPI(email, password);
      }
    }
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
                SizedBox(height: 30.sp),
                SizedBox(
                  height: 250,
                  child: Padding(
                    padding: EdgeInsets.all(0.sp),
                    child: Image.asset(
                      'assets/Picture2.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(20.sp),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 30.sp),
                            TextFormField(
                              controller: emailController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
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
                            SizedBox(height: 10.sp),
                            TextFormField(
                              controller: passwordController,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.orange,
                                ),
                                labelStyle: const TextStyle(
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
                                login();
                              },
                            ),
                            SizedBox(height: 10.sp),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => Home()),
                                      );
                                    },//without API
                                   // onPressed: login, //with API
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0.sp),
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                    child:  Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 18.sp,
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
                                      fontSize: 18.sp,
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


  void navToForgetPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPassword()),
    );
  }
}