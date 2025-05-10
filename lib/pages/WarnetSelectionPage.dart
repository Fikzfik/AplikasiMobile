import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/pages/PcListPage.dart';
import 'package:fikzuas/main.dart';

class BookingState with ChangeNotifier {
  Map<String, List<bool>> warnetPcSlots = {
    "CyberNet Central": List<bool>.filled(5, true), // 5 PCs
    "GamerZone East": List<bool>.filled(7, true), // 7 PCs
    "NetPlay South": List<bool>.filled(9, true), // 9 PCs
  };

  void bookSlot(String warnetName, int index) {
    warnetPcSlots[warnetName]![index - 1] = false;
    notifyListeners();
  }

  int getAvailableSlots(String warnetName) {
    return warnetPcSlots[warnetName]!.where((slot) => slot).length;
  }
}

class WarnetSelectionPage extends StatelessWidget {
  final List<Map<String, dynamic>> warnetLocations = [
    {
      "name": "CyberNet Central",
      "address": "Jl. Sudirman No. 12, Jakarta",
      "image": "assets/img/net1.png",
      "availablePcs": 5,
      "rating": 4.7,
    },
    {
      "name": "GamerZone East",
      "address": "Jl. Thamrin No. 45, Jakarta",
      "image": "assets/img/net2.png",
      "availablePcs": 7,
      "rating": 4.3,
    },
    {
      "name": "NetPlay South",
      "address": "Jl. Gatot Subroto No. 78, Jakarta",
      "image": "assets/img/net3.png",
      "availablePcs": 9,
      "rating": 4.5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Warnet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : theme.colorScheme.primary,
              ),
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white70 : theme.colorScheme.primary,
              ),
              onPressed: () {
                // Pastikan ThemeProvider sudah didefinisikan
                // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                // Jika ThemeProvider belum ada, komentar ini atau definisikan ThemeProvider
              },
            ),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF2C2F50) : Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [theme.colorScheme.primary, theme.scaffoldBackgroundColor]
                : [Colors.grey[200]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                // Search Bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Color(0xFF2C2F50).withOpacity(0.3)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: isDark ? Colors.white70 : Colors.black54),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search warnet...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.tune,
                          color: isDark ? Colors.white70 : Colors.black54),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                // List of Warnet Cards
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16.0),
                    itemCount: warnetLocations.length,
                    itemBuilder: (context, index) {
                      final warnet = warnetLocations[index];
                      return _buildWarnetCard(context, warnet, theme, isDark);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarnetCard(BuildContext context, Map<String, dynamic> warnet,
      ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => BookingState(),
              child: PcListPage(warnetName: warnet["name"]!),
            ),
          ),
        );
      },
      child: Card(
        elevation: theme.cardTheme.elevation ?? 5,
        shape: theme.cardTheme.shape,
        margin: EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Warnet
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.asset(
                  warnet["image"]!,
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150.0,
                      color: Colors.grey,
                      child: Center(child: Text('Image not found')),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          warnet["name"]!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${warnet["rating"]}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Icon(
                              Icons.star,
                              size: 16.0,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      warnet["address"]!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Available PCs: ${warnet["availablePcs"]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}