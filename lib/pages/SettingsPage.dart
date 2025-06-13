import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late String body;
  bool isLoading = false;
  bool isDataExpanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? userName;

  @override
  void initState() {
    super.initState();
    body = "Belum Ada Data";
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            userName = data['user']['name'];
          });
        } else {
          setState(() {
            userName = "Pengguna Tidak Ditemukan";
          });
        }
      } catch (e) {
        setState(() {
          userName = "Error: $e";
        });
      }
    } else {
      setState(() {
        userName = "Belum Login";
      });
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      body = "Memuat...";
      isDataExpanded = true;
    });
    try {
      var response =
          await http.get(Uri.parse("http://10.0.2.2:8000/api/users"));
      setState(() {
        body = response.statusCode == 200
            ? response.body
            : "Gagal memuat data: ${response.statusCode}";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        body = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: buildProfileCard(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Text(
                    "Pengaturan",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: buildSettingsGrid(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Text(
                    "Data API",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: buildDataCard(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CachedNetworkImage(
                  imageUrl: "https://picsum.photos/id/1005/200/300",
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[300],
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[300],
                    child: SpinKitFadingCircle(
                        color: Theme.of(context).colorScheme.primary, size: 40),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red, size: 40),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Fitur edit foto profil segera hadir!')),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ).animate().scale(duration: 800.ms),
            SizedBox(height: 12),
            Text(
              userName ?? "Memuat Nama...",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
            ).animate().fadeIn(duration: 900.ms),
            Text(
              "@fikzfik",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ).animate().fadeIn(duration: 1000.ms),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip(
                    "Level 10", Theme.of(context).colorScheme.primary, isDark),
                SizedBox(width: 12),
                _buildStatChip("1000 Poin",
                    Theme.of(context).colorScheme.secondary, isDark),
              ],
            ).animate().slideY(duration: 1100.ms, begin: 0.2, end: 0.0),
          ],
        ),
      ),
    );
  }

  Widget buildSettingsGrid(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3, // Adjusted to prevent overflow
      children: [
        _buildSettingCard(
          icon: Icons.edit,
          title: "Edit Profil",
          color: Theme.of(context).colorScheme.primary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur edit profil segera hadir!')),
            );
          },
          isDark: isDark,
        ),
        _buildSettingCard(
          icon: Icons.lock,
          title: "Keamanan",
          color: Colors.greenAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur keamanan segera hadir!')),
            );
          },
          isDark: isDark,
        ),
        _buildSettingCard(
          icon: Icons.brightness_6,
          title: "Tema Gelap",
          color: Theme.of(context).colorScheme.secondary,
          onTap: () {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
          isDark: isDark,
          trailing: Transform.scale(
            scale: 0.8, // Scale down the switch to save space
            child: Switch(
              value: isDark,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
          ),
        ),
        _buildSettingCard(
          icon: Icons.notifications,
          title: "Notifikasi",
          color: Colors.orangeAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur notifikasi segera hadir!')),
            );
          },
          isDark: isDark,
        ),
        _buildSettingCard(
          icon: Icons.help,
          title: "Bantuan",
          color: Colors.teal,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fitur bantuan segera hadir!')),
            );
          },
          isDark: isDark,
        ),
        _buildSettingCard(
          icon: Icons.logout,
          title: "Keluar",
          color: Colors.redAccent,
          onTap: () {
            Navigator.pushNamed(context, '/logout');
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color), // Reduced icon size
            ),
            SizedBox(height: 4), // Reduced spacing
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Reduced font size
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (trailing != null) ...[
              SizedBox(height: 4), // Reduced spacing
              trailing,
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(duration: 800.ms);
  }

  Widget _buildStatChip(String label, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
      ),
    );
  }

  Widget buildDataCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return GestureDetector(
      onTap: fetchData,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: isLoading
              ? Center(
                  child: SpinKitFadingCircle(
                      color: Theme.of(context).colorScheme.primary, size: 40))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Data API",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Icon(
                          isDataExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ],
                    ),
                    if (isDataExpanded && body != "Belum Ada Data") ...[
                      SizedBox(height: 12),
                      Text(
                        body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                        maxLines: 10,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(duration: 800.ms);
  }
}
