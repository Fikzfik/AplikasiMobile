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
        duration: const Duration(milliseconds: 1200),
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: buildHeader(context),
                ),
                SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildMainCard(context),
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
                    'Our Services',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildMenuGrid(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Discover More',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildDiscoverCard(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/img/logo.png',
          height: 36,
          fit: BoxFit.contain,
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search functionality coming soon!')),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite_border,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMainCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Card(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Saldo",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
            SizedBox(height: 8),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: Text(
                "\$4,560",
                key: ValueKey<String>("\$4,560"),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionIcon(context, Icons.upload, "Send",
                    Theme.of(context).colorScheme.primary),
                _buildActionIcon(
                    context, Icons.download, "Receive", Colors.greenAccent),
                _buildActionIcon(
                    context, Icons.attach_money, "Loan", Colors.orangeAccent),
                _buildActionIcon(
                    context, Icons.add_card, "Top-Up", Colors.purpleAccent),
              ],
            ),
          ],
        ),
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
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
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildMenuCard(context, Icons.computer, "BO Warnet",
            Theme.of(context).colorScheme.primary, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WarnetSelectionPage()));
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
      child: Card(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDiscoverCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Card(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Exciting Features Coming Soon!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
        ),
      ),
    );
  }
}
