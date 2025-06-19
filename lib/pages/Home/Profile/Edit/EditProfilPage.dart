import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? userName;
  String? email;
  int? idUser; // Store id_user
  String? profileImageUrl;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        print('Loading user data with token: $token');
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        print('GET /api/user response: status=${response.statusCode}, body=${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            idUser = data['user']['id_user']; // Store id_user
            userName = data['user']['name'] ?? "Pengguna Tidak Ditemukan";
            email = data['user']['email'] ?? "email@example.com";
            _nameController.text = userName!;
            _emailController.text = email!;
            profileImageUrl = "https://picsum.photos/id/1005/200/300"; // Placeholder
          });
          print('User data loaded: id_user=$idUser, name=$userName, email=$email');
        } else {
          setState(() {
            userName = "Error: Status ${response.statusCode}";
          });
        }
      } catch (e) {
        setState(() {
          userName = "Error: $e";
        });
        print('Error loading user data: $e');
      }
    } else {
      print('No token found in SharedPreferences');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { isLoading = true; });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (idUser == null) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found. Please reload profile.')),
      );
      print('Error: id_user is null');
      return;
    }

    try {
      final requestBody = jsonEncode({
        'id_user': idUser,
        'name': _nameController.text,
        'email': _emailController.text,
      });
      print('Sending PUT /api/user with body: $requestBody, token: $token');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('PUT /api/user response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        await _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CachedNetworkImage(
                          imageUrl: profileImageUrl ?? "https://picsum.photos/id/1005/200/300",
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 60,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 60,
                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                            child: SpinKitFadingCircle(
                              color: primaryColor,
                              size: 40,
                            ),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 60,
                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.red, size: 40),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Image upload feature coming soon!')),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: "Name",
                          icon: Icons.person,
                          validator: (value) =>
                              value!.isEmpty ? "Name cannot be empty" : null,
                          isDark: isDark,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email,
                          validator: (value) {
                            if (value!.isEmpty) return "Email cannot be empty";
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value))
                              return "Enter a valid email";
                            return null;
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 24,
                            )
                          : Text(
                              "Save Changes",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: validator,
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}