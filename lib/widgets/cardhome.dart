import 'package:flutter/material.dart';
Widget buildMenuGrid(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return GridView.count(
    shrinkWrap: true,
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 2.5,
    physics: NeverScrollableScrollPhysics(),
    children: [
      _buildMenuCard(context, Icons.computer, "BO Warnet", Colors.blueAccent, () {
          Navigator.pushNamed(context, '/boking');
      }),
      _buildMenuCard(context, Icons.sports_esports, "Booking PS", Colors.purpleAccent, () {
         Navigator.pushNamed(context, '/sewaps');
      }),
      _buildMenuCard(context, Icons.monetization_on, "Top-Up", Colors.greenAccent, () {
    Navigator.pushNamed(context, '/topup');
      }),
      _buildMenuCard(context, Icons.shield, "Jasa Joki", Colors.orangeAccent, () {
       Navigator.pushNamed(context, '/joki');
      }),
    ],
  );
}

Widget _buildMenuCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? Color(0xFF262A50) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 8,
          spreadRadius: 2,
          offset: Offset(2, 4),
        ),
      ],
    ),
    child: InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}