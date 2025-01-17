import 'package:flutter/material.dart';
import 'package:logistics/ForgotPassword.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:http/http.dart' as http;


class ResetPassword extends StatelessWidget {
  const ResetPassword({Key? key}) : super(key: key);

  void _showPasswordResetDialog(BuildContext context, String email) async {
    // Make the API call to send password reset email
    var apiUrl = 'http://logistics-api-8.somee.com/api/Account/ForgotPassword/$email';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'accept': '*/*'},
      );

      if (response.statusCode == 200) {
        // If the request is successful, show the dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Password Reset Email Sent'),
              content: Text(
                'An email with instructions to reset your password has been sent to $email. '
                    'Please check your email inbox and follow the instructions to reset your password.',
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => ForgotPassword(email: email),
                      ),
                    ); // Navigate to the LoginScreen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // If the request fails, show an error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to send password reset email. Please try again later.'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // If an error occurs, show an error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.orange,
        titleSpacing: 0, // Adjust the spacing to align the title to the left
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.mail_lock_outlined, size: 55, color: Colors.orange),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          String email = emailController.text;
                          _showPasswordResetDialog(context, email);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          "Change Password",
                          style: TextStyle(color: Colors.white, fontSize: 18),
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
}
