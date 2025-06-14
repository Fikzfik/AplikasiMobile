// time_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimeSelectionPage extends StatefulWidget {
  final String warnetName;
  final int pcNumber;
  final DateTime selectedDate;
  final int warnetId;
  final int? pcId;
  final String pcName;
  final String pcSpecs;

  const TimeSelectionPage({
    Key? key,
    required this.warnetName,
    required this.pcNumber,
    required this.selectedDate,
    required this.warnetId,
    required this.pcId,
    required this.pcName,
    required this.pcSpecs,
  }) : super(key: key);

  @override
  _TimeSelectionPageState createState() => _TimeSelectionPageState();
}

class _TimeSelectionPageState extends State<TimeSelectionPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  TimeOfDay? selectedTime;
  int? selectedDuration;
  bool isLoading = false;
  List<Map<String, dynamic>> bookedTimes = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    _fetchBookedTimes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchBookedTimes() async {
    if (widget.pcId == null) {
      setState(() {
        errorMessage = 'PC ID is required';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        setState(() {
          errorMessage = 'Authentication required';
          isLoading = false;
        });
        return;
      }

      final url = 'http://10.0.2.2:8000/api/booked_pc?warnet_id=${widget.warnetId}&pc_id=${widget.pcId}&date=${widget.selectedDate.toIso8601String().split('T')[0]}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          setState(() {
            bookedTimes = List<Map<String, dynamic>>.from(data.map((item) {
              return {
                'start': TimeOfDay(
                  hour: int.parse(item['start_time'].split(':')[0]),
                  minute: int.parse(item['end_time'].split(':')[1]),
                ),
                'end': TimeOfDay(
                  hour: int.parse(item['end_time'].split(':')[0]),
                  minute: int.parse(item['end_time'].split(':')[1]),
                ),
              };
            }));
            isLoading = false;
          });
        } else {
          throw Exception('Response data is not a list');
        }
      } else {
        throw Exception('Failed to fetch booked times: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  int getTotalPrice() {
    return (selectedDuration ?? 0) * 50000;
  }

  TimeOfDay getEndTime() {
    if (selectedTime == null || selectedDuration == null) {
      return TimeOfDay(hour: 0, minute: 0);
    }
    
    int endHour = selectedTime!.hour + selectedDuration!;
    int endMinute = selectedTime!.minute;
    
    if (endHour >= 24) {
      endHour = endHour % 24;
    }
    
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  bool isTimeSlotAvailable() {
    if (selectedTime == null || selectedDuration == null) return false;

    final startMinutes = selectedTime!.hour * 60 + selectedTime!.minute;
    final endTime = getEndTime();
    final endMinutes = endTime.hour * 60 + endTime.minute;

    for (var booking in bookedTimes) {
      final bookedStart = booking['start'] as TimeOfDay;
      final bookedEnd = booking['end'] as TimeOfDay;
      final bookedStartMinutes = bookedStart.hour * 60 + bookedStart.minute;
      final bookedEndMinutes = bookedEnd.hour * 60 + bookedEnd.minute;

      if (startMinutes < bookedEndMinutes && endMinutes > bookedStartMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "The selected time slot (${selectedTime!.format(context)} - ${endTime.format(context)}) overlaps with an existing booking!",
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

  Future<void> _bookSlot() async {
    if (selectedTime == null || selectedDuration == null || widget.pcId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select time and duration!",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!isTimeSlotAvailable()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('id_user');
      
      if (token == null || userId == null) {
        throw Exception('Authentication required');
      }

      final startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      
      final endTime = startTime.add(Duration(hours: selectedDuration!));
      final totalPrice = getTotalPrice();

      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedStartTime = dateFormat.format(startTime);
      final formattedEndTime = dateFormat.format(endTime);

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/book_pcs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pc_id': widget.pcId,
          'id_user': userId,
          'start_time': formattedStartTime,
          'end_time': formattedEndTime,
          'booking_status': 'confirmed',
          'amount': totalPrice,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to book slot: ${response.statusCode}');
      }

      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/history', 
        (route) => route.settings.name == '/home',
        arguments: {'refreshOnLoad': true},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking confirmed! Your PC is reserved for ${selectedDuration} hours.",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to book: $e",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [Color(0xFF191B2F), Color(0xFF191B2F)]
                : [Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: isDark ? Colors.white : Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                      Text(
                        "Select Time",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      SizedBox(width: 40),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Booking info card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF262A43) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.computer_rounded,
                                color: primaryColor,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pcName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    widget.warnetName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Divider(color: isDark ? Colors.white12 : Colors.black12),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: isDark ? Colors.white60 : Colors.black54,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(widget.selectedDate),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.memory_rounded,
                              color: isDark ? Colors.white60 : Colors.black54,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.pcSpecs,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
                  
                  SizedBox(height: 24),
                  
                  // Booked times section
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  else if (errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Error: $errorMessage",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Already Booked Times",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ).animate().fadeIn(duration: 1000.ms),
                        SizedBox(height: 12),
                        bookedTimes.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "No bookings yet for this date!",
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 1000.ms)
                            : Container(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: bookedTimes.length,
                                  itemBuilder: (context, index) {
                                    final booking = bookedTimes[index];
                                    final start = booking['start'] as TimeOfDay;
                                    final end = booking['end'] as TimeOfDay;
                                    
                                    return Container(
                                      margin: EdgeInsets.only(right: 12),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_filled_rounded,
                                            color: Colors.red,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "${start.format(context)} - ${end.format(context)}",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(duration: 1000.ms + (index * 100).ms);
                                  },
                                ),
                              ),
                      ],
                    ),
                  
                  SizedBox(height: 24),
                  
                  // Time & Duration selection
                  Text(
                    "Select Time & Duration",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(duration: 1200.ms),
                  SizedBox(height: 16),
                  
                  // Time selection
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: primaryColor,
                                onPrimary: Colors.white,
                                surface: isDark ? Color(0xFF262A43) : Colors.grey[900]!,
                                onSurface: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF262A43) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Text(
                            selectedTime == null
                                ? "Select Start Time"
                                : "Start Time: ${selectedTime!.format(context)}",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 1300.ms).slideX(begin: -0.1, end: 0),
                  
                  SizedBox(height: 16),
                  
                  // Duration selection
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF262A43) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Duration (hours)",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [1, 2, 3, 4, 5].map((hours) {
                            final isSelected = selectedDuration == hours;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDuration = hours;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark ? Color(0xFF1F2236) : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  "$hours h",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white : Colors.black),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 1400.ms).slideX(begin: -0.1, end: 0),
                  
                  SizedBox(height: 24),
                  
                  // Booking summary
                  if (selectedTime != null && selectedDuration != null)
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF262A43) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Booking Summary",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildSummaryRow(
                            "Date",
                            DateFormat('EEEE, MMMM d, yyyy').format(widget.selectedDate),
                            Icons.calendar_today_rounded,
                            isDark,
                          ),
                          SizedBox(height: 8),
                          _buildSummaryRow(
                            "Time",
                            "${selectedTime!.format(context)} - ${getEndTime().format(context)}",
                            Icons.access_time_rounded,
                            isDark,
                          ),
                          SizedBox(height: 8),
                          _buildSummaryRow(
                            "Duration",
                            "$selectedDuration hours",
                            Icons.hourglass_top_rounded,
                            isDark,
                          ),
                          SizedBox(height: 8),
                          _buildSummaryRow(
                            "PC",
                            widget.pcName,
                            Icons.computer_rounded,
                            isDark,
                          ),
                          SizedBox(height: 16),
                          Divider(color: isDark ? Colors.white12 : Colors.black12),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Price",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                "IDR ${getTotalPrice()}",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 1500.ms).scale(begin: Offset(0.95, 0.95)),
                  
                  SizedBox(height: 32),
                  
                  // Book Now button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedTime != null && selectedDuration != null && !isLoading
                          ? _bookSlot
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: isDark ? Colors.white24 : Colors.grey[300],
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Book Now",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(duration: 1600.ms).slideY(begin: 0.2, end: 0),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white60 : Colors.black54,
          size: 18,
        ),
        SizedBox(width: 12),
        Text(
          "$label:",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

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