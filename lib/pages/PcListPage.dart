import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/WarnetSelectionPage.dart';

class PcListPage extends StatelessWidget {
  final String warnetName;

  const PcListPage({Key? key, required this.warnetName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingState>(
      builder: (context, bookingState, child) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        final pcSlots = bookingState.warnetPcSlots[warnetName]!;

        return Scaffold(
          appBar: AppBar(
            title: Text('$warnetName PCs'),
            backgroundColor: isDark ? Color(0xFF2C2F50) : Colors.blue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: pcSlots.length,
            itemBuilder: (context, index) {
              final pcNumber = index + 1;
              final isAvailable = pcSlots[index];
              return Card(
                color: isDark ? Color(0xFF1A1D40) : Colors.white,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.computer,
                    color: isAvailable ? (isDark ? Colors.green : Colors.green[700]) : (isDark ? Colors.red : Colors.red[700]),
                  ),
                  title: Text(
                    'PC $pcNumber',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: isAvailable
                        ? () {
                            bookingState.bookSlot(warnetName, pcNumber);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('PC $pcNumber booked!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable ? Colors.blue : Colors.grey,
                    ),
                    child: Text('Book'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}