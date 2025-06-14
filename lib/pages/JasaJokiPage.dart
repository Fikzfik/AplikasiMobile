import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/animation_builder/custom_animation_builder.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart'; // Import main.dart for ThemeProvider
import 'JokiFormPage.dart';

class JasaJokiPage extends StatefulWidget {
  const JasaJokiPage({super.key});

  @override
  State<JasaJokiPage> createState() => _JasaJokiPageState();
}

class _JasaJokiPageState extends State<JasaJokiPage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> games = const [
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

  late TabController _tabController;
  String searchQuery = '';
  List<Map<String, dynamic>> get filteredGames => games
      .where((game) => game["name"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()))
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Color(0xFF0A0E21) : Color(0xFFF9FAFE),
      body: Stack(
        children: [
          // Animated background
          BlurBackground(
            colors: isDark
                ? [
                    Color(0xFF1A1F38),
                    Color(0xFF0D1028),
                    Color(0xFF2E0A46),
                    Color(0xFF0A0E21),
                  ]
                : [
                    Color(0xFFD1E5FF),
                    Color(0xFFE6F0FA),
                    Color(0xFFC1D5F0),
                    Color(0xFFF9FAFE),
                  ],
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDark),

                // Tabs
                _buildTabs(isDark),

                // Search bar
                _buildSearchBar(isDark),

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
    final primaryColor = isDark ? Color(0xFFFF4D6D) : Color(0xFF4361EE);
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
                colors: [
                  (isDark ? Colors.white : Colors.black).withOpacity(0.14),
                  (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  (isDark ? Colors.white : Colors.black).withOpacity(0.1),
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
            "Game Boosting",
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
              colors: [
                (isDark ? Colors.white : Colors.black).withOpacity(0.14),
                (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final tabGradient = isDark
        ? [Color(0xFFFF4D6D), Color(0xFFC9184A)]
        : [Color(0xFF4CC9F0), Color(0xFF4361EE)];
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      height: 50,
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(colors: tabGradient),
        ),
        labelColor: isDark ? Colors.white : Colors.black87,
        unselectedLabelColor: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(text: "Popular"),
          Tab(text: "New"),
          Tab(text: "Trending"),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar(bool isDark) {
    final primaryColor = isDark ? Color(0xFF4CC9F0) : Color(0xFF4361EE);
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
          colors: [
            (isDark ? Colors.white : Colors.black).withOpacity(0.14),
            (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? Colors.white : Colors.black).withOpacity(0.2),
            (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
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
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
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
                  gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 900.ms).slideY(begin: -0.2, end: 0);
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
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              size: 40,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No games found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.7),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Try a different search term',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
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
        childAspectRatio: 0.75,
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
    final primaryColor = isDark ? Color(0xFFFF4D6D) : Color(0xFF4361EE);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                JokiServicePage(gameName: game["name"]),
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
      child: Stack(
        children: [
          // Game card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Game image
                  Image.asset(
                    game["image"],
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? Colors.grey[900] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
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
                          (isDark ? Colors.black : Colors.black).withOpacity(0.7),
                          (isDark ? Colors.black : Colors.black).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),

                  // Game info
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          game["name"],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.${(index % 5) + 5}",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.people_alt_rounded,
                              color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "${(index + 1) * 125}K",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: index % 3 == 0
                                  ? [primaryColor, primaryColor.withOpacity(0.8)]
                                  : [primaryColor.withOpacity(0.8), primaryColor],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Boost Now",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-right badge (for some games)
          if (index % 4 == 0)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFFFFD700) : Color(0xFFFFA500),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "HOT",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            ),
        ],
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