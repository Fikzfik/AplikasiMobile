import 'package:flutter/material.dart';
import '../widgets/clipper.dart';

class SewaPsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1D40),
        elevation: 0,
        title: Text(
          "Sewa PS",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white70),
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
                child: Container(color: Color(0xFF2C2F50)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rent a PlayStation",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF262A50) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "PS Type",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(),
                        ),
                        items: ["PS4", "PS5"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Rental Duration (hours)",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle rental logic
                          print("PS rental confirmed");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Confirm Rental",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            color: Colors.white,
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