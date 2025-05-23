import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PsRentalState with ChangeNotifier {
  Map<String, List<bool>> psSlots = {
    "PlayZone Central": List<bool>.filled(5, true), // 5 PS units
    "GameHub East": List<bool>.filled(7, true), // 7 PS units
    "FunPlay South": List<bool>.filled(9, true), // 9 PS units
  };

  // Store booked times per location, unit, and date
  Map<String, Map<int, List<Map<String, dynamic>>>> bookedTimes = {
    "PlayZone Central": {},
    "GameHub East": {},
    "FunPlay South": {},
  };

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int? selectedDuration;
  String? paymentMethod;

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    selectedTime = time;
    notifyListeners();
  }

  void setSelectedDuration(int duration) {
    selectedDuration = duration;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  int getTotalPrice() {
    return (selectedDuration ?? 0) * 50000; // IDR 50,000 per hour
  }

  TimeOfDay getEndTime() {
    if (selectedTime == null || selectedDuration == null) {
      return TimeOfDay(hour: 0, minute: 0);
    }
    int endHour = selectedTime!.hour + selectedDuration!;
    int endMinute = selectedTime!.minute;
    return TimeOfDay(hour: endHour % 24, minute: endMinute);
  }

  void bookSlot(String psLocation, int unitIndex, DateTime date, TimeOfDay startTime, TimeOfDay endTime) {
    if (psSlots.containsKey(psLocation)) {
      psSlots[psLocation]![unitIndex - 1] = false; // Mark as booked
      if (!bookedTimes[psLocation]!.containsKey(unitIndex - 1)) {
        bookedTimes[psLocation]![unitIndex - 1] = [];
      }
      bookedTimes[psLocation]![unitIndex - 1]!.add({
        'date': date,
        'start': startTime,
        'end': endTime,
      });
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getBookedTimes(String psLocation, int unitIndex, DateTime date) {
    if (bookedTimes.containsKey(psLocation) && bookedTimes[psLocation]!.containsKey(unitIndex - 1)) {
      return bookedTimes[psLocation]![unitIndex - 1]!.where((booking) {
        DateTime bookingDate = booking['date'] as DateTime;
        return bookingDate.year == date.year &&
            bookingDate.month == date.month &&
            bookingDate.day == date.day;
      }).toList();
    }
    return [];
  }

  bool isTimeSlotAvailable(BuildContext context, String psLocation, int unitIndex) {
    if (selectedTime == null || selectedDuration == null || selectedDate == null) {
      return false;
    }

    final startMinutes = selectedTime!.hour * 60 + selectedTime!.minute;
    final endTime = getEndTime();
    final endMinutes = endTime.hour * 60 + endTime.minute;

    // Check if end time exceeds 22:00
    if (endTime.hour > 22 || (endTime.hour == 22 && endTime.minute > 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Booking cannot end after 22:00! Please adjust your start time or duration.",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    final bookedTimesList = getBookedTimes(psLocation, unitIndex, selectedDate!);
    for (var booking in bookedTimesList) {
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

  void confirmBooking(String psLocation, int unitIndex) {
    if (selectedTime != null && selectedDuration != null && selectedDate != null && paymentMethod != null) {
      bookSlot(psLocation, unitIndex, selectedDate!, selectedTime!, getEndTime());
      // Reset temporary state
      selectedDate = null;
      selectedTime = null;
      selectedDuration = null;
      paymentMethod = null;
    }
  }
}