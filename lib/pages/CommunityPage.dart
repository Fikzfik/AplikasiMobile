import 'dart:convert';

import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_group_screen.dart'; // Import ChatGroupScreen
import 'find_friends_screen.dart'; // Import FindFriendsScreen
import 'package:http/http.dart' as http;

class CommunityChat extends StatefulWidget {
  @override
  _CommunityChatState createState() => _CommunityChatState();
}

class _CommunityChatState extends State<CommunityChat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> categories = [
    {
      "name": "MOBA",
      "icon": Icons.sports_esports,
      "color": Colors.blue,
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
      "games": [
        {"name": "PUBG", "id_game": 10},
        {"name": "Fortnite", "id_game": 11},
        {"name": "Apex Legends", "id_game": 12},
      ],
      "image": "assets/img/battle_royale.jpg",
    },
  ];

  final List<Map<String, dynamic>> discussions = [
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

  final List<Map<String, dynamic>> events = [
    {
      "title": "Mobile Legends Tournament",
      "date": "June 20, 2025",
      "prize": "\$1,000",
      "color": Colors.blue,
      "image": "assets/img/event1.jpg",
    },
    {
      "title": "Valorant Championship",
      "date": "July 5, 2025",
      "prize": "\$2,500",
      "color": Colors.red,
      "image": "assets/img/event2.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showGamesDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? Color(0xFF1F2937) : Colors.white,
          title: Row(
            children: [
              Icon(
                category["icon"],
                color: category["color"],
              ),
              SizedBox(width: 8),
              Text(
                "${category["name"]} Games",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: category["games"].length,
              itemBuilder: (context, index) {
                final game = category["games"][index];
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatGroupScreen(
                          game: game["name"],
                          idGame: game["id_game"],
                        ),
                      ),
                    );
                  },
                  title: Text(
                    game["name"],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: category["color"].withOpacity(0.2),
                    child: Text(
                      game["name"][0],
                      style: TextStyle(
                        color: category["color"],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: category["color"],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Community",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
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
                            icon: Icon(Icons.filter_list, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Filter functionality coming soon!')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FindFriendsScreen()),
                              );
                            },
                            tooltip: 'Find Friends',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Game Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 16),
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
                        items: categories.map((category) {
                          return GestureDetector(
                            onTap: () => _showGamesDialog(category),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                                        category["image"],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  category["color"],
                                                  category["color"].withOpacity(0.7),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                          );
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
                                          category["name"],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          category["games"].map((game) => game["name"]).join(", "),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 100 * categories.indexOf(category)));
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Trending Discussions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('View all discussions tapped!')),
                          );
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: discussions.length,
                  itemBuilder: (context, index) {
                    final discussion = discussions[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(discussion["category"]).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    discussion["category"],
                                    style: TextStyle(
                                      color: _getCategoryColor(discussion["category"]),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  discussion["time"],
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              discussion["title"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: _getCategoryColor(discussion["category"]).withOpacity(0.2),
                                  child: Text(
                                    discussion["author"][0],
                                    style: TextStyle(
                                      color: _getCategoryColor(discussion["category"]),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  discussion["author"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "${discussion["replies"]}",
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 200 * index));
                  },
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Events",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
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
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      event["image"],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                event["color"],
                                                event["color"].withOpacity(0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event["title"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  event["date"],
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.8),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.attach_money,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Prize Pool: ${event["prize"]}",
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.8),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "Join",
                                          style: TextStyle(
                                            color: event["color"],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: Duration(milliseconds: 200 * index));
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create new post tapped!')),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
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
}

