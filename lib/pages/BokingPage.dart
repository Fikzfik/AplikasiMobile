import 'package:flutter/material.dart';
import '../widgets/clipper.dart'; // Assuming you have the DiagonalClipper

class BookingPage extends StatelessWidget {
  // Sample data for computer slots (true = available, false = occupied)
  final List<bool> computerSlots = [
    true, true, false, true, false, true, true, false, true, true
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1D40),
        elevation: 0,
        title: Text(
          "Booking",
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
          // Background Clip
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
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Book Your Gaming Session",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 computers per row
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1, // Square slots
                    ),
                    itemCount: computerSlots.length,
                    itemBuilder: (context, index) {
                      bool isAvailable = computerSlots[index];
                      return GestureDetector(
                        onTap: () {
                          if (isAvailable) {
                            _showBookingDialog(context, index + 1);
                          } else {
                            // Show notification for occupied slot
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "PC ${index + 1} is already occupied!",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isAvailable ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (isAvailable ? Colors.green : Colors.red)
                                    .withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "PC ${index + 1}",
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, int pcNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? Color(0xFF262A50) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Book PC $pcNumber",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "Date",
                    labelStyle: TextStyle(fontFamily: "Poppins"),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Color(0xFF1A1D40) : Colors.grey[200],
                  ),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Time",
                    labelStyle: TextStyle(fontFamily: "Poppins"),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Color(0xFF1A1D40) : Colors.grey[200],
                  ),
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Duration (hours)",
                    labelStyle: TextStyle(fontFamily: "Poppins"),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: isDark ? Color(0xFF1A1D40) : Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle booking logic here
                print("Booking confirmed for PC $pcNumber");
                Navigator.pop(context);
                // Optionally, update the computerSlots list to mark this PC as occupied
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}