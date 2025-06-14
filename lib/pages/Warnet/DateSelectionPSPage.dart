import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fikzuas/pages/Warnet/TimeSelectionPSPage.dart';

class DateSelectionPSPage extends StatefulWidget {
  final String warnetName;
  final int psNumber;
  final int warnetId;
  final int? psId;

  const DateSelectionPSPage({
    Key? key,
    required this.warnetName,
    required this.psNumber,
    required this.warnetId,
    required this.psId,
  }) : super(key: key);

  @override
  _DateSelectionPageState createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPSPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  DateTime? selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    const List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Select Booking Date',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Warnet Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videogame_asset,
                        color: isDark ? Colors.white60 : Colors.black54,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Booking PS ${widget.psNumber} at ${widget.warnetName}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),

              SizedBox(height: 16),

              // Calendar Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_left,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                                selectedDate = null;
                              });
                            },
                          ),
                          Text(
                            '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_right,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                                selectedDate = null;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: daysOfWeek.map((day) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: (totalGridItems + 6) ~/ 7 * 7,
                          itemBuilder: (context, index) {
                            final dayIndex = index - firstDayOffset + 1;
                            final date = dayIndex > 0 && dayIndex <= daysInMonth
                                ? DateTime(_currentMonth.year, _currentMonth.month, dayIndex)
                                : null;

                            if (date == null) {
                              return SizedBox.shrink();
                            }

                            final isSelected = selectedDate == date;
                            final isToday = date.day == DateTime.now().day &&
                                date.month == DateTime.now().month &&
                                date.year == DateTime.now().year;
                            final isPast = date.isBefore(DateTime.now().subtract(Duration(days: 1)));

                            return GestureDetector(
                              onTap: isPast
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TimeSelectionPSPage(
                                            warnetName: widget.warnetName,
                                            psNumber: widget.psNumber,
                                            selectedDate: date,
                                            warnetId: widget.warnetId,
                                            psId: widget.psId,
                                          ),
                                        ),
                                      );
                                    },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? primaryColor.withOpacity(0.8)
                                      : (isToday
                                          ? accentColor.withOpacity(0.3)
                                          : (isPast
                                              ? Colors.grey[300]
                                              : isDark ? Color(0xFF262A43) : Colors.white)),
                                  border: isSelected
                                      ? Border.all(color: primaryColor, width: 2)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? primaryColor.withOpacity(0.3)
                                          : (isToday ? accentColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1)),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$dayIndex',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday
                                              ? Colors.black87
                                              : (isPast ? Colors.grey[600] : (isDark ? Colors.white70 : Colors.black54))),
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 500.ms + (index * 20).ms),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}