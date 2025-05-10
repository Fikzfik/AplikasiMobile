import 'package:flutter/material.dart';

class Designpage extends StatefulWidget {
  @override
  _DesignPageState createState() => _DesignPageState();
}

class _DesignPageState extends State<Designpage> {
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
        {"name": "Valorant", "image": "assets/img/valorant.jpg"},
        {"name": "CS:GO", "image": "assets/img/csgo.jpg"},
        {"name": "Call of Duty", "image": "assets/img/cod.jpg"}
      ]
    },
    {
      "name": "RPG",
      "image": "assets/img/rpg.jpg",
      "games": [
        {"name": "Genshin Impact", "image": "assets/img/genshin.jpg"},
        {"name": "Elden Ring", "image": "assets/img/eldenring.jpg"},
        {"name": "Final Fantasy", "image": "assets/img/ff.jpg"}
      ]
    },
    {
      "name": "Battle Royale",
      "image": "assets/img/battle_royale.jpg",
      "games": [
        {"name": "PUBG", "image": "assets/img/pubg.jpg"},
        {"name": "Fortnite", "image": "assets/img/fortnite.jpg"},
        {"name": "Apex Legends", "image": "assets/img/apex.jpg"}
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Categories"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: gameCategories.length,
          itemBuilder: (context, index) {
            final category = gameCategories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      category["image"],
                      width: 50,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    category["name"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: category["games"].map<Widget>((game) {
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
                      title: Text(game["name"]),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
