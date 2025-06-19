import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/Home/Dashboard/DashboardPage.dart';
import 'package:fikzuas/pages/home/chat/CommunityPage.dart';
import 'package:fikzuas/pages/home/history/HistoryPage.dart';
import 'package:fikzuas/pages/home/profile/SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['selectedIndex'] != null) {
      print('Received selectedIndex: ${args['selectedIndex']}');
      setState(() {
        _selectedIndex = args['selectedIndex'] as int;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(),
          CommunityChat(),
          HistoryPage(
              refreshOnLoad:
                  ModalRoute.of(context)?.settings.arguments != null &&
                      (ModalRoute.of(context)!.settings.arguments
                              as Map?)?['refreshOnLoad'] ==
                          true),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0,
                  Theme.of(context).colorScheme.primary, isDark),
              _buildNavItem(
                  Icons.chat_bubble, "Chat", 1, Colors.redAccent, isDark),
              _buildNavItem(
                  Icons.history, "Activity", 2, Colors.orangeAccent, isDark),
              _buildNavItem(
                  Icons.person, "Profile", 3, Colors.blueAccent, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color color, bool isDark) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? color
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
