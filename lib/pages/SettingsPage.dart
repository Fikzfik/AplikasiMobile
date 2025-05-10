import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late String body;
  bool isLoading = false;
  bool isDataExpanded = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    body = "Belum Ada Data";
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      body = "Memuat...";
      isDataExpanded = true;
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          "Profil & Pengaturan",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Poppins',
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
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
                const SnackBar(content: Text('Notifikasi segera hadir!')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.4,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              Color(0xFF2C2F50),
                              Color(0xFF1A1D40).withOpacity(0.95),
                            ]
                          : [
                              Color(0xFF3A3D60),
                              Color(0xFF2C2F50).withOpacity(0.9),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Color(0xFF262A50), Color(0xFF1A1D40)]
                          : [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.purple[900]!.withOpacity(0.4) : Colors.blue[200]!.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 3,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: isDark
                                    ? [Colors.purple.withOpacity(0.3), Colors.transparent]
                                    : [Colors.blue.withOpacity(0.3), Colors.transparent],
                                radius: 1.2,
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.bottomRight,
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
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(8),
                                child: CachedNetworkImage(
                                  imageUrl: "https://picsum.photos/id/1005/200/300",
                                  imageBuilder: (context, imageProvider) => CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    backgroundImage: imageProvider,
                                  ),
                                  placeholder: (context, url) => CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: SpinKitFadingCircle(color: Colors.deepPurple, size: 80),
                                  ),
                                  errorWidget: (context, url, error) => CircleAvatar(
                                    radius: 100,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.error, color: Colors.red, size: 80),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Fitur edit foto profil segera hadir!')),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.edit, size: 24, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
                      SizedBox(height: 16),
                      Text(
                        "Fikri Ardiansyah",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                      ).animate().fadeIn(duration: 900.ms),
                      Text(
                        "@fikzfik",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      ).animate().fadeIn(duration: 1000.ms),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatChip("Level 10", Colors.blueAccent, isDark),
                          SizedBox(width: 12),
                          _buildStatChip("1000 Poin", Colors.purpleAccent, isDark),
                        ],
                      ).animate().slideY(duration: 1100.ms, begin: 0.5, end: 0.0, curve: Curves.easeOut),
                    ],
                  ),
                ),
                // Settings Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "Pengaturan",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                  ),
                ).animate().fadeIn(duration: 1200.ms),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  childAspectRatio: 1.5,
                  children: [
                    _buildSettingCard(
                      icon: Icons.edit,
                      title: "Edit Profil",
                      gradient: [Colors.blue[700]!, Colors.blue[400]!],
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
                      gradient: [Colors.green[700]!, Colors.green[400]!],
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
                      gradient: [Colors.purple[700]!, Colors.purple[400]!],
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                      },
                      isDark: isDark,
                      trailing: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 50,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: LinearGradient(
                            colors: isDark
                                ? [Colors.purple[700]!, Colors.deepPurple[400]!]
                                : [Colors.blue[300]!, Colors.purple[200]!],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.purple[900]!.withOpacity(0.3) : Colors.blue[200]!.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Switch(
                          value: isDark,
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                          },
                          activeColor: Colors.transparent,
                          activeTrackColor: Colors.transparent,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                      ),
                    ),
                    _buildSettingCard(
                      icon: Icons.notifications,
                      title: "Notifikasi",
                      gradient: [Colors.orange[700]!, Colors.orange[400]!],
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
                      gradient: [Colors.teal[700]!, Colors.teal[400]!],
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
                      gradient: [Colors.red[700]!, Colors.red[400]!],
                      onTap: () {
                        Navigator.pushNamed(context, '/logout');
                      },
                      isDark: isDark,
                    ),
                  ],
                ).animate().fadeIn(duration: 1300.ms).slideY(duration: 1300.ms, begin: 0.5, end: 0.0),
                // Data Fetching Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: GestureDetector(
                      onTap: fetchData,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [Colors.purple[700]!, Colors.deepPurple[400]!]
                                : [Colors.blue[300]!, Colors.purple[200]!],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.purple[900]!.withOpacity(0.5) : Colors.blue[200]!.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 3,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? SpinKitPulse(
                                  color: Colors.white,
                                  size: 32,
                                )
                              : Text(
                                  "AMBIL DATA",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 1400.ms),
                if (body != "Belum Ada Data")
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDataExpanded = !isDataExpanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF262A50) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Data API",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                ),
                                Icon(
                                  isDataExpanded ? Icons.expand_less : Icons.expand_more,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ],
                            ),
                            if (isDataExpanded) ...[
                              SizedBox(height: 12),
                              Text(
                                body,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'Poppins',
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 14,
                                    ),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 1500.ms),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required List<Color> gradient,
    required VoidCallback onTap,
    required bool isDark,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF262A50), Color(0xFF1A1D40)]
                : [Colors.white, Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
            if (trailing != null) ...[
              SizedBox(height: 8),
              trailing,
            ],
          ],
        ),
      ),
    );
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
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 140);

    var firstControlPoint = Offset(size.width / 3.5, size.height - 60);
    var firstEndPoint = Offset(size.width / 2, size.height - 100);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 180);
    var secondEndPoint = Offset(size.width, size.height - 120);
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