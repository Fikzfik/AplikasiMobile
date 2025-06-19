import 'dart:async';
import 'dart:convert';
import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fikzuas/pages/Home/Chat/Grup/chat_group_screen.dart';
import 'package:fikzuas/pages/Home/Chat/FindFriends/find_friends_screen.dart';

class CommunityChat extends StatefulWidget {
  @override
  _CommunityChatState createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> discussions = [];
  List<Map<String, dynamic>> events = [];
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    );

    _loadAuthData();
    _headerController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'your-token';
    });
    if (_token != null) {
      await _fetchCategories();
      await _fetchDiscussions();
      await _fetchEvents();
    } else {
      _loadFallbackData();
    }
  }

  Future<void> _fetchCategories() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/categories'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          categories = data
              .map((cat) => {
                    'name': cat['name'] ?? 'Unknown',
                    'icon': _getIconFromName(cat['name']),
                    'color': _getColorFromName(cat['name']),
                    'gradient': _parseGradient(cat['gradient']),
                    'games': (cat['games'] as List?)
                            ?.map((game) => {
                                  'name': game['name'] ?? 'Unknown Game',
                                  'id_game': game['id_game'] ?? 0,
                                })
                            .toList() ??
                        [],
                    'image': cat['image'] ?? 'assets/img/default.jpg',
                  })
              .toList();
        });
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      print('Fetch Categories Error: $e');
      _loadFallbackData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDiscussions() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/discussions'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          discussions = data
              .map((disc) => {
                    'title': disc['title'] ?? 'No Title',
                    'author': disc['author'] ?? 'Anonymous',
                    'replies': disc['replies'] ?? 0,
                    'time': disc['time'] ?? 'Unknown',
                    'category': disc['category'] ?? 'Unknown',
                  })
              .toList();
        });
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      print('Fetch Discussions Error: $e');
      _loadFallbackData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchEvents() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/events'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          events = data
              .map((event) => {
                    'title': event['title'] ?? 'No Title',
                    'date': event['date'] ?? 'Unknown',
                    'prize': event['prize'] ?? 'N/A',
                    'color': _getColorFromName(event['category'] ?? 'Unknown'),
                    'gradient': _parseGradient(event['gradient']),
                    'image': event['image'] ?? 'assets/img/default.jpg',
                  })
              .toList();
        });
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      print('Fetch Events Error: $e');
      _loadFallbackData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadFallbackData() {
    setState(() {
      categories = [
        {
          "name": "MOBA",
          "icon": Icons.sports_esports,
          "color": Colors.blue,
          "gradient": [Color(0xFF2196F3), Color(0xFF1976D2)],
          "games": [
            {"name": "Mobile Legends", "id_game": 1},
            {"name": "League of Legends", "id_game": 2},
            {"name": "Dota 2", "id_game": 3},
          ],
          "image": "assets/img/moba.jpg",
        },
        {
          "name": "FPS",
          "icon": Icons.gps_fixed,
          "color": Colors.red,
          "gradient": [Color(0xFFE53935), Color(0xFFD32F2F)],
          "games": [
            {"name": "Valorant", "id_game": 4},
            {"name": "CS:GO", "id_game": 5},
            {"name": "Call of Duty", "id_game": 6},
          ],
          "image": "assets/img/fps.jpg",
        },
        {
          "name": "RPG",
          "icon": Icons.auto_stories,
          "color": Colors.purple,
          "gradient": [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          "games": [
            {"name": "Genshin Impact", "id_game": 7},
            {"name": "Elden Ring", "id_game": 8},
            {"name": "Final Fantasy", "id_game": 9},
          ],
          "image": "assets/img/rpg.jpg",
        },
        {
          "name": "Battle Royale",
          "icon": Icons.map,
          "color": Colors.orange,
          "gradient": [Color(0xFFFF9800), Color(0xFFF57C00)],
          "games": [
            {"name": "PUBG", "id_game": 10},
            {"name": "Fortnite", "id_game": 11},
            {"name": "Apex Legends", "id_game": 12},
          ],
          "image": "assets/img/battle_royale.jpg",
        },
      ];
      discussions = [
        {
          "title": "Best MOBA Strategies 2025",
          "author": "ProGamer123",
          "replies": 42,
          "time": "2h ago",
          "category": "MOBA",
        },
        {
          "title": "Valorant New Update Discussion",
          "author": "FPSMaster",
          "replies": 28,
          "time": "5h ago",
          "category": "FPS",
        },
        {
          "title": "RPG Hidden Gems",
          "author": "AdventureSeeker",
          "replies": 15,
          "time": "1d ago",
          "category": "RPG",
        },
      ];
      events = [
        {
          "title": "Mobile Legends Tournament",
          "date": "June 20, 2025",
          "prize": "\$1,000",
          "color": Colors.blue,
          "gradient": [Color(0xFF2196F3), Color(0xFF1976D2)],
          "image": "assets/img/event1.jpg",
        },
        {
          "title": "Valorant Championship",
          "date": "July 5, 2025",
          "prize": "\$2,500",
          "color": Colors.red,
          "gradient": [Color(0xFFE53935), Color(0xFFD32F2F)],
          "image": "assets/img/event2.jpg",
        },
      ];
    });
  }

  List<Color> _parseGradient(dynamic gradientData) {
    if (gradientData == null) return [];
    if (gradientData is List) {
      return gradientData.map((color) {
        if (color is int) {
          return Color(color); // Handle integer color codes (e.g., 0xFF2196F3)
        } else if (color is String) {
          return Color(int.parse(color.replaceAll('#', '0xFF'))); // Handle hex strings
        }
        return Colors.grey; // Default fallback
      }).cast<Color>().toList();
    }
    return [Colors.grey]; // Default fallback if not a list
  }

  void _showGamesDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category["gradient"] as List<Color>? ??
                    [
                      category["color"] ?? Colors.blue,
                      (category["color"] ?? Colors.blue).withOpacity(0.7)
                    ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (category["color"] ?? Colors.blue).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category["icon"] ?? Icons.games,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${category["name"]} Games",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              category["description"] ?? "No description",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: category["games"].length,
                    itemBuilder: (context, index) {
                      final game = category["games"][index];
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF374151) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (category["color"] ?? Colors.blue)
                                .withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatGroupScreen(
                                  game: game["name"],
                                  idGame: game["id_game"],
                                  category: {
                                    "color": category["color"] ?? Colors.blue,
                                    "gradient": category["gradient"] as List<Color>? ??
                                        [
                                          category["color"] ?? Colors.blue,
                                          (category["color"] ?? Colors.blue)
                                              .withOpacity(0.7)
                                        ],
                                    "icon": category["icon"] ?? Icons.games,
                                    "description": category["description"] ??
                                        "No description",
                                  },
                                ),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: category["gradient"] as List<Color>? ??
                                    [
                                      category["color"] ?? Colors.blue,
                                      (category["color"] ?? Colors.blue)
                                          .withOpacity(0.7)
                                    ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                game["name"][0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            game["name"],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            "${game["players"] ?? 'Unknown players'} active players",
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: category["color"] ?? Colors.blue,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 100 * index))
                          .slideX(begin: 0.3, end: 0);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1))
            .fadeIn(duration: Duration(milliseconds: 300));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color(0xFF0F172A), Color(0xFF1E293B)]
                : [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _headerAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(_headerAnimation),
                    child: Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [Color(0xFF1F2937), Color(0xFF374151)]
                              : [Colors.white, Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Forum Page",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF8B5CF6)
                                      ],
                                    ).createShader(
                                        Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Connect • Play • Compete",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildHeaderButton(Icons.search, () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Search functionality coming soon!')),
                                );
                              }),
                              SizedBox(width: 8),
                              _buildHeaderButton(Icons.filter_list, () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Filter functionality coming soon!')),
                                );
                              }),
                              SizedBox(width: 8),
                              _buildHeaderButton(Icons.person_add, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FindFriendsScreen()),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Game Categories",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      _isLoading && categories.isEmpty
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: Colors.blue))
                          : CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 0.85,
                                aspectRatio: 16 / 9,
                                autoPlayInterval: Duration(seconds: 4),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeFactor: 0.3,
                              ),
                              items: categories.map((category) {
                                return GestureDetector(
                                  onTap: () => _showGamesDialog(category),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              (category["color"] ?? Colors.blue)
                                                  .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: category["gradient"]
                                                      as List<Color>? ??
                                                  [
                                                    category["color"] ??
                                                        Colors.blue,
                                                    (category["color"] ??
                                                            Colors.blue)
                                                        .withOpacity(0.7)
                                                  ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withOpacity(0.3),
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        category["icon"] ??
                                                            Icons.games,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            category["name"],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Inter',
                                                            ),
                                                          ),
                                                          Text(
                                                            category[
                                                                    "description"] ??
                                                                "No description",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.8),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "${category["games"].length} games available",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.7),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trending Discussions",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('View all discussions tapped!')),
                              );
                            },
                            icon: Icon(Icons.trending_up, size: 16),
                            label: Text("View All"),
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _isLoading && discussions.isEmpty
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: Colors.blue))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: discussions.length,
                              itemBuilder: (context, index) {
                                final discussion = discussions[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.08),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                        discussion["category"])
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _getCategoryColor(
                                                          discussion[
                                                              "category"])
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                discussion["category"],
                                                style: TextStyle(
                                                  color: _getCategoryColor(
                                                      discussion["category"]),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              discussion["time"],
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          discussion["title"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            height: 1.3,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getCategoryColor(
                                                        discussion["category"]),
                                                    _getCategoryColor(
                                                            discussion[
                                                                "category"])
                                                        .withOpacity(0.7),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  discussion["author"][0],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                discussion["author"],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            _buildStatButton(
                                                Icons.chat_bubble_outline,
                                                discussion["replies"]
                                                    .toString()),
                                            SizedBox(width: 16),
                                            _buildStatButton(
                                                Icons.favorite_outline,
                                                "0"), // Placeholder for likes
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        delay:
                                            Duration(milliseconds: 200 * index))
                                    .slideY(begin: 0.3, end: 0);
                              },
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Events",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      _isLoading && events.isEmpty
                          ? Center(
                              child:
                                  CircularProgressIndicator(color: Colors.blue))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (event["color"] ?? Colors.blue)
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: event["gradient"]
                                                    as List<Color>? ??
                                                [
                                                  event["color"] ?? Colors.blue,
                                                  (event["color"] ??
                                                          Colors.blue)
                                                      .withOpacity(0.7)
                                                ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      Container(
                                        height: 180,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                    0.9), // Placeholder status
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                "Registration Open", // Placeholder status
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              event["title"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                height: 1.2,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildEventInfo(
                                                          Icons.calendar_today,
                                                          "${event["date"]}"),
                                                      SizedBox(height: 4),
                                                      _buildEventInfo(
                                                          Icons.attach_money,
                                                          "Prize Pool: ${event["prize"]}"),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    "Join Now",
                                                    style: TextStyle(
                                                      color: event["color"] ??
                                                          Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
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
                                    .fadeIn(
                                        delay:
                                            Duration(milliseconds: 300 * index))
                                    .slideX(
                                        begin: index.isEven ? -0.3 : 0.3,
                                        end: 0);
                              },
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Create new post tapped!'),
                backgroundColor: Color(0xFF3B82F6),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ).animate().scale(delay: Duration(milliseconds: 800)),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF374151) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon,
            color: isDark ? Colors.grey[300] : Colors.grey[700], size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStatButton(IconData icon, String count) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 14,
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "MOBA":
        return Colors.blue;
      case "FPS":
        return Colors.red;
      case "RPG":
        return Colors.purple;
      case "Battle Royale":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case "MOBA":
        return Icons.sports_esports;
      case "FPS":
        return Icons.gps_fixed;
      case "RPG":
        return Icons.auto_stories;
      case "Battle Royale":
        return Icons.map;
      default:
        return Icons.games;
    }
  }

  Color _getColorFromName(String name) {
    switch (name) {
      case "MOBA":
        return Colors.blue;
      case "FPS":
        return Colors.red;
      case "RPG":
        return Colors.purple;
      case "Battle Royale":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}