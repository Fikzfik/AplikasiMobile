import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'PsUnitListPage.dart';
import 'PsRentalState.dart';

class PsSelectionPage extends StatelessWidget {
  final List<Map<String, dynamic>> psLocations = [
    {
      "name": "PlayZone Central",
      "address": "Jl. Sudirman No. 12, Jakarta",
      "image": "assets/img/ps1.png",
      "availableUnits": 5,
      "rating": 4.7,
    },
    {
      "name": "GameHub East",
      "address": "Jl. Thamrin No. 45, Jakarta",
      "image": "assets/img/ps2.png",
      "availableUnits": 7,
      "rating": 4.3,
    },
    {
      "name": "FunPlay South",
      "address": "Jl. Gatot Subroto No. 78, Jakarta",
      "image": "assets/img/ps3.png",
      "availableUnits": 9,
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
              'My PS Rental',
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
                // Toggle theme if ThemeProvider is defined
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
                            hintText: 'Search PS location...',
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
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16.0),
                    itemCount: psLocations.length,
                    itemBuilder: (context, index) {
                      final psLocation = psLocations[index];
                      return _buildPsCard(context, psLocation, theme, isDark);
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

  Widget _buildPsCard(BuildContext context, Map<String, dynamic> psLocation,
      ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PsUnitListPage(psLocation: psLocation["name"]!),
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
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.asset(
                  psLocation["image"]!,
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
                          psLocation["name"]!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${psLocation["rating"]}',
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
                      psLocation["address"]!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Available Units: ${psLocation["availableUnits"]}',
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
