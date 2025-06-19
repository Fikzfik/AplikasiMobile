import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:fikzuas/pages/Home/Profile/Edit/EditProfilPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool isLoading = false;
  bool isDataExpanded = false;
  String? userName;
  String? email; // Store user's email
  String body = "Belum Ada Data";
  bool notificationsEnabled = true;
  String selectedLanguage = "English";

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
            userName = data['user']['name'] ?? "Pengguna Tidak Ditemukan";
            email = data['user']['email'] ?? "email@example.com"; // Fetch email
          });
          print('User data loaded: name=$userName, email=$email');
        } else {
          setState(() {
            userName = "Pengguna Tidak Ditemukan";
            email = "email@example.com";
          });
          print('Failed to load user data: status=${response.statusCode}, body=${response.body}');
        }
      } catch (e) {
        setState(() {
          userName = "Error: $e";
          email = "email@example.com";
        });
        print('Error loading user data: $e');
      }
    } else {
      setState(() {
        userName = "Belum Login";
        email = "email@example.com";
      });
      print('No token found in SharedPreferences');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      body = "Memuat...";
      isDataExpanded = true;
    });
    try {
      var response = await http.get(Uri.parse("http://10.0.2.2:8000/api/users"));
      setState(() {
        body = response.statusCode == 200
            ? response.body
            : "Gagal memuat data: ${response.statusCode}";
        isLoading = false;
      });
      print('fetchData response: status=${response.statusCode}, body=${response.body}');
    } catch (e) {
      setState(() {
        body = "Error: $e";
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 24),

                // Profile Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Theme.of(context).colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CachedNetworkImage(
                              imageUrl: "https://picsum.photos/id/1005/200/300",
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 40,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => CircleAvatar(
                                radius: 40,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                                child: SpinKitFadingCircle(
                                  color: primaryColor,
                                  size: 30,
                                ),
                              ),
                              errorWidget: (context, url, error) => CircleAvatar(
                                radius: 40,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                                child: Icon(Icons.error, color: Colors.red, size: 30),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Fitur edit foto profil segera hadir!')),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? "Memuat Nama...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                email ?? "Memuat Email...", // Display actual email
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Premium",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "1250 pts",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Account Settings
                Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  icon: Icons.person,
                  title: "Edit Profile",
                  subtitle: "Change your personal information",
                  color: Colors.blue,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage()),
                    ).then((_) {
                      print('Returned from EditProfilePage, reloading user data');
                      _loadUserData(); // Refresh data on return
                    });
                  },
                ),
                _buildSettingItem(
                  icon: Icons.lock,
                  title: "Security",
                  subtitle: "Password and authentication",
                  color: Colors.green,
                  isDark: isDark,
                ),
                _buildSettingItem(
                  icon: Icons.payment,
                  title: "Payment Methods",
                  subtitle: "Manage your payment options",
                  color: Colors.purple,
                  isDark: isDark,
                ),

                SizedBox(height: 24),

                // Preferences
                Text(
                  "Preferences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 16),
                _buildSwitchItem(
                  icon: Icons.notifications,
                  title: "Notifications",
                  subtitle: "Enable push notifications",
                  color: Colors.orange,
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                  isDark: isDark,
                ),
                _buildSwitchItem(
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  subtitle: "Toggle dark theme",
                  color: Colors.indigo,
                  value: isDark,
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  },
                  isDark: isDark,
                ),
                _buildDropdownItem(
                  icon: Icons.language,
                  title: "Language",
                  subtitle: "Select your preferred language",
                  color: Colors.teal,
                  value: selectedLanguage,
                  items: ["English", "Spanish", "French", "German", "Japanese"],
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                  isDark: isDark,
                ),

                SizedBox(height: 24),

                // Support
                Text(
                  "Support",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 16),
                _buildSettingItem(
                  icon: Icons.help,
                  title: "Help Center",
                  subtitle: "Get help with your account",
                  color: Colors.amber,
                  isDark: isDark,
                ),
                _buildSettingItem(
                  icon: Icons.feedback,
                  title: "Feedback",
                  subtitle: "Share your thoughts with us",
                  color: Colors.cyan,
                  isDark: isDark,
                ),
                _buildSettingItem(
                  icon: Icons.info,
                  title: "About",
                  subtitle: "App version and information",
                  color: Colors.deepPurple,
                  isDark: isDark,
                ),

                SizedBox(height: 24),

                // Logout Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/logout');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: onTap ?? () {},
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.arrow_drop_down),
          underline: SizedBox(),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}