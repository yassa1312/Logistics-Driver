// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logistics/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistics/LoginScreen.dart';
import 'package:http/http.dart' as http;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final List<String> validPrefixes = ["010", "011", "012", "015"];
  String? validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      return 'Phone Number is mandatory.';
    }

    // Check if the phone number starts with one of the valid prefixes
    if (!validPrefixes.any((prefix) => phone.startsWith(prefix))) {
      return 'Phone number must start with 010, 011, 012, or 015.';
    }

    // Check if the phone number is exactly 11 digits long
    if (phone.length != 11) {
      return 'Phone number must be exactly 11 digits long.';
    }

    // If all validations pass, return null
    return null;
  }

  String? validateEmailDomain(String email) {
    if (email.isEmpty) {
      return 'Email is mandatory.';
    }

    final domain = email.split('@').last;
    if (!['gmail.com', 'yahoo.com', 'hotmail.com'].contains(domain)) {
      return 'Only Gmail, Yahoo, and Hotmail addresses are allowed.';
    }
    return null;
  }
  String? validatePassword(String password, String confirmPassword) {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return 'Passwords are mandatory.';
    }

    // Check if the passwords match
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    // Check if the password length is at least 8 characters
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    // Check if the password contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check if the password contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }

    // Check if the password contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }

    // If all validations pass, return null
    return null;
  }


  bool obscureText1 = true;
  double strength = 0.0;

  @override
  void initState() {
    super.initState();
     // Add listener to roleController
  }

  void togglePasswordVisibility1() {
    setState(() {
      obscureText1 = !obscureText1;
    });
  }


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    nameController.dispose();
    roleController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.orange,
        child: Column(
          children: [
            const SizedBox(height: 30,),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Image.asset(
                  'assets/Picture2.png', // Replace 'assets/Picture1.png' with your actual PNG file path
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: ListView(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      controller: nameController,
                      maxLength: 28,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(
                          Icons.account_box,
                          color: Colors.orange,
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        counterText: '${nameController.text.length}/28',
                      ),
                      onChanged: (text) {
                        setState(() {
                          // This will trigger a rebuild to update the counterText
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: const TextStyle(
                          color: Colors.orange,
                        ),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.phone, color: Colors.orange),
                        counterText: '${phoneNumberController.text.length}/11',
                      ),
                      onChanged: (text) {
                        setState(() {
                          // This will trigger a rebuild to update the counterText
                        });
                      },
                      maxLength: 11, // Limit input to 11 digits
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          displayToast('Please enter a phone number');
                          return 'Please enter a phone number';
                        }

                        // Check if the phone number starts with one of the valid prefixes
                        if (!validPrefixes.any((prefix) => value.startsWith(prefix))) {
                          displayToast('Phone number must start with 010, 011, 012, or 015.');
                          return 'Phone number must start with 010, 011, 012, or 015.';
                        }

                        // Check if the phone number is exactly 11 digits long
                        if (value.length != 11) {
                          displayToast('Phone number must be exactly 11 digits long.');
                          return 'Phone number must be exactly 11 digits long.';
                        }

                        // If all validations pass, return null
                        return null;
                      },

                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email, color: Colors.orange),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is mandatory.';
                        }
                        final domain = value.split('@').last;
                        if (!['gmail.com', 'yahoo.com', 'hotmail.com'].contains(domain)) {
                          return 'Only Gmail, Yahoo, and Hotmail addresses are allowed.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            controller: passwordController,
                            textInputAction: TextInputAction.next,
                            obscureText: obscureText1,
                            onChanged: (password) {
                              // You can add any necessary logic here on password change
                              // For real-time validation, consider using FormFieldValidator or FormFieldSetter
                            },
                            validator: (password) {
                              if (password == null || password.isEmpty) {
                                return 'Password is mandatory.';
                              }

                              // Check if the password length is at least 8 characters
                              if (password.length < 8) {
                                return 'Password must be at least 8 characters long.';
                              }

                              // Check if the password contains at least one uppercase letter
                              if (!password.contains(RegExp(r'[A-Z]'))) {
                                return 'Password must contain at least one uppercase letter.';
                              }

                              // Check if the password contains at least one lowercase letter
                              if (!password.contains(RegExp(r'[a-z]'))) {
                                return 'Password must contain at least one lowercase letter.';
                              }

                              // Check if the password contains at least one digit
                              if (!password.contains(RegExp(r'[0-9]'))) {
                                return 'Password must contain at least one digit.';
                              }

                              // If all validations pass, return null
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.orange),
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock, color: Colors.orange),
                              suffixIcon: GestureDetector(
                                onTap: togglePasswordVisibility1,
                                child: Icon(
                                  obscureText1 ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 10),
                          TextFormField(
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            obscureText: obscureText1,
                            onFieldSubmitted: (_) {
                              onRegisterSuccess();
                            },

                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(
                                color: Colors.orange, // Change label color to orange
                              ),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                              suffixIcon: GestureDetector(
                                onTap: togglePasswordVisibility1,
                                child: Icon(
                                  obscureText1 ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.orange,
                                ),
                              ),
                            ),

                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ), backgroundColor: Colors.orange,
                        ),
                        onPressed: () {
                            onRegisterSuccess();
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have account?",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.
                              orange,
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
          ],
        ),
      ),
    );
  }

  void onRegisterSuccess() async {
    String email = emailController.text;
    String name = nameController.text;
    String phone = phoneNumberController.text;
    String role = roleController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    // Check if the name is at least 3 characters
    if (name.length < 4) {
      displayToast("Name must be at least 3 characters.");
      return;
    }

    // Check if the phone number is empty
    if (phone.isEmpty) {
      displayToast("Phone Number is mandatory.");
      return;
    }// Validate phone number
    String? phoneError = validatePhoneNumber(phone);
    if (phoneError != null) {
      displayToast(phoneError);
      return;
    }
    // Validate email domain
    String? emailError = validateEmailDomain(email);
    if (emailError != null) {
      displayToast(emailError);
      return;
    }

    // Check if the passwords match
    String? passwordError = validatePassword(password, confirmPassword);
    if (passwordError != null) {
      displayToast(passwordError);
      return;
    }


    // Attempt API registration
    try {
      bool registrationSuccess = await RegistrationAPI.registerUser(email, password, name, phone, role);

      RegistrationAPI.displayRegistrationResult(registrationSuccess); // Call displayRegistrationResult

      if (registrationSuccess) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      displayToast("Registration failed");
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
}

class RegistrationAPI {
  static Future<bool> registerUser(String email, String password ,String name,String phone, String role) async {
    var headers = {
      'Content-Type': 'application/json',
    };

    var data = {
      "email": email,
      "password": password,
      "name": name,
      "phone": phone,
      "role":"Driver",
    };

    try {
      String? baseUrl = await AuthService.getURL();
      var response = await http.post(
        Uri.parse('$baseUrl/api/Account/Register'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return true; // Successful registration
      } else {
        print(response.body);
        return false; // Unsuccessful registration
      }
    } catch (error) {
      print('Error during registration: $error');
      return false; // Error during registration
    }
  }

  static void displayRegistrationResult(bool registrationSuccess) {
    if (registrationSuccess) {
      displayToast("Account created successfully!");
    } else {
      displayToast("Registration failed. Please try changing Email or Phone number.");
    }
  }

  static void displayToast(String message) {
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
}


Future<void> saveUserData(String userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userData', userData);
}