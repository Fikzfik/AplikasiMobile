import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class PsRentalState with ChangeNotifier {
  List<List<bool>> psAvailability = List.generate(
    5,
    (row) => List.generate(6, (col) => col + row * 6 + 1 <= 20 ? true : false),
  );
  List<List<bool?>> psSelection = List.generate(
    5,
    (row) => List.generate(6, (col) => null),
  );
  bool isRenting = false;

  void toggleSelection(int row, int col) {
    if (psAvailability[row][col]) {
      psSelection[row][col] = psSelection[row][col] == null ? true : null;
      notifyListeners();
    }
  }

  void setRenting(bool value) {
    isRenting = value;
    notifyListeners();
  }

  void reserveSelected() {
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        if (psSelection[row][col] == true) {
          psAvailability[row][col] = false;
          psSelection[row][col] = null;
        }
      }
    }
    notifyListeners();
  }

  List<int> getSelectedIndices() {
    List<int> selected = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        if (psSelection[row][col] == true) {
          selected.add(row * 6 + col + 1);
        }
      }
    }
    return selected;
  }
}

class SewaPsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PsRentalState(),
      child: Consumer<PsRentalState>(
        builder: (context, rentalState, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "Sewa PS",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 18,
                  color: Colors.white70,
                  shadows: [
                    Shadow(color: Colors.pinkAccent.withOpacity(0.6), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1440), Color(0xFF0D0A2F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: CircularParticle(
                    key: UniqueKey(),
                    awayRadius: 100,
                    numberOfParticles: 50,
                    speedOfParticles: 0.3,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    onTapAnimation: false,
                    particleColor: Colors.white.withOpacity(0.5),
                    awayAnimationDuration: Duration(milliseconds: 800),
                    maxParticleSize: 2,
                    isRandSize: true,
                    isRandomColor: false,
                    enableHover: false,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.pinkAccent.withOpacity(0.8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                        SizedBox(height: 20),
                        Text(
                          "Choose PS Units",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                        SizedBox(height: 20),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: 30,
                            itemBuilder: (context, index) {
                              int row = index ~/ 6;
                              int col = index % 6;
                              bool isAvailable = rentalState.psAvailability[row][col];
                              bool? isSelected = rentalState.psSelection[row][col];
                              Color color = isAvailable
                                  ? (isSelected == true ? Colors.teal : Colors.white)
                                  : Colors.redAccent;
                              return GestureDetector(
                                onTap: () => rentalState.toggleSelection(row, col),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color.withOpacity(0.8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.chair,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 600.ms + (index * 50).ms),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(Icons.circle, Colors.white, "Available"),
                            SizedBox(width: 20),
                            _buildLegendItem(Icons.circle, Colors.redAccent, "Reserved"),
                            SizedBox(width: 20),
                            _buildLegendItem(Icons.circle, Colors.teal, "Selected"),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (rentalState.getSelectedIndices().isNotEmpty) {
                              rentalState.setRenting(true);
                              _showRentalDialog(context, rentalState);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please select at least one PS unit!",
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            "Confirm Selection",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ).animate().fadeIn(duration: 800.ms),
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

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: "Poppins",
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showRentalDialog(BuildContext context, PsRentalState rentalState) {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final TextEditingController durationController = TextEditingController();
    String? paymentMethod;
    int currentStep = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final lightModeBackground = Color.alphaBlend(
          Colors.black.withOpacity(0.15),
          Colors.grey[200]!,
        );

        return StatefulBuilder(
          builder: (context, setState) {
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
                            "Confirm PS Rental",
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
                                width: 150 * (currentStep + 1),
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
                          Container(
                            height: 280,
                            child: Stepper(
                              currentStep: currentStep,
                              onStepContinue: () {
                                if (currentStep == 0) {
                                  if (selectedDate != null &&
                                      selectedTime != null &&
                                      durationController.text.isNotEmpty) {
                                    setState(() {
                                      currentStep++;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Please fill all fields!",
                                          style: TextStyle(fontFamily: "Poppins"),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                } else {
                                  if (paymentMethod != null) {
                                    setState(() {
                                      rentalState.setRenting(true);
                                    });
                                    Future.delayed(Duration(seconds: 2), () {
                                      rentalState.reserveSelected();
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Rental for PS units ${rentalState.getSelectedIndices().join(', ')} confirmed! Total: IDR ${int.parse(durationController.text) * 50000 * rentalState.getSelectedIndices().length}",
                                            style: TextStyle(fontFamily: "Poppins"),
                                          ),
                                          backgroundColor: Colors.blueAccent,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                      rentalState.setRenting(false);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Please select a payment method!",
                                          style: TextStyle(fontFamily: "Poppins"),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              onStepCancel: () {
                                if (currentStep > 0) {
                                  setState(() {
                                    currentStep--;
                                  });
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              controlsBuilder: (context, details) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: details.onStepCancel,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.grey[600]!, Colors.grey[800]!],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            currentStep == 0 ? "Cancel" : "Back",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ).animate().fadeIn(duration: 800.ms).scale(),
                                      ),
                                      GestureDetector(
                                        onTap: details.onStepContinue,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.blueAccent, Colors.pinkAccent],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blueAccent.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: rentalState.isRenting
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : Text(
                                                  currentStep == 0 ? "Next" : "Confirm",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                        ).animate().fadeIn(duration: 800.ms).scale(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              steps: [
                                Step(
                                  title: Text(
                                    "Rental Details",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  content: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final date = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(Duration(days: 30)),
                                          );
                                          if (date != null) {
                                            setState(() {
                                              selectedDate = date;
                                            });
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
                                              colors: isDark
                                                  ? [Color(0xFF1A1440), Color(0xFF262A50)]
                                                  : [Colors.grey[300]!, Colors.grey[200]!],
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.calendar_today, color: Colors.blueAccent, size: 20),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  selectedDate == null
                                                      ? "Select Date"
                                                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: selectedDate == null
                                                        ? (isDark ? Colors.white70 : Colors.black54)
                                                        : (isDark ? Colors.white : Colors.black87),
                                                    fontWeight: selectedDate == null
                                                        ? FontWeight.normal
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
                                      SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () async {
                                          final time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );
                                          if (time != null) {
                                            setState(() {
                                              selectedTime = time;
                                            });
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
                                              colors: isDark
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
                                                  selectedTime == null
                                                      ? "Select Time"
                                                      : selectedTime!.format(context),
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: selectedTime == null
                                                        ? (isDark ? Colors.white70 : Colors.black54)
                                                        : (isDark ? Colors.white : Colors.black87),
                                                    fontWeight: selectedTime == null
                                                        ? FontWeight.normal
                                                        : FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0, delay: 100.ms),
                                      SizedBox(height: 12),
                                      TextField(
                                        controller: durationController,
                                        decoration: InputDecoration(
                                          labelText: "Duration (hours)",
                                          labelStyle: TextStyle(
                                            fontFamily: "Poppins",
                                            color: isDark ? Colors.white70 : Colors.black54,
                                          ),
                                          prefixIcon: Icon(Icons.hourglass_empty, color: Colors.blueAccent, size: 20),
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
                                          fillColor: isDark ? Color(0xFF1A1440) : Colors.grey[300],
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0, delay: 200.ms),
                                    ],
                                  ),
                                ),
                                Step(
                                  title: Text(
                                    "Payment Details",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  content: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: "Payment Method",
                                          labelStyle: TextStyle(
                                            fontFamily: "Poppins",
                                            color: isDark ? Colors.white70 : Colors.black54,
                                          ),
                                          prefixIcon: Icon(Icons.payment, color: Colors.blueAccent, size: 20),
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
                                          fillColor: isDark ? Color(0xFF1A1440) : Colors.grey[300],
                                        ),
                                        dropdownColor: isDark ? Color(0xFF1A1440) : Colors.grey[300],
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                        value: paymentMethod,
                                        items: ["Credit Card", "PayPal", "Cash"].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            paymentMethod = value;
                                          });
                                        },
                                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
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
                                            colors: isDark
                                                ? [Color(0xFF1A1440), Color(0xFF262A50)]
                                                : [Colors.grey[300]!, Colors.grey[200]!],
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.account_balance_wallet, color: Colors.blueAccent, size: 20),
                                                SizedBox(width: 12),
                                                Text(
                                                  "Total Price",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    color: isDark ? Colors.white70 : Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "IDR ${int.tryParse(durationController.text) != null ? int.parse(durationController.text) * 50000 * rentalState.getSelectedIndices().length : 0}",
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0, delay: 100.ms),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOut).fadeIn(duration: 400.ms);
          },
        );
      },
    );
  }
}