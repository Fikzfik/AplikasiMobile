import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TimeSelectionState with ChangeNotifier {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedDuration;
  bool isLoading = false;
  List<Map<String, dynamic>> bookedTimes = [];

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
    return (selectedDuration ?? 0) * 50000; // Assuming same price as PC for simplicity
  }

  TimeOfDay getEndTime() {
    if (selectedTime == null || selectedDuration == null) {
      return selectedTime ?? TimeOfDay(hour: 0, minute: 0);
    }
    int endHour = selectedTime!.hour + selectedDuration!;
    int endMinute = selectedTime!.minute;
    endHour = endHour % 24;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }

  bool isTimeSlotAvailable(BuildContext context) {
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

class TimeSelectionPSPage extends StatelessWidget {
  final String warnetName;
  final int psNumber;
  final DateTime selectedDate;
  final int warnetId;
  final int? psId;

  const TimeSelectionPSPage({
    Key? key,
    required this.warnetName,
    required this.psNumber,
    required this.selectedDate,
    required this.warnetId,
    required this.psId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchBookedTimes(int warnetId, int? psId, DateTime date, String? token) async {
    if (psId == null) {
      debugPrint('Error: psId is null');
      throw Exception('psId is required');
    }

    final url = 'http://10.0.2.2:8000/api/booked_console?warnet_id=$warnetId&ps_id=$psId&date=${date.toIso8601String().split('T')[0]}';
    debugPrint('Request URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data.map((item) {
            return {
              'start': TimeOfDay(
                hour: int.parse(item['start_time'].split(':')[0]),
                minute: int.parse(item['start_time'].split(':')[1]),
              ),
              'end': TimeOfDay(
                hour: int.parse(item['end_time'].split(':')[0]),
                minute: int.parse(item['end_time'].split(':')[1]),
              ),
            };
          }));
        } else {
          throw Exception('Response data is not a list');
        }
      } else {
        throw Exception('Failed to fetch booked times: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception caught: $e');
      rethrow;
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  @override
  Widget build(BuildContext context) {
    if (psId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: PS ID is not provided. Please go back and select a PlayStation.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        _getToken(),
        _getUserId(),
      ]).then((results) => {'token': results[0], 'userId': results[1]}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data!['token'] == null || snapshot.data!['userId'] == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Please login to continue.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red),
              ),
            ),
          );
        }

        final String token = snapshot.data!['token'];
        final int userId = snapshot.data!['userId'];

        return ChangeNotifierProvider(
          create: (_) => TimeSelectionState(selectedDate: selectedDate),
          child: Consumer<TimeSelectionState>(
            builder: (context, timeState, child) {
              return Scaffold(
                body: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchBookedTimes(warnetId, psId, selectedDate, token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      debugPrint('FutureBuilder error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      debugPrint('No bookings found for this date.');
                      return _buildBookingForm(context, timeState, token, userId, []);
                    } else {
                      timeState.bookedTimes = snapshot.data!;
                      debugPrint('Booked times loaded: ${timeState.bookedTimes}');
                      return _buildBookingForm(context, timeState, token, userId, snapshot.data!);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingForm(BuildContext context, TimeSelectionState timeState, String token, int userId, List<Map<String, dynamic>> bookedTimes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark ? [Color(0xFF191B2F), Color(0xFF191B2F)] : [Colors.white, Colors.white],
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
                              Icons.gamepad,
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
                                  "PS $psNumber",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  warnetName,
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
                            DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),

                SizedBox(height: 24),

                // Booked times section
                if (timeState.isLoading)
                  Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                else if (timeState.bookedTimes.isEmpty)
                  Container(
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
                      Container(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: timeState.bookedTimes.length,
                          itemBuilder: (context, index) {
                            final booking = timeState.bookedTimes[index];
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
                      final selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        time.hour,
                        time.minute,
                      );
                      final currentDateTime = DateTime.now(); // Use current time
                      if (selectedDateTime.isBefore(currentDateTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cannot book a time in the past.',
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      timeState.setSelectedTime(time);
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
                          timeState.selectedTime == null
                              ? "Select Start Time"
                              : "Start Time: ${timeState.selectedTime!.format(context)}",
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
                          final isSelected = timeState.selectedDuration == hours;

                          return GestureDetector(
                            onTap: () {
                              timeState.setSelectedDuration(hours);
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
                if (timeState.selectedTime != null && timeState.selectedDuration != null)
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
                          DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                          Icons.calendar_today_rounded,
                          isDark,
                        ),
                        SizedBox(height: 8),
                        _buildSummaryRow(
                          "Time",
                          "${timeState.selectedTime!.format(context)} - ${timeState.getEndTime().format(context)}",
                          Icons.access_time_rounded,
                          isDark,
                        ),
                        SizedBox(height: 8),
                        _buildSummaryRow(
                          "Duration",
                          "${timeState.selectedDuration} hours",
                          Icons.hourglass_top_rounded,
                          isDark,
                        ),
                        SizedBox(height: 8),
                        _buildSummaryRow(
                          "PS",
                          "PS $psNumber",
                          Icons.gamepad,
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
                              "IDR ${timeState.getTotalPrice()}",
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
                    onPressed: timeState.selectedTime != null && timeState.selectedDuration != null && !timeState.isLoading
                        ? () {
                            if (timeState.isTimeSlotAvailable(context)) {
                              timeState.setLoading(true);
                              _showPaymentDialog(context, timeState, warnetName, psNumber, selectedDate, psId, token, userId);
                            }
                          }
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
                    child: timeState.isLoading
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

  void _showPaymentDialog(BuildContext context, TimeSelectionState timeState, String warnetName, int psNumber, DateTime selectedDate, int? psId, String token, int userId) {
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
                        "Payment via QRIS",
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
                        "Scan the QR code below to pay:",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.white70 : Colors.black54,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "QRIS Placeholder",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      SizedBox(height: 16),
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
                        onPressed: () async {
                          if (timeState.selectedTime != null &&
                              timeState.selectedDuration != null &&
                              psId != null) {
                            timeState.setLoading(true);
                            try {
                              await _bookSlotToDatabase(context, timeState, psId, selectedDate, token, userId);
                              Navigator.pop(context); // Close payment dialog
                              Navigator.pushNamed(context, '/history', arguments: {'refreshOnLoad': true});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Payment confirmed! Rental for PS $psNumber at $warnetName has been booked. Total: IDR ${timeState.getTotalPrice()}",
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  duration: Duration(seconds: 3),
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
                              timeState.setLoading(false);
                            }
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
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                "Confirm Payment",
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
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOut)
            .fadeIn(duration: 400.ms);
      },
    );
  }

  Future<void> _bookSlotToDatabase(BuildContext context, TimeSelectionState timeState, int psId, DateTime selectedDate, String token, int userId) async {
    final startTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      timeState.selectedTime!.hour,
      timeState.selectedTime!.minute,
    );
    final endTime = startTime.add(Duration(hours: timeState.selectedDuration ?? 0));
    final totalPrice = timeState.getTotalPrice();

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedStartTime = dateFormat.format(startTime);
    final formattedEndTime = dateFormat.format(endTime);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/book_ps'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_playstation': psId,
        'id_user': userId,
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        'booking_status': 'confirmed',
        'amount': totalPrice,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to book slot: ${response.statusCode} - ${response.body}');
    }
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