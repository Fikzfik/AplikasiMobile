import 'package:flutter/material.dart';
import 'package:fikzuas/pages/DashboardPage.dart';
import 'package:fikzuas/pages/CommunityPage.dart';
import 'package:fikzuas/pages/HistoryPage.dart';
import 'package:fikzuas/pages/SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Color(0xFF2C2F50),
              scaffoldBackgroundColor: Color(0xFF121212),
              colorScheme: ColorScheme.dark(
                primary: Color(0xFF2C2F50),
                secondary: Colors.purpleAccent,
                background: Color(0xFF121212),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
              cardTheme: CardTheme(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Color(0xFF1A1D40),
              scaffoldBackgroundColor: Colors.grey[100],
              colorScheme: ColorScheme.light(
                primary: Color(0xFF1A1D40),
                secondary: Colors.purpleAccent,
                background: Colors.grey[100]!,
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
              cardTheme: CardTheme(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            DashboardPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
            CommunityChat(),
            HistoryPage(),
            SettingsPage(),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Color(0xFF1A1D40),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", 0, Colors.purpleAccent, isDark),
                _buildNavItem(Icons.chat_bubble, "Chat", 1, Colors.redAccent, isDark),
                _buildNavItem(Icons.history, "Activity", 2, Colors.orangeAccent, isDark),
                _buildNavItem(Icons.person, "Profile", 3, Colors.blueAccent, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color color, bool isDark) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.white70,
                size: 28,
              ),
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}