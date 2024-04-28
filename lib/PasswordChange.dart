import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logistics/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'LoginScreen.dart'; // Import your LoginScreen if it's in a separate file

class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key}) : super(key: key);

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool obscureTextOldPassword = true;
  bool obscureTextNewPassword = true;
  bool obscureTextConfirmPassword = true;
  late FocusNode newPasswordFocus;
  late FocusNode confirmPasswordFocus;

  @override
  void initState() {
    super.initState();
    newPasswordFocus = FocusNode();
    confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  void toggleOldPasswordVisibility() {
    setState(() {
      obscureTextOldPassword = !obscureTextOldPassword;
    });
  }

  void toggleNewPasswordVisibility() {
    setState(() {
      obscureTextNewPassword = !obscureTextNewPassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obscureTextConfirmPassword = !obscureTextConfirmPassword;
    });
  }
  Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
  void _showPasswordResetDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Password Change'),
          content: Text(
            'You will signin again ',
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                clearUserData();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ); // Navigate to the LoginScreen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword() async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter all fields.");
      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(msg: "New password and confirmation do not match.");
      return;
    }

    String? token = await AuthService.getAccessToken(); // Moved outside the try block

    var url = Uri.parse('http://logistics-api-8.somee.com/api/Account/ChangemyPassword');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var body = jsonEncode({
      "currentPassword": oldPassword,
      "newPassword": newPassword,
    });

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      _showPasswordResetDialog(context, 'sample@email.com');
    } else {
      Fluttertoast.showToast(msg: "Failed to change password.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Password Change'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: oldPasswordController,
              textInputAction: TextInputAction.next,
              obscureText: obscureTextOldPassword,
              onChanged: (password) {},
              onFieldSubmitted: (_) => newPasswordFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Old Password',
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                suffixIcon: GestureDetector(
                  onTap: toggleOldPasswordVisibility,
                  child: Icon(
                    obscureTextOldPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: newPasswordFocus,
              controller: newPasswordController,
              textInputAction: TextInputAction.next,
              obscureText: obscureTextNewPassword,
              onChanged: (password) {},
              onFieldSubmitted: (_) => confirmPasswordFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                suffixIcon: GestureDetector(
                  onTap: toggleNewPasswordVisibility,
                  child: Icon(
                    obscureTextNewPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: confirmPasswordFocus,
              controller: confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: obscureTextConfirmPassword,
              onFieldSubmitted: (_) => changePassword(),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: const TextStyle(
                  color: Colors.orange,
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                suffixIcon: GestureDetector(
                  onTap: toggleConfirmPasswordVisibility,
                  child: Icon(
                    obscureTextConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.orange,
                ),
                onPressed: changePassword,

                child: const Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
