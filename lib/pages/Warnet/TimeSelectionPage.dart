import 'dart:ui';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

// Assuming BookingState is defined elsewhere; include its import if needed
// import 'package:fikzuas/states/BookingState.dart';

class TimeSelectionState with ChangeNotifier {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedDuration; // Durasi peminjaman dalam jam
  bool isLoading = false;

  // Simulasi data booking: jam yang sudah dipesan pada tanggal tertentu
  final List<Map<String, dynamic>> bookedTimes = [
    {
      'start': TimeOfDay(hour: 13, minute: 0), // Booking dari 13:00
      'end': TimeOfDay(hour: 15, minute: 59), // Hingga 15:00
    },
    {
      'start': TimeOfDay(hour: 13, minute: 0), // Booking dari 13:00
      'end': TimeOfDay(hour: 15, minute: 0), // Hingga 15:00
    },
    // Tambahkan data booking lain jika diperlukan
  ];

  TimeSelectionState({this.selectedDate});

  void setSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void setSelectedDuration(int duration) {
    selectedDuration = duration;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  int getTotalPrice() {
    return (selectedDuration ?? 0) * 50000; // Harga per jam: IDR 50,000
  }

  // Fungsi untuk menghitung jam akhir berdasarkan jam mulai dan durasi
  TimeOfDay getEndTime() {
    if (selectedTime == null || selectedDuration == null) {
      return selectedTime ?? TimeOfDay(hour: 0, minute: 0);
    }
    int endHour = selectedTime!.hour + selectedDuration!;
    int endMinute = selectedTime!.minute;
    endHour = endHour % 24; // Handle jika melebihi 24 jam
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  // Fungsi untuk mengecek apakah ada tumpang tindih dengan booking yang sudah ada
  bool isTimeSlotAvailable(BuildContext context) {
    if (selectedTime == null || selectedDuration == null) {
      return false;
    }

    // Hitung rentang waktu yang dipilih pengguna
    final startMinutes = selectedTime!.hour * 60 + selectedTime!.minute;
    final endTime = getEndTime();
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Cek tumpang tindih dengan setiap booking yang sudah ada
    for (var booking in bookedTimes) {
      final bookedStart = booking['start'] as TimeOfDay;
      final bookedEnd = booking['end'] as TimeOfDay;

      final bookedStartMinutes = bookedStart.hour * 60 + bookedStart.minute;
      final bookedEndMinutes = bookedEnd.hour * 60 + bookedEnd.minute;

      // Logika tumpang tindih: jika rentang waktu yang dipilih tumpang tindih dengan rentang waktu yang sudah dipesan
      if ((startMinutes < bookedEndMinutes && endMinutes > bookedStartMinutes)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "The selected time slot (${selectedTime!.format(context)} - ${endTime.format(context)}) overlaps with an existing booking (${bookedStart.format(context)} - ${bookedEnd.format(context)})!",
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return false;
      }
    }
    return true;
  }
}

class TimeSelectionPage extends StatelessWidget {
  final String warnetName;
  final int pcNumber;
  final DateTime selectedDate;

  const TimeSelectionPage({
    Key? key,
    required this.warnetName,
    required this.pcNumber,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeSelectionState(selectedDate: selectedDate),
      child: Consumer<TimeSelectionState>(
        builder: (context, timeState, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Latar belakang dengan efek wave clipper
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: Theme.of(context).brightness == Brightness.dark
                                ? [
                                    Color(0xFF2C2F50),
                                    Color(0xFF1A1D40).withOpacity(0.9),
                                  ]
                                : [
                                    Color(0xFF3A3D60),
                                    Color(0xFF2C2F50).withOpacity(0.85),
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // AppBar Custom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white70,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'Select Booking Time',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms),
                            SizedBox(width: 48),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Info PC yang dipilih
                        Text(
                          'Booking PC $pcNumber at $warnetName on ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        SizedBox(height: 16),
                        // Tampilan jam yang sudah dipesan
                        timeState.bookedTimes.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Booked Times:",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ).animate().fadeIn(duration: 600.ms),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: timeState.bookedTimes.map((booking) {
                                      final start = booking['start'] as TimeOfDay;
                                      final end = booking['end'] as TimeOfDay;
                                      return Chip(
                                        label: Text(
                                          "${start.format(context)} - ${end.format(context)}",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        elevation: 2,
                                        shadowColor: Colors.black26,
                                      ).animate().fadeIn(duration: 600.ms);
                                    }).toList(),
                                  ),
                                ],
                              )
                            : Text(
                                "No bookings yet for this date.",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ).animate().fadeIn(duration: 600.ms),
                        SizedBox(height: 24),
                        // Field untuk memilih jam
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              timeState.setSelectedTime(time);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.5),
                                width: 2,
                              ),
                              gradient: LinearGradient(
                                colors: Theme.of(context).brightness == Brightness.dark
                                    ? [Color(0xFF1A1440), Color(0xFF262A50)]
                                    : [Colors.grey[300]!, Colors.grey[200]!],
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.blueAccent, size: 20),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    timeState.selectedTime == null
                                        ? "Select Time"
                                        : timeState.selectedTime!.format(context),
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: timeState.selectedTime == null
                                          ? (Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white70
                                              : Colors.black54)
                                          : (Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black87),
                                      fontWeight: timeState.selectedTime == null
                                          ? FontWeight.normal
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
                        SizedBox(height: 16),
                        // Input Durasi
                        TextField(
                          onChanged: (value) {
                            final duration = int.tryParse(value) ?? 0;
                            if (duration > 0) {
                              timeState.setSelectedDuration(duration);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Duration (hours)",
                            labelStyle: TextStyle(
                              fontFamily: "Poppins",
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            prefixIcon: Icon(Icons.hourglass_empty, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blueAccent.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blueAccent.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Color(0xFF1A1440)
                                : Colors.grey[300],
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0, delay: 100.ms),
                        SizedBox(height: 12),
                        // Total Harga
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.5),
                              width: 2,
                            ),
                            gradient: LinearGradient(
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? [Color(0xFF1A1440), Color(0xFF262A50)]
                                  : [Colors.grey[300]!, Colors.grey[200]!],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, color: Colors.blueAccent),
                                  SizedBox(width: 12),
                                  Text(
                                    "Total Price",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "IDR ${timeState.getTotalPrice()}",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0, delay: 200.ms),
                        SizedBox(height: 24),
                        // Tombol Next
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            child: ElevatedButton(
                              onPressed: timeState.selectedTime != null && timeState.selectedDuration != null
                                  ? () {
                                      if (timeState.isTimeSlotAvailable(context)) {
                                        timeState.setLoading(true);
                                        _showPaymentDialog(context, timeState);
                                        timeState.setLoading(false);
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: timeState.selectedTime != null && timeState.selectedDuration != null
                                        ? [Colors.purpleAccent, Colors.blueAccent]
                                        : [Colors.grey[600]!, Colors.grey[700]!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: timeState.selectedTime != null && timeState.selectedDuration != null
                                          ? Colors.purpleAccent.withOpacity(0.4)
                                          : Colors.grey.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  child: Center(
                                    child: timeState.isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Next',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms).scale(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, TimeSelectionState timeState) {
    final bookingState = Provider.of<BookingState>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final lightModeBackground = Color.alphaBlend(
          Colors.black.withOpacity(0.15),
          Colors.grey[200]!,
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Color(0xFF262A50), Color(0xFF1A1440)]
                    : [lightModeBackground, lightModeBackground],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Confirm PC Rental",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      SizedBox(height: 12),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: 4,
                        width: 300,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF1A1440) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.pinkAccent],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      SizedBox(height: 16),
                      Text(
                        "Warnet: $warnetName",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "PC: $pcNumber",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Time: ${timeState.selectedTime?.format(context) ?? 'Not selected'}",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Duration: ${timeState.selectedDuration ?? 0} hours",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Total: IDR ${timeState.getTotalPrice()}",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (timeState.selectedTime != null && timeState.selectedDuration != null) {
                            timeState.setLoading(true);
                            Future.delayed(Duration(seconds: 2), () {
                              // Update the booking state to reserve the PC
                              bookingState.bookSlot(warnetName, pcNumber);
                              // Pop the dialog and TimeSelectionPage
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Back to PcListPage
                              Navigator.pop(context); // Back to WarnetSelectionPage
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Rental for PC $pcNumber at $warnetName confirmed! Total: IDR ${timeState.getTotalPrice()}",
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              timeState.setLoading(false);
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select time and duration!",
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: timeState.isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Confirm Booking",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ).animate().fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOut).fadeIn(duration: 400.ms);
      },
    );
  }
}

// Custom Clipper untuk efek wave
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 50);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 150);
    var secondEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}