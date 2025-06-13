import 'package:fikzuas/booking_state.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/pages/Warnet/PcListPage.dart';
import 'package:fikzuas/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

class FixedStore extends StatefulWidget {
  @override
  _FixedStoreState createState() => _FixedStoreState();
}

class _FixedStoreState extends State<FixedStore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 0;

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

  Future<List<Map<String, dynamic>>> fetchWarnetData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/warnets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {
        "id": item['id_warnet'],
        "name": item['warnet_name'],
        "address": item['address'],
        "availablePcs": item['total_pcs'],
        "rating": item['stars'] != null ? double.parse(item['stars']) : 0.0,
        "image": "assets/img/net${(data.indexOf(item) % 3) + 1}.png",
      }).toList();
    } else {
      print(response);
      throw Exception('Gagal memuat data warnet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationHeader(),
              SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeAnimation,
                child: buildMainCard(context),
              ),
              SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildWarnetSpecialty(),
              ),
              SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildPromoBanner(context),
              ),
              SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildNearbyWarnet(),
              ),
              SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildTopWarnet(),
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF2196F3),
        unselectedItemColor: Color(0xFF757575),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New York, USA",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            Text(
              "Warnetancer",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.search, color: Color(0xFF2196F3), size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildMainCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border(
       
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Saldo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            SizedBox(height: 8),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Text(
                "\$4,560",
                key: ValueKey<String>("\$4,560"),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(context, Icons.upload, "Send", Colors.purpleAccent),
                _buildActionButton(context, Icons.download, "Receive", Colors.blueAccent),
                _buildActionButton(context, Icons.attach_money, "Loan", Colors.greenAccent),
                _buildActionButton(context, Icons.add_card, "Top-Up", Colors.orangeAccent),
              ],
            ),
          ],
        ),
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
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnetSpecialty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Our Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.3,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildMenuCard(context, Icons.computer, "BO Warnet", Color(0xFF2196F3),
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WarnetSelectionPage(),
                ),
              );
            }),
            _buildMenuCard(
                context, Icons.sports_esports, "Booking PS", Color(0xFF2196F3), () {
              Navigator.pushNamed(context, '/sewaps');
            }),
            _buildMenuCard(
                context, Icons.monetization_on, "Top-Up", Color(0xFF2196F3), () {
              Navigator.pushNamed(context, '/topup');
            }),
            _buildMenuCard(context, Icons.shield, "Jasa Joki", Color(0xFF2196F3),
                () {
              Navigator.pushNamed(context, '/joki');
            }),
          ],
        ),
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

  Widget _buildPromoBanner(BuildContext context) {
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
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.asset(
                    promo['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Color(0xFFF5F5F5));
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          promo['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNearbyWarnet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nearby Warnet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchWarnetData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No warnet available'));
            } else {
              final warnetList = snapshot.data!.take(2).toList();
              return Column(
                children: warnetList.map((warnet) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: _buildWarnetCard(context, warnet),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildWarnetCard(BuildContext context, Map<String, dynamic> warnet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => BookingState()
                ..initializePcSlots(warnet["name"], warnet["availablePcs"]),
              child: PcListPage(
                warnetName: warnet["name"],
                warnetId: warnet["id"],
              ),
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  warnet["image"],
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 80,
                      color: Color(0xFFF5F5F5),
                      child: Center(child: Text('Image not found')),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warnet["name"],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      warnet["address"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFFFFA000), size: 16),
                        Text(
                          "${warnet["rating"]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
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
    );
  }

  Widget _buildTopWarnet() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Top Warnet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchWarnetData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No warnet available'));
            } else {
              final warnetList = snapshot.data!.take(3).toList();
              return Column(
                children: warnetList.map((warnet) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: _buildWarnetCardTop(context, warnet),
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildWarnetCardTop(BuildContext context, Map<String, dynamic> warnet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color(0xFFF5F5F5),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFEEEEEE),
              child: Icon(Icons.person, color: Color(0xFF2196F3), size: 32),
              radius: 30,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warnet["name"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    warnet["address"],
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFA000), size: 16),
                      Text(
                        "${warnet["rating"]}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                      Text(
                        " (${warnet["availablePcs"]} Reviews)",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeNotifierProvider(
                      create: (_) => BookingState()
                        ..initializePcSlots(warnet["name"], warnet["availablePcs"]),
                      child: PcListPage(
                        warnetName: warnet["name"],
                        warnetId: warnet["id"],
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Text(
                "Make Booking",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}