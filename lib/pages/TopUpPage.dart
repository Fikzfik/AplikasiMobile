import 'package:flutter/material.dart';
import '../widgets/clipper.dart';

class TopUpPage extends StatelessWidget {
  // Flattened list of games
  final List<Map<String, dynamic>> games = [
    {"name": "Mobile Legends", "image": "assets/ml.jpg"},
    {"name": "League of Legends", "image": "assets/lol.jpg"},
    {"name": "Dota 2", "image": "assets/dota2.jpg"},
    {"name": "Valorant", "image": "assets/valorant.png"},
    {"name": "CS:GO", "image": "assets/csgo.png"},
    {"name": "Call of Duty", "image": "assets/cod.jpg"},
    {"name": "Genshin Impact", "image": "assets/genshin.jpg"},
    {"name": "Elden Ring", "image": "assets/eldenring.png"},
    {"name": "Final Fantasy", "image": "assets/ff.png"},
    {"name": "PUBG", "image": "assets/pubg.jpg"},
    {"name": "Fortnite", "image": "assets/fortnite.jpg"},
    {"name": "Apex Legends", "image": "assets/apex.png"},
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
            color: Colors.white70,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 300,
              child: ClipPath(
                clipper: DiagonalClipper(),
                child: Container(color: const Color(0xFF2C2F50)),
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
                        "Select Game",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 columns for 3x3
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0, // Square items
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = games[index];
                      return GestureDetector(
                        onTap: () {
                          _showTopUpForm(context, game["name"], isDark);
                        },
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
                                color: Colors.black.withOpacity(0.5),
                              ),
                              Center(
                                child: Text(
                                  game["name"],
                                  style: const TextStyle(
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  void _showTopUpForm(BuildContext context, String gameName, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF262A50) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "Top-Up $gameName",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262A50) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Game ID",
                    labelStyle: TextStyle(fontFamily: "Poppins"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Top-Up Amount",
                    labelStyle: TextStyle(fontFamily: "Poppins"),
                    border: OutlineInputBorder(),
                  ),
                  items: ["50K", "100K", "200K", "500K"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontFamily: "Poppins",
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print("Top-up confirmed for $gameName");
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            child: const Text(
              "Confirm Top-Up",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}