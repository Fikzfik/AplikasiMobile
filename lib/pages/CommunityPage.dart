import 'package:flutter/material.dart';
import '../widgets/clipper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

class CommunityChat extends StatefulWidget {
  @override
  State<CommunityChat> createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> gameCategories = [
    {
      "name": "MOBA",
      "image": "assets/moba.jpg",
      "games": [
        {"name": "Mobile Legends", "image": "assets/ml.jpg"},
        {"name": "League of Legends", "image": "assets/lol.jpg"},
        {"name": "Dota 2", "image": "assets/dota2.jpg"}
      ]
    },
    {
      "name": "FPS",
      "image": "assets/fps.jpg",
      "games": [
        {"name": "Valorant", "image": "assets/valorant.png"},
        {"name": "CS:GO", "image": "assets/csgo.png"},
        {"name": "Call of Duty", "image": "assets/cod.jpg"}
      ]
    },
    {
      "name": "RPG",
      "image": "assets/rpg.jpg",
      "games": [
        {"name": "Genshin Impact", "image": "assets/genshin.jpg"},
        {"name": "Elden Ring", "image": "assets/eldenring.png"},
        {"name": "Final Fantasy", "image": "assets/ff.png"}
      ]
    },
    {
      "name": "Battle Royale",
      "image": "assets/battle_royale.jpeg",
      "games": [
        {"name": "PUBG", "image": "assets/pubg.jpg"},
        {"name": "Fortnite", "image": "assets/fortnite.jpg"},
        {"name": "Apex Legends", "image": "assets/apex.png"}
      ]
    },
  ];

  final List<Map<String, String>> recentDiscussions = [
    {
      "title": "Best MOBA Strategies 2025",
      "category": "MOBA",
      "lastPost": "2 hours ago",
    },
    {
      "title": "Valorant New Update Discussion",
      "category": "FPS",
      "lastPost": "5 hours ago",
    },
    {
      "title": "RPG Hidden Gems",
      "category": "RPG",
      "lastPost": "1 day ago",
    },
  ];

  @override
  void initState() {
    super.initState();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1D40) : const Color(0xFF2C2F50),
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey,
                  border: Border.all(
                    color: isDark ? Colors.white : Colors.black54,
                    width: 3,
                  ),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage("https://picsum.photos/id/798/200/300"),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Welcome, Gamer!",
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
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
                            ? [Color(0xFF2C2F50), Color(0xFF1A1D40).withOpacity(0.9)]
                            : [Color(0xFF3A3D60), Color(0xFF2C2F50).withOpacity(0.85)],
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
                  SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Featured Communities",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 200,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(gameCategories[index % gameCategories.length]["image"]),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                gameCategories[index % gameCategories.length]["name"],
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: gameCategories.length,
                      autoplay: true,
                      autoplayDelay: 5000,
                      viewportFraction: 0.8,
                      scale: 0.9,
                    ),
                  ),
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Select Categories",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  StaggeredGrid.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: gameCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return StaggeredGridTile.count(
                        crossAxisCellCount: 2,
                        mainAxisCellCount: index.isEven ? 2.0 : 1.5,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: isDark ? Color(0xFF1A1D40) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  category["name"] + " Games",
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: (category["games"] as List<dynamic>).map((game) {
                                    return ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          game["image"],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        game["name"],
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Joined ${game["name"]} community!')),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Close", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                                  )
                                ],
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(category["image"]),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                category["name"],
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Recent Discussions",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ...recentDiscussions.map((discussion) {
                    return ScaleTransition(
                      scale: _scaleAnimation,
                      child: Card(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            discussion["title"]!,
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            "${discussion["category"]} • ${discussion["lastPost"]}",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening ${discussion["title"]} discussion')),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      "Join Events",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 160, // Increased height to fix overflow
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Color(0xFF262A50), Color(0xFF1A1D40)]
                              : [Color(0xFFE6F0FA), Color(0xFFC1D5FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced padding to fit content
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Weekly Gaming Tournament",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Join our weekly event and compete with other gamers! Prizes await.",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Registered for the tournament!')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "Join Now",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
}

// Custom Wave Clipper (diimpor dari widgets/clipper.dart)
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