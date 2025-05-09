import 'package:flutter/material.dart';
import '../main.dart'; // For theme toggle

class JokiFormPage extends StatelessWidget {
  final String gameName;

  const JokiFormPage({super.key, required this.gameName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D40),
        elevation: 0,
        title: Text(
          "Joki for $gameName",
          style: const TextStyle(
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
              child: Container(color: const Color(0xFF2C2F50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  "Hire a Gaming Pro for $gameName",
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262A50) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Game ID",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Initial Rank",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Target Rank",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          print("Joki service confirmed for $gameName");
                          Navigator.pop(context); // Go back after confirmation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Confirm Joki",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}