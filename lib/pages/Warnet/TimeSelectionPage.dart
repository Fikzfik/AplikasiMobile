import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:fikzuas/pages/HistoryPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

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
    return (selectedDuration ?? 0) * 50000;
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

class TimeSelectionPage extends StatelessWidget {
  final String warnetName;
  final int pcNumber;
  final DateTime selectedDate;
  final int warnetId;
  final int? pcId;

  const TimeSelectionPage({
    Key? key,
    required this.warnetName,
    required this.pcNumber,
    required this.selectedDate,
    required this.warnetId,
    required this.pcId,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchBookedTimes(int warnetId, int? pcId, DateTime date) async {
    if (pcId == null) {
      debugPrint('Error: pcId is null');
      throw Exception('pcId is required');
    }

    debugPrint('Fetching booked times...');
    debugPrint('warnetId: $warnetId');
    debugPrint('pcId: $pcId');
    debugPrint('date: ${date.toIso8601String().split('T')[0]}');

    final url = 'http://10.0.2.2:8000/api/booked_pc?warnet_id=$warnetId&pc_id=$pcId&date=${date.toIso8601String().split('T')[0]}';
    debugPrint('Request URL: $url');

    try {
      final response = await http.get(Uri.parse(url));
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Decoded data: $data');

        if (data is List) {
          return List<Map<String, dynamic>>.from(data.map((item) {
            debugPrint('Processing item: $item');
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
          debugPrint('Error: Response data is not a list');
          throw Exception('Response data is not a list');
        }
      } else {
        debugPrint('Error: Failed to fetch booked times with status code ${response.statusCode}');
        throw Exception('Failed to fetch booked times: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception caught: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the current date and time (10:08 PM WIB on May 31, 2025)
    final currentDateTime = DateTime(2025, 5, 31, 22, 8);

    if (pcId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error: PC ID is not provided. Please go back and select a PC.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => TimeSelectionState(selectedDate: selectedDate),
      child: Consumer<TimeSelectionState>(
        builder: (context, timeState, child) {
          // Validate selected date against current date
          if (selectedDate.isBefore(currentDateTime.subtract(Duration(days: 1)))) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Cannot book in the past. Please select a future date.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }

          return Scaffold(
            body: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchBookedTimes(warnetId, pcId, selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint('FutureBuilder error: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  debugPrint('No bookings found for this date.');
                  return Stack(
                    children: [
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
                                      ? [Color(0xFF2C2F50), Color(0xFF1A1D40).withOpacity(0.9)]
                                      : [Color(0xFF3A3D60), Color(0xFF2C2F50).withOpacity(0.85)],
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
                              Text(
                                "No bookings yet for this date.",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ).animate().fadeIn(duration: 600.ms),
                              SizedBox(height: 24),
                              GestureDetector(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    final selectedDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    // Fixed: Call isSameDay as a method of TimeSelectionPage
                                    if (isSameDay(selectedDate, currentDateTime) && selectedDateTime.isBefore(currentDateTime)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Cannot book a time in the past. Please select a future time.",
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
                                ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
                              ),
                              SizedBox(height: 16),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  child: ElevatedButton(
                                    onPressed: timeState.selectedTime != null && timeState.selectedDuration != null
                                        ? () {
                                            if (timeState.isTimeSlotAvailable(context)) {
                                              timeState.setLoading(true);
                                              _showPaymentDialog(context, timeState, warnetName, pcNumber, selectedDate, pcId);
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
                  );
                } else {
                  timeState.bookedTimes = snapshot.data!;
                  debugPrint('Booked times loaded: ${timeState.bookedTimes}');
                  return Stack(
                    children: [
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
                                      ? [Color(0xFF2C2F50), Color(0xFF1A1D40).withOpacity(0.9)]
                                      : [Color(0xFF3A3D60), Color(0xFF2C2F50).withOpacity(0.85)],
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
                              Column(
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
                              ),
                              SizedBox(height: 24),
                              GestureDetector(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    final selectedDateTime = DateTime(
                                      selectedDate.year,
                                      selectedDate.month,
                                      selectedDate.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    // Fixed: Call isSameDay as a method of TimeSelectionPage
                                    if (isSameDay(selectedDate, currentDateTime) && selectedDateTime.isBefore(currentDateTime)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Cannot book a time in the past. Please select a future time.",
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
                                ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
                              ),
                              SizedBox(height: 16),
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  child: ElevatedButton(
                                    onPressed: timeState.selectedTime != null && timeState.selectedDuration != null
                                        ? () {
                                            if (timeState.isTimeSlotAvailable(context)) {
                                              timeState.setLoading(true);
                                              _showPaymentDialog(context, timeState, warnetName, pcNumber, selectedDate, pcId);
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
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, TimeSelectionState timeState, String warnetName, int pcNumber, DateTime selectedDate, int? pcId) {
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
                        child: Image.asset(
                          'assets/qris_placeholder.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                "QRIS Image Not Found",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            );
                          },
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
                          if (timeState.selectedTime != null && timeState.selectedDuration != null && pcId != null) {
                            timeState.setLoading(true);
                            try {
                              await Future.delayed(Duration(seconds: 2));
                              await _bookSlotToDatabase(context, timeState, pcId!, selectedDate);
                              final bookingState = Provider.of<BookingState>(context, listen: false);
                              bookingState.bookSlot(warnetName, pcNumber);

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HistoryPage(refreshOnLoad: true)),
                                (Route<dynamic> route) => false,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Transaksi Berhasil",
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } catch (e) {
                              debugPrint('Error during payment confirmation: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Payment failed: $e'),
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
        ).animate().scale(duration: 500.ms, curve: Curves.easeOut).fadeIn(duration: 400.ms);
      },
    );
  }

  Future<void> _bookSlotToDatabase(BuildContext context, TimeSelectionState timeState, int pcId, DateTime selectedDate) async {
    try {
      if (pcId == null) {
        throw Exception('PC ID is null');
      }

      final startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, timeState.selectedTime!.hour, timeState.selectedTime!.minute);
      final endTime = startTime.add(Duration(hours: timeState.selectedDuration ?? 0));
      final totalPrice = timeState.getTotalPrice();

      // Format the date to match Y-m-d H:i:s
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final formattedStartTime = dateFormat.format(startTime);
      final formattedEndTime = dateFormat.format(endTime);

      debugPrint('Booking slot with data:');
      debugPrint('pc_id: $pcId');
      debugPrint('id_user: 1');
      debugPrint('start_time: $formattedStartTime');
      debugPrint('end_time: $formattedEndTime');
      debugPrint('booking_status: confirmed');
      debugPrint('amount: $totalPrice');

      final requestBody = jsonEncode({
        'pc_id': pcId,
        'id_user': 1,
        'start_time': formattedStartTime,
        'end_time': formattedEndTime,
        'booking_status': 'confirmed',
        'amount': totalPrice,
      });
      debugPrint('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/book_pcs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('Booking successfully saved to database: ${responseData['booking_id']}');
      } else {
        throw Exception('Failed to book slot: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in _bookSlotToDatabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book slot: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      rethrow;
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
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