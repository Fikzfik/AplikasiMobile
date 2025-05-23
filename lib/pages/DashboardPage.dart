import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      _fadeAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
      _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller.forward();
    } catch (e) {
      print('Animation initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/img/logo.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite_border,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              // Add functionality for the heart icon
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              // Add functionality for the cart icon
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Stack(
          children: [
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
                            ? [
                                Color(0xFF2C2F50),
                                Color(0xFF1A1D40).withOpacity(0.9),
                              ]
                            : [
                                Color(0xFF3A3D60),
                                Color(0xFF2C2F50).withOpacity(0.85),
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: buildMainCard(context),
                  ),
                  SizedBox(height: 24),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: buildPromoBanner(context),
                  ),
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Our Services',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: buildMenuGrid(context),
                  ),
                  SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Discover More',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 120,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Exciting Features Coming Soon!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      width: double.infinity,
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
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 3,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Saldo",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: "Poppins",
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
          ),
          SizedBox(height: 8),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: Text(
              "\$4,560",
              key: ValueKey<String>("\$4,560"),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: "Poppins",
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionIcon(
                  context, Icons.upload, "Send", Colors.purpleAccent),
              _buildActionIcon(
                  context, Icons.download, "Receive", Colors.blueAccent),
              _buildActionIcon(
                  context, Icons.attach_money, "Loan", Colors.greenAccent),
              _buildActionIcon(
                  context, Icons.add_card, "Top-Up", Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
      BuildContext context, IconData icon, String label, Color color) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label action tapped!')),
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: "Poppins",
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPromoBanner(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    List<Map<String, dynamic>> promos = [
      {
        'image': 'assets/img/promo1.jpg',
        'title': 'Summer Sale',
        'description': 'Up to 50% off on all services!',
      },
      {
        'image': 'assets/img/promo2.jpg',
        'title': 'Loyalty Rewards',
        'description': 'Earn double points this month!',
      },
      {
        'image': 'assets/img/promo3.jpg',
        'title': 'New User Bonus',
        'description': 'Get \$10 on your first top-up!',
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
        initialPage: 0,
        enableInfiniteScroll: true,
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeFactor: 0.3,
      ),
      items: promos.map((promo) {
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped on ${promo['title']}')),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      promo['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[300]);
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        promo['title'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        promo['description'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontFamily: "Poppins",
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildMenuGrid(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.3,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildMenuCard(context, Icons.computer, "BO Warnet", Colors.blueAccent,
            () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WarnetSelectionPage(), // Navigate to WarnetSelectionPage instead
            ),
          );
        }),
        _buildMenuCard(
            context, Icons.sports_esports, "Booking PS", Colors.purpleAccent,
            () {
          Navigator.pushNamed(context, '/sewaps');
        }),
        _buildMenuCard(
            context, Icons.monetization_on, "Top-Up", Colors.greenAccent, () {
          Navigator.pushNamed(context, '/topup');
        }),
        _buildMenuCard(context, Icons.shield, "Jasa Joki", Colors.orangeAccent,
            () {
          Navigator.pushNamed(context, '/joki');
        }),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

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
              color: color.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: "Poppins",
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
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
