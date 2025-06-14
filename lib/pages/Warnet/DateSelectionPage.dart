// date_selection_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fikzuas/pages/Warnet/TimeSelectionPage.dart';

class DateSelectionPage extends StatefulWidget {
  final String warnetName;
  final int pcNumber;
  final int warnetId;
  final int? pcId;
  final String pcName;
  final String pcSpecs;

  const DateSelectionPage({
    Key? key,
    required this.warnetName,
    required this.pcNumber,
    required this.warnetId,
    required this.pcId,
    required this.pcName,
    required this.pcSpecs,
  }) : super(key: key);

  @override
  _DateSelectionPageState createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  DateTime? selectedDate;
  late DateTime _currentMonth;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void _selectDate(DateTime date) {
    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return;
    }
    
    setState(() {
      selectedDate = date;
    });
    
    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimeSelectionPage(
            warnetName: widget.warnetName,
            pcNumber: widget.pcNumber,
            selectedDate: date,
            warnetId: widget.warnetId,
            pcId: widget.pcId,
            pcName: widget.pcName,
            pcSpecs: widget.pcSpecs,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    const List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final daysInMonth = _daysInMonth(_currentMonth);
    final firstDayOffset = _firstDayOffset(_currentMonth);
    final totalGridItems = firstDayOffset + daysInMonth;

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
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
                      "Select Date",
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
              ),
              
              // Booking info card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Row(
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
                            "Booking ${widget.pcName}",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "at ${widget.warnetName}",
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
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
              
              // Month navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                            1,
                          );
                          selectedDate = null;
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                            1,
                          );
                          selectedDate = null;
                        });
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 1000.ms),
              
              // Days of week
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: daysOfWeek.map((day) {
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(duration: 1200.ms),
              
              // Calendar grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: (totalGridItems + 6) ~/ 7 * 7,
                    itemBuilder: (context, index) {
                      final dayIndex = index - firstDayOffset + 1;
                      
                      if (dayIndex < 1 || dayIndex > daysInMonth) {
                        return SizedBox.shrink();
                      }
                      
                      final date = DateTime(_currentMonth.year, _currentMonth.month, dayIndex);
                      final isSelected = selectedDate != null && 
                          selectedDate!.year == date.year && 
                          selectedDate!.month == date.month && 
                          selectedDate!.day == date.day;
                      final isToday = DateTime.now().year == date.year && 
                          DateTime.now().month == date.month && 
                          DateTime.now().day == date.day;
                      final isPast = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
                      
                      return GestureDetector(
                        onTap: isPast ? null : () => _selectDate(date),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : isToday
                                    ? accentColor
                                    : isPast
                                        ? (isDark ? Color(0xFF1F2236) : Colors.grey[200])
                                        : (isDark ? Color(0xFF262A43) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected || isToday
                                ? [
                                    BoxShadow(
                                      color: (isSelected ? primaryColor : accentColor).withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              dayIndex.toString(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                color: isSelected || isToday
                                    ? Colors.white
                                    : isPast
                                        ? (isDark ? Colors.white38 : Colors.black38)
                                        : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 100.ms, delay: (index * 20).ms),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}