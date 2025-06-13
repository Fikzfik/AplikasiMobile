import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      "image": "assets/img/moba.jpg",
      "games": [
        {"name": "Mobile Legends", "image": "assets/img/ml.jpg"},
        {"name": "League of Legends", "image": "assets/img/lol.jpg"},
        {"name": "Dota 2", "image": "assets/img/dota2.jpg"}
      ]
    },
    {
      "name": "FPS",
      "image": "assets/img/fps.jpg",
      "games": [
        {"name": "Valorant", "image": "assets/img/valorant.png"},
        {"name": "CS:GO", "image": "assets/img/csgo.png"},
        {"name": "Call of Duty", "image": "assets/img/cod.jpg"}
      ]
    },
    {
      "name": "RPG",
      "image": "assets/img/rpg.jpg",
      "games": [
        {"name": "Genshin Impact", "image": "assets/img/genshin.jpg"},
        {"name": "Elden Ring", "image": "assets/img/eldenring.png"},
        {"name": "Final Fantasy", "image": "assets/img/ff.png"}
      ]
    },
    {
      "name": "Battle Royale",
      "image": "assets/img/battle_royale.jpeg",
      "games": [
        {"name": "PUBG", "image": "assets/img/pubg.jpg"},
        {"name": "Fortnite", "image": "assets/img/fortnite.jpg"},
        {"name": "Apex Legends", "image": "assets/img/apex.png"}
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
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Featured Communities',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildCommunityCarousel(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Select Categories',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildCategoryGrid(context),
                ),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Recent Discussions',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ...recentDiscussions.map((discussion) => ScaleTransition(
                      scale: _scaleAnimation,
                      child: buildDiscussionCard(context, discussion),
                    )).toList(),
                SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Join Events',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                SizedBox(height: 12),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildEventCard(context),
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
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
              backgroundImage: NetworkImage("https://picsum.photos/id/798/200/300"),
            ),
            SizedBox(width: 12),
            Text(
              "Welcome, Gamer!",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildCommunityCarousel(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      height: 160,
      child: Swiper(
        itemBuilder: (context, index) {
          final category = gameCategories[index % gameCategories.length];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    category["image"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      category["name"],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: gameCategories.length,
        autoplay: true,
        autoplayDelay: 4000,
        viewportFraction: 0.85,
        scale: 0.9,
      ),
    );
  }

  Widget buildCategoryGrid(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return StaggeredGrid.count(
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: gameCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: index.isEven ? 2.0 : 1.8,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    "${category["name"]} Games",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
                      child: Text("Close", style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            },
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      category["image"],
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  Center(
                    child: Text(
                      category["name"],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildDiscussionCard(BuildContext context, Map<String, String> discussion) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          discussion["title"]!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${discussion["category"]} • ${discussion["lastPost"]}",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${discussion["title"]} discussion')),
          );
        },
      ),
    ).animate().fadeIn(duration: 800.ms).scale(duration: 800.ms);
  }

  Widget buildEventCard(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Weekly Gaming Tournament",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              "Join our weekly event and compete with other gamers! Prizes await.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
            ),
            SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registered for the tournament!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text("Join Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}