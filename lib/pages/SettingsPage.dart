import 'package:flutter/material.dart';
import 'package:fikzuas/main.dart';
import '../widgets/clipper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String body;
  bool isLoading = false;

  @override
  void initState() {
    body = "Belum Ada Data";
    super.initState();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      body = "Memuat...";
    });
    try {
      var response = await http.get(Uri.parse("http://10.0.2.2:8000/api/users"));
      print(response.body);
      print("=====================================");
      print(response.statusCode);
      setState(() {
        body = response.statusCode == 200 ? response.body : "Gagal memuat data: ${response.statusCode}";
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D40) : const Color(0xFF2C2F50),
        elevation: 0,
        title: Text(
          "Pengaturan",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // 🔹 Background dengan ClipPath
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.65,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF2C2F50), const Color(0xFF1A1D40).withOpacity(0.9)]
                          : [const Color(0xFF3A3D60), const Color(0xFF2C2F50).withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Konten Profil & Pengaturan
          Column(
            children: [
              // 🔥 Profil User (Stack)
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.transparent,
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? [Colors.purple[700]!, Colors.deepPurple[400]!]
                                : [Colors.blue[300]!, Colors.purple[200]!],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.purple[900]!.withOpacity(0.5) : Colors.blue[200]!.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CachedNetworkImage(
                          imageUrl: "https://picsum.photos/id/1005/200/300",
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: SpinKitCircle(color: Colors.deepPurple, size: 50),
                          ),
                          errorWidget: (context, url, error) => const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.error, color: Colors.red, size: 50),
                          ),
                        ),
                      ).animate().fade(duration: 600.ms, curve: Curves.easeOut).scale(duration: 600.ms, curve: Curves.easeOut),
                      const SizedBox(height: 12),
                      Text(
                        "Fikri Ardiansyah",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ).animate().fade(duration: 700.ms, curve: Curves.easeOut).scale(duration: 700.ms, curve: Curves.easeOut),
                      Text(
                        "@fikzfik",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                      ).animate().fade(duration: 800.ms, curve: Curves.easeOut).scale(duration: 800.ms, curve: Curves.easeOut),
                    ],
                  ),
                ],
              ),

              // 🔥 List Pengaturan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262A50) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "Pengaturan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ).animate().fade(duration: 900.ms, curve: Curves.easeOut),
                      ExpansionTile(
                        title: Text(
                          "Akun",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        children: [
                          _buildSettingTile(
                            icon: Icons.account_circle,
                            title: "Edit Profil",
                            onTap: () {},
                            isDark: isDark,
                          ),
                          _buildSettingTile(
                            icon: Icons.lock,
                            title: "Keamanan",
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ).animate().fade(duration: 900.ms, curve: Curves.easeOut),
                      ExpansionTile(
                        title: Text(
                          "Lainnya",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        children: [
                          _buildSettingTile(
                            icon: Icons.brightness_6,
                            title: "Tema Gelap",
                            onTap: () {},
                            isDark: isDark,
                            trailing: Switch(
                              value: isDark,
                              onChanged: (value) {
                                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                              },
                              activeColor: Colors.deepPurple,
                            ),
                          ),
                          _buildSettingTile(
                            icon: Icons.notifications,
                            title: "Notifikasi",
                            onTap: () {},
                            isDark: isDark,
                          ),
                          _buildSettingTile(
                            icon: Icons.help,
                            title: "Bantuan",
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ).animate().fade(duration: 900.ms, curve: Curves.easeOut),
                      _buildSettingTile(
                        icon: Icons.logout,
                        title: "Keluar",
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pushNamed(context, '/logout');
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: fetchData,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [Colors.purple[700]!, Colors.deepPurple[400]!]
                                  : [Colors.blue[300]!, Colors.purple[200]!],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.purple[900]!.withOpacity(0.5) : Colors.blue[200]!.withOpacity(0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : Text(
                                    "GET DATA",
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ).animate().fade(duration: 900.ms, curve: Curves.easeOut).scale(duration: 900.ms, curve: Curves.easeOut),
                      const SizedBox(height: 16),
                      Text(
                        body,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fade(duration: 900.ms, curve: Curves.easeOut),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    required bool isDark,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: isDark ? const Color(0xFF1A1D40) : Colors.grey[100],
          child: ListTile(
            leading: Icon(
              icon,
              color: iconColor ?? Colors.deepPurple,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: textColor ?? (isDark ? Colors.white : Colors.black87),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ),
      ),
    ).animate().fade(duration: 800.ms, curve: Curves.easeOut).scale(duration: 800.ms, curve: Curves.easeOut);
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 150);
    var secondEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}