import 'package:fikzuas/pages/TopUp/TopUpDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart'; // Import main.dart for ThemeProvider

class TopUpGameSelectionPage extends StatefulWidget {
  @override
  _TopUpGameSelectionPageState createState() => _TopUpGameSelectionPageState();
}

class _TopUpGameSelectionPageState extends State<TopUpGameSelectionPage> {
  final List<Map<String, dynamic>> games = [
    {"name": "Mobile Legends", "image": "assets/img/ml.jpg", "popular": true},
    {"name": "League of Legends", "image": "assets/img/lol.jpg", "popular": true},
    {"name": "Dota 2", "image": "assets/img/dota2.jpg", "popular": false},
    {"name": "Valorant", "image": "assets/img/valorant.png", "popular": true},
    {"name": "CS:GO", "image": "assets/img/csgo.png", "popular": false},
    {"name": "Call of Duty", "image": "assets/img/cod.jpg", "popular": true},
    {"name": "Genshin Impact", "image": "assets/img/genshin.jpg", "popular": true},
    {"name": "Elden Ring", "image": "assets/img/eldenring.png", "popular": false},
    {"name": "Final Fantasy", "image": "assets/img/ff.png", "popular": false},
    {"name": "PUBG", "image": "assets/img/pubg.jpg", "popular": true},
    {"name": "Fortnite", "image": "assets/img/fortnite.jpg", "popular": false},
    {"name": "Apex Legends", "image": "assets/img/apex.png", "popular": true},
  ];

  String searchQuery = '';
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Action',
    'RPG',
    'MOBA',
    'FPS',
    'Battle Royale'
  ];

  List<Map<String, dynamic>> get filteredGames {
    var filtered = games
        .where((game) => game["name"]
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    if (selectedCategory != 'All') {
      if (selectedCategory == 'MOBA') {
        filtered = filtered
            .where((game) =>
                game["name"].contains("Legends") || game["name"].contains("Dota"))
            .toList();
      } else if (selectedCategory == 'FPS') {
        filtered = filtered
            .where((game) =>
                game["name"].contains("Valorant") ||
                game["name"].contains("CS:GO") ||
                game["name"].contains("Call of Duty"))
            .toList();
      } else if (selectedCategory == 'Battle Royale') {
        filtered = filtered
            .where((game) =>
                game["name"].contains("PUBG") ||
                game["name"].contains("Fortnite") ||
                game["name"].contains("Apex"))
            .toList();
      } else if (selectedCategory == 'RPG') {
        filtered = filtered
            .where((game) =>
                game["name"].contains("Genshin") ||
                game["name"].contains("Elden") ||
                game["name"].contains("Fantasy"))
            .toList();
      }
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Color(0xFF0A0E21) : Color(0xFFF9FAFE),
      body: Stack(
        children: [
          // Animated background
          BlurBackground(
            colors: isDark
                ? [
                    Color(0xFF3A0CA3),
                    Color(0xFF4361EE),
                    Color(0xFF4CC9F0),
                    Color(0xFF0A0E21),
                  ]
                : [
                    Color(0xFF6B7280),
                    Color(0xFF60A5FA),
                    Color(0xFF34D399),
                    Color(0xFFF9FAFE),
                  ],
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDark),

                // Title and subtitle
                _buildTitle(isDark),

                // Categories
                _buildCategories(isDark),

                // Search bar
                _buildSearchBar(isDark),

                // Featured game
                if (searchQuery.isEmpty && selectedCategory == 'All')
                  _buildFeaturedGame(isDark),

                // Game grid
                Expanded(
                  child: filteredGames.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildGameGrid(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassmorphicContainer(
              width: 45,
              height: 45,
              borderRadius: 15,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.14),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.05),
                      ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ]
                    : [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.1),
                      ],
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
          ),
          Text(
            "Top Up",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ).animate().fadeIn(duration: 600.ms),
          GlassmorphicContainer(
            width: 45,
            height: 45,
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.14),
                      Colors.white.withOpacity(0.05),
                    ]
                  : [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.05),
                    ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ]
                  : [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.1),
                    ],
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: isDark ? Colors.white : Colors.black87,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Game Top Up",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.2, end: 0),
          SizedBox(height: 5),
          Text(
            "Get the best deals for your favorite games",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(top: 15, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          Color(0xFF4CC9F0),
                          Color(0xFF4361EE),
                        ],
                      )
                    : null,
                color: isSelected
                    ? null
                    : isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 900.ms, delay: (index * 50).ms);
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 55,
        borderRadius: 15,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ]
              : [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                size: 22,
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search games...',
                    hintStyle: GoogleFonts.poppins(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black54,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CC9F0),
                      Color(0xFF4361EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildFeaturedGame(bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 15),
      height: 150,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TopUpDetailsPage(
                gameName: "Mobile Legends",
                gameImage: "assets/img/ml.jpg",
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/img/ml.jpg",
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4D6D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "FEATURED",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Mobile Legends",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Special Promo: 20% Extra Diamonds",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Top-right badge
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "4.9",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 1100.ms).scale(begin: Offset(1, 0.95));
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
              size: 40,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No games found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Try a different search term or category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(bool isDark) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        return _buildGameCard(context, game, index, isDark);
      },
    );
  }

  Widget _buildGameCard(
      BuildContext context, Map<String, dynamic> game, int index, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TopUpDetailsPage(
              gameName: game["name"],
              gameImage: game["image"],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.14),
                  Colors.white.withOpacity(0.05),
                ]
              : [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ]
              : [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                ],
        ),
        child: Column(
          children: [
            // Game image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      game["image"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),

                    // Popular badge
                    if (game["popular"] == true)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "POPULAR",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Game info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CC9F0).withOpacity(0.7),
                    Color(0xFF4361EE).withOpacity(0.7),
                  ],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game["name"],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        color: Colors.white.withOpacity(0.8),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Top Up Now",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: (index * 100).ms)
          .scale(delay: (index * 100).ms, duration: 400.ms),
    );
  }
}

class BlurBackground extends StatelessWidget {
  final List<Color> colors;

  const BlurBackground({
    Key? key,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomAnimationBuilder<double>(
        control: Control.mirror,
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(seconds: 20),
        builder: (context, value, child) {
          return Stack(
            children: [
              Positioned(
                top: -100,
                left: -100 + (value * 50),
                child: _buildGradientCircle(300, colors[0]),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: -100 + (value * -30),
                child: _buildGradientCircle(250, colors[1]),
              ),
              Positioned(
                bottom: -150,
                left: MediaQuery.of(context).size.width * 0.5 + (value * 40),
                child: _buildGradientCircle(350, colors[2]),
              ),
              // Overlay to darken and add texture
              Container(
                decoration: BoxDecoration(
                  color: colors[3].withOpacity(0.85),
                  backgroundBlendMode: BlendMode.multiply,
                ),
              ),
              // Noise texture overlay
              Opacity(
                opacity: 0.03,
                child: Image.asset(
                  'assets/img/noise_texture.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradientCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}