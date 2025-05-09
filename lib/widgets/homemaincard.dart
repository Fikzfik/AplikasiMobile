import 'package:flutter/material.dart';

Widget buildMainCard(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: isDark ? Color(0xFF262A50) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.5),
          blurRadius: 10,
          spreadRadius: 2,
          offset: Offset(2, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Saldo",
          style: TextStyle(
            fontFamily: "Poppins",
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "\$4,560",
          style: TextStyle(
            fontFamily: "Poppins",
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionIcon(context, Icons.upload, "Send"),
            _buildActionIcon(context, Icons.download, "Receive"),
            _buildActionIcon(context, Icons.attach_money, "Loan"),
            _buildActionIcon(context, Icons.add_card, "Top-Up"),
          ],
        ),
      ],
    ),
  );
}

Widget _buildActionIcon(BuildContext context, IconData icon, String label) {
  final theme = Theme.of(context);
  return Column(
    children: [
      Icon(icon, size: 30, color: Colors.purpleAccent),
      SizedBox(height: 5),
      Text(
        label,
        style: TextStyle(
          fontFamily: "Poppins",
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
    ],
  );
}
