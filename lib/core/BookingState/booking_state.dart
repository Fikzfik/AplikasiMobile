import 'package:flutter/material.dart';

class BookingState with ChangeNotifier {
  Map<String, List<bool>> warnetPcSlots = {};
  Map<String, List<bool>> warnetPsSlots = {};

  void initializePcSlots(String warnetName, int totalPcs) {
    if (!warnetPcSlots.containsKey(warnetName)) {
      warnetPcSlots[warnetName] = List<bool>.filled(totalPcs, true);
    }
  }

  void initializePsSlots(String warnetName, int totalPs) {
    if (!warnetPsSlots.containsKey(warnetName)) {
      warnetPsSlots[warnetName] = List<bool>.filled(totalPs, true);
    }
  }

  void bookPcSlot(String warnetName, int index) {
    if (warnetPcSlots.containsKey(warnetName)) {
      warnetPcSlots[warnetName]![index - 1] = false;
      notifyListeners();
    }
  }

 void bookPsSlot(String warnetName, int psId) {
    final index = warnetPsSlots[warnetName]!.indexWhere((slot) => slot); // Find first available slot
    if (index != -1) {
      warnetPsSlots[warnetName]![index] = false;
      notifyListeners();
    }
  }

  int getAvailablePcSlots(String warnetName) {
    return warnetPcSlots[warnetName]?.where((slot) => slot).length ?? 0;
  }

  int getAvailablePsSlots(String warnetName) {
    return warnetPsSlots[warnetName]?.where((slot) => slot).length ?? 0;
  }
}