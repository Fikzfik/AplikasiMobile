import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/clipper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _rememberMe = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> registerUser(String name, String email, String password,
      String confirmPassword, BuildContext context) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Register Berhasil')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        String errorMessage = 'Register gagal';
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
          errorMessage = data['errors'].values.first[0];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;

    double maxWidth = screenWidth < 500 ? screenWidth * 0.9 : 400;
    double fontSizeLarge = screenWidth * 0.06;
    double fontSizeMedium = screenWidth * 0.045;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: DiagonalClipper(),
              child: Container(
                color: isDarkMode ? Colors.black : Color(0xFF1A1D40),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double containerWidth = screenWidth * 0.9;
                  containerWidth = containerWidth > 400 ? 400 : containerWidth;
                  containerWidth = containerWidth < 300 ? 300 : containerWidth;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipPath(
                        clipper: TopDiagonalClipper(),
                        child: Container(
                          width: containerWidth,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 30,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Form Register',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nameController,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey),
                                  prefixIcon: Icon(Icons.people,
                                      color: isDarkMode ? Colors.white : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey),
                                  prefixIcon: Icon(Icons.email,
                                      color: isDarkMode ? Colors.white : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black),
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey),
                                  prefixIcon: Icon(Icons.lock,
                                      color: isDarkMode ? Colors.white : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _confirmPasswordController,
                                style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black),
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm Password',
                                  hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey),
                                  prefixIcon: Icon(Icons.lock,
                                      color: isDarkMode ? Colors.white : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  CupertinoSwitch(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value;
                                      });
                                    },
                                    activeColor:
                                        isDarkMode ? Colors.blueAccent : Color(0xFF1A1D40),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: BottomDiagonalClipper(),
                        child: Container(
                          width: containerWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius:
                                BorderRadius.vertical(bottom: Radius.circular(30)),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.blueAccent
                                          : Color(0xFF1A1D40),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton(
                                  color: isDarkMode ? Colors.blueAccent : Color(0xFF1A1D40),
                                  borderRadius: BorderRadius.circular(10),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  onPressed: () {
                                    final name = _nameController.text.trim();
                                    final email = _emailController.text.trim();
                                    final pass = _passwordController.text.trim();
                                    final confirm = _confirmPasswordController.text.trim();

                                    if (name.isEmpty ||
                                        email.isEmpty ||
                                        pass.isEmpty ||
                                        confirm.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Semua field harus diisi')),
                                      );
                                      return;
                                    }

                                    if (pass != confirm) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Kata sandi tidak cocok')),
                                      );
                                      return;
                                    }

                                    registerUser(name, email, pass, confirm, context);
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text('Or Register With',
                                  style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black)),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.facebook,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40)),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.g_mobiledata, color: Colors.red),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.apple,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40)),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(
                                      fontSize: fontSizeMedium,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: fontSizeMedium,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40),
                                        decoration: TextDecoration.underline,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}