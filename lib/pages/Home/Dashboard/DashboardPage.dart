import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      _fadeAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      );
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: buildHeader(context),
                ),
                SizedBox(height: 24),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildMainCard(context, primaryColor, secondaryColor),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: buildPromoBanner(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Our Services",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildMenuGrid(context, isDark),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Discover More",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildDiscoverCard(context, isDark),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.gamepad, color: primaryColor),
            ),
            SizedBox(width: 12),
            Text(
              "GameZone",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search functionality coming soon!')),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite_border, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMainCard(BuildContext context, Color primaryColor, Color secondaryColor) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
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
                "Total Saldo",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "PREMIUM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: Text(
              "\$4,560",
              key: ValueKey<String>("\$4,560"),
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, Icons.upload, "Send", Theme.of(context).colorScheme.primary),
              _buildActionButton(context, Icons.download, "Receive", Colors.greenAccent),
              _buildActionButton(context, Icons.attach_money, "Loan", Colors.orangeAccent),
              _buildActionButton(context, Icons.add_card, "Top-Up", Colors.purpleAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label action tapped!')),
        );
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        'gradient': [Colors.purple, Colors.blue],
      },
      {
        'image': 'assets/img/promo2.jpg',
        'title': 'Loyalty Rewards',
        'description': 'Earn double points this month!',
        'gradient': [Colors.orange, Colors.red],
      },
      {
        'image': 'assets/img/promo3.jpg',
        'title': 'New User Bonus',
        'description': 'Get \$10 on your first top-up!',
        'gradient': [Colors.green, Colors.teal],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Special Offers",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 16 / 9,
            autoPlayInterval: Duration(seconds: 5),
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
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: promo['gradient'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        promo['title'] == 'Summer Sale'
                            ? Icons.videogame_asset
                            : promo['title'] == 'Loyalty Rewards'
                                ? Icons.sports_esports
                                : Icons.headset,
                        size: 120,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promo['title'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            promo['description'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Claim Now",
                              style: TextStyle(
                                color: promo['gradient'][0],
                                fontWeight: FontWeight.bold,
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
          }).toList(),
        ),
      ],
    );
  }

  Widget buildMenuGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildServiceCard(
          "BO Warnet",
          Icons.computer,
          Theme.of(context).colorScheme.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => WarnetSelectionPage())),
          isDark,
        ),
        _buildServiceCard(
          "Booking PS",
          Icons.sports_esports,
          Colors.purpleAccent,
          () => Navigator.pushNamed(context, '/sewaps'),
          isDark,
        ),
        _buildServiceCard(
          "Top-Up",
          Icons.monetization_on,
          Colors.greenAccent,
          () => Navigator.pushNamed(context, '/topup'),
          isDark,
        ),
        _buildServiceCard(
          "Jasa Joki",
          Icons.shield,
          Colors.orangeAccent,
          () => Navigator.pushNamed(context, '/joki'),
          isDark,
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDiscoverCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Exciting Features Coming Soon!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}