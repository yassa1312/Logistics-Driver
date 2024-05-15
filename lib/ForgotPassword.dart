import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  final String email;

  const ForgotPassword({Key? key, required this.email}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late TextEditingController emailController;
  bool _obscureText = true;
  void dispose() {
    super.dispose();
    codeController.dispose();
    passwordController.dispose();
  }
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }
  void togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forget Password"),
        backgroundColor: Colors.orange,
        titleSpacing: 0, // Adjust the spacing to align the title to the left
      ),
      body: Container(
        color: Colors.orange,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, color: Colors.orange),
                        labelStyle: TextStyle(color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: codeController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        labelStyle: TextStyle(
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, color: Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      textInputAction: TextInputAction.done,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'New Password',
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
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _resetPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange, // Text color
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
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

  void _resetPassword() async {
    String code = codeController.text.trim();
    String password = passwordController.text.trim();

    bool resetSuccess = await ResetAPI.resetPassword(widget.email, code, password);
    if (resetSuccess) {
      Fluttertoast.showToast(
        msg: "Password reset successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      // Navigate to login screen after successful password reset
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to reset password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

class ResetAPI {
  static Future<bool> resetPassword(String email, String code, String password) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var data = {
      "email": email,
      "code": code,
      "newPassword": password,
    };

    try {
      String? baseUrl = await AuthService.getURL();
      var response = await http.post(
        Uri.parse('$baseUrl/api/Account/ResetPassword'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return true; // Successful reset
      } else {
        print(response.body);
        return false; // Unsuccessful reset
      }
    } catch (error) {
      print('Error during password reset: $error');
      return false; // Error during password reset
    }
  }
}
