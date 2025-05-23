import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'TopUpDetailPage.dart'; // Import the next page

class TopUpGameSelectionPage extends StatelessWidget {
  // Game list
  final List<Map<String, dynamic>> games = [
    {"name": "Mobile Legends", "image": "assets/img/ml.jpg"},
    {"name": "League of Legends", "image": "assets/img/lol.jpg"},
    {"name": "Dota 2", "image": "assets/img/dota2.jpg"},
    {"name": "Valorant", "image": "assets/img/valorant.png"},
    {"name": "CS:GO", "image": "assets/img/csgo.png"},
    {"name": "Call of Duty", "image": "assets/img/cod.jpg"},
    {"name": "Genshin Impact", "image": "assets/img/genshin.jpg"},
    {"name": "Elden Ring", "image": "assets/img/eldenring.png"},
    {"name": "Final Fantasy", "image": "assets/img/ff.png"},
    {"name": "PUBG", "image": "assets/img/pubg.jpg"},
    {"name": "Fortnite", "image": "assets/img/fortnite.jpg"},
    {"name": "Apex Legends", "image": "assets/img/apex.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D40),
        elevation: 0,
        title: const Text(
          "Top-Up",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Colorful wave background with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF8B5CF6), // Vibrant purple
                              const Color(0xFFEC4899), // Vibrant pink
                              const Color(0xFF1A1D40).withOpacity(0.9),
                            ]
                          : [
                              const Color(0xFF34D399), // Bright green
                              const Color(0xFF60A5FA), // Bright blue
                              const Color(0xFF2C2F50).withOpacity(0.85),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        "Select Your Favorite Game!",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopUpDetailsPage(
                                gameName: game["name"],
                                gameImage: game["image"],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  game["image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: Colors.grey),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.black.withOpacity(0.1),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    game["name"],
                                    style: const TextStyle(
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(1, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, delay: (index * 100).ms)
                          .shimmer(
                            duration: 1200.ms,
                            color: Colors.white.withOpacity(0.3),
                          );
                    },
                    childCount: games.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for a more dynamic wave effect
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 120);

    var firstControlPoint = Offset(size.width / 6, size.height);
    var firstEndPoint = Offset(size.width / 3, size.height - 80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width / 2, size.height - 200);
    var secondEndPoint = Offset(2 * size.width / 3, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    var thirdControlPoint = Offset(5 * size.width / 6, size.height - 150);
    var thirdEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(
      thirdControlPoint.dx,
      thirdControlPoint.dy,
      thirdEndPoint.dx,
      thirdEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}