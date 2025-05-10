import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/clipper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPressed = false;
  bool _rememberMe = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> login(String email, String password) async {
    final response = await http.post( 
      Uri.parse('http://10.0.2.2:8000/api/login'),  // Ganti dengan endpoint API login backend Laravel Anda
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        print('Login sukses: ${data['user']['name']}');
        // Menyimpan token atau data user di local storage atau shared preferences untuk sesi
        Navigator.pushNamed(context, '/home');
      } else {
        showErrorDialog('Login gagal. Periksa email dan password Anda.');
      }
    } else {
      showErrorDialog('Terjadi kesalahan. Server tidak merespons.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double maxWidth = screenWidth < 500 ? screenWidth * 0.9 : 400;
    double fontSizeLarge = screenWidth * 0.06; // responsif font
    double fontSizeMedium = screenWidth * 0.045;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Section
                      ClipPath(
                        clipper: TopDiagonalClipper(),
                        child: Container(
                          width: maxWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 30,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: fontSizeLarge,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: fontSizeMedium,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email Address',
                                  hintStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),
                                  prefixIcon: Icon(Icons.email,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: fontSizeMedium,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white54
                                        : Colors.grey,
                                  ),
                                  prefixIcon: Icon(Icons.lock,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  CupertinoSwitch(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value;
                                      });
                                    },
                                    activeColor: isDarkMode
                                        ? Colors.blueAccent
                                        : Color(0xFF1A1D40),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                        fontSize: fontSizeMedium,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Section
                      ClipPath(
                        clipper: BottomDiagonalClipper(),
                        child: Container(
                          width: maxWidth,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 32),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: fontSizeMedium,
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
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    setState(() {
                                      _isPressed = true;
                                    });
                                  },
                                  onTapUp: (_) {
                                    setState(() {
                                      _isPressed = false;
                                    });
                                  },
                                  onTap: () {
                                    // Lakukan login
                                    String email = _emailController.text;
                                    String password = _passwordController.text;
                                    if (email.isNotEmpty && password.isNotEmpty) {
                                      login(email, password);
                                    } else {
                                      showErrorDialog('Harap isi email dan password.');
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isPressed
                                          ? Colors.white
                                          : (isDarkMode
                                              ? Colors.blueAccent
                                              : Color(0xFF1A1D40)),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: fontSizeMedium,
                                          color: _isPressed
                                              ? (isDarkMode
                                                  ? Colors.black
                                                  : Color(0xFF1A1D40))
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'or login with',
                                style: TextStyle(
                                  fontSize: fontSizeMedium,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: screenWidth * 0.08,
                                    icon: Icon(Icons.facebook,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40)),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    iconSize: screenWidth * 0.08,
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.red),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    iconSize: screenWidth * 0.08,
                                    icon: Icon(Icons.android,
                                        color: Colors.green),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    iconSize: screenWidth * 0.08,
                                    icon: Icon(Icons.apple,
                                        color: isDarkMode
                                            ? Colors.blueAccent
                                            : Color(0xFF1A1D40)),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      fontSize: fontSizeMedium,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          '/register'); // Pastikan route ini sudah didefinisikan
                                    },
                                    child: Text(
                                      "Register",
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
