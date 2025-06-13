import 'package:flutter/material.dart';
import '../widgets/clipper.dart';
import '../main.dart'; // Relative import for theme toggle
import 'JokiFormPage.dart'; // Import the form page

class JasaJokiPage extends StatelessWidget {
  const JasaJokiPage({super.key});

  // Same game list as TopUpPage
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D40),
        elevation: 0,
        title: const Text(
          "Jasa Joki",
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
                          // Navigate to JokiFormPage with the selected game name
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => JokiServicePage(gameName: game["name"]),
                            ),
                          );
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
}