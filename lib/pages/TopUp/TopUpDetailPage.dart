import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpDetailsPage extends StatefulWidget {
  final String gameName;
  final String gameImage;

  const TopUpDetailsPage(
      {Key? key, required this.gameName, required this.gameImage})
      : super(key: key);

  @override
  _TopUpDetailsPageState createState() => _TopUpDetailsPageState();
}

class _TopUpDetailsPageState extends State<TopUpDetailsPage> {
  final List<Map<String, dynamic>> topUpOptions = [
    {"diamonds": "100 Diamonds (50+50)", "price": 14203, "rewards": 71},
    {"diamonds": "300 Diamonds (150+150)", "price": 42365, "rewards": 211},
    {"diamonds": "500 Diamonds (250+250)", "price": 70632, "rewards": 353},
    {"diamonds": "1000 Diamonds (500+500)", "price": 142025, "rewards": 710},
  ];

  final List<String> paymentMethods = [
    "Saldo",
    "Bank",
    "CreditCard",
  ];

  String? selectedTopUpOption;
  String? selectedTab = "2x Recharge Bonus";
  String? selectedPaymentMethod;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController zoneIdController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String userName = "Loading...";
  int userBalance = 0;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('token');
    });
    if (authToken != null) {
      await _loadUserData();
    } else {
      setState(() {
        userName = "Not Logged In";
        userBalance = 0;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          setState(() {
            userName = data['user']['name'] ?? "Unknown User";
            userBalance = (data['user']['money'] as num?)?.toInt() ?? 0;
          });
        } else {
          setState(() {
            userName = "Data Not Found";
            userBalance = 0;
          });
        }
      } else {
        setState(() {
          userName = "Failed to Load: ${response.statusCode}";
          userBalance = 0;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error: $e";
        userBalance = 0;
      });
    }
  }

  Future<void> _performTopUp() async {
    if (!formKey.currentState!.validate() ||
        selectedTopUpOption == null ||
        selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please fill all fields and select a top-up amount and payment method")),
      );
      return;
    }

    final selectedOption = topUpOptions
        .firstWhere((option) => option["diamonds"] == selectedTopUpOption);
    final amount = selectedOption["price"];

    if (selectedPaymentMethod == "Saldo" && userBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Insufficient balance")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/topup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'game_name': widget.gameName,
          'amount': amount,
          'payment_method': selectedPaymentMethod,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Top-up for ${widget.gameName} ($selectedTopUpOption) via $selectedPaymentMethod confirmed!",
            ),
          ),
        );
        if (selectedPaymentMethod == "Saldo") {
          setState(() {
            userBalance = (responseData['data']['new_balance'] as num).toInt();
          });
        }
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Top-up failed: ${responseData['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    // Determine if Saldo is disabled based on selected amount and balance
    final selectedOption = selectedTopUpOption != null
        ? topUpOptions
            .firstWhere((option) => option["diamonds"] == selectedTopUpOption)
        : null;
    final isSaldoDisabled =
        selectedOption != null && userBalance < selectedOption["price"];

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
                      "Top-Up ${widget.gameName}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game info
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              widget.gameImage,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: isDark
                                    ? Color(0xFF1F2236)
                                    : Colors.grey[300],
                                width: 60,
                                height: 60,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.gameName,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  "Official Top-Up Center",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 800.ms).scale(),

                      SizedBox(height: 24),

                      // User ID section
                      _buildSectionHeader("1. Masukkan User ID",
                          Icons.person_rounded, primaryColor),
                      SizedBox(height: 16),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: userIdController,
                              decoration: InputDecoration(
                                labelText: "Masukkan User ID",
                                labelStyle: TextStyle(fontFamily: "Poppins"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: isDark
                                    ? Color(0xFF1F2236)
                                    : Colors.grey[100],
                                prefixIcon: Icon(Icons.person_rounded,
                                    color: primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your User ID";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: zoneIdController,
                              decoration: InputDecoration(
                                labelText: "Zone ID",
                                labelStyle: TextStyle(fontFamily: "Poppins"),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: isDark
                                    ? Color(0xFF1F2236)
                                    : Colors.grey[100],
                                prefixIcon: Icon(Icons.map_rounded,
                                    color: primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your Zone ID";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 900.ms)
                          .slideY(begin: 0.2, end: 0),

                      SizedBox(height: 24),

                      // Top-up options section
                      _buildSectionHeader("2. Pilih Nominal Top Up",
                          Icons.diamond_rounded, primaryColor),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: accentColor,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "22,751 item dibeli dalam satu jam terakhir",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 950.ms),

                      SizedBox(height: 16),

                      // Tab buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabButton("2x Recharge Bonus",
                                Icons.replay_rounded, isDark, primaryColor),
                            SizedBox(width: 8),
                            _buildTabButton("Diamond", Icons.diamond_rounded,
                                isDark, primaryColor),
                            SizedBox(width: 8),
                            _buildTabButton("Twilight Pass", Icons.star_rounded,
                                isDark, primaryColor),
                            SizedBox(width: 8),
                            _buildTabButton(
                                "Weekly Diamond",
                                Icons.calendar_today_rounded,
                                isDark,
                                primaryColor),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 1000.ms)
                          .slideX(begin: -0.2, end: 0),

                      SizedBox(height: 16),

                      // Top-up options grid
                      if (selectedTab == "2x Recharge Bonus") ...[
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: topUpOptions.length,
                          itemBuilder: (context, index) {
                            final option = topUpOptions[index];
                            final isSelected =
                                selectedTopUpOption == option["diamonds"];
                            return _buildTopUpCard(option, isSelected, index,
                                isDark, primaryColor);
                          },
                        ),
                      ],

                      SizedBox(height: 24),

                      // User info
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "User",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Balance",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Rp. $userBalance",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 1100.ms),

                      SizedBox(height: 24),

                      // Payment method section
                      _buildSectionHeader("Select Payment Method",
                          Icons.payment_rounded, primaryColor),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Payment Method",
                          labelStyle: TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor:
                              isDark ? Color(0xFF1F2236) : Colors.grey[100],
                          prefixIcon:
                              Icon(Icons.payment_rounded, color: primaryColor),
                        ),
                        value: selectedPaymentMethod,
                        items: paymentMethods.map((String method) {
                          final isDisabled =
                              method == "Saldo" && isSaldoDisabled;
                          return DropdownMenuItem<String>(
                            value: method,
                            enabled: !isDisabled,
                            child: Row(
                              children: [
                                Text(
                                  method,
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    color: isDisabled
                                        ? Colors.grey
                                        : (isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                                if (isDisabled)
                                  Text(
                                    " (Insufficient Balance)",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a payment method";
                          }
                          return null;
                        },
                      )
                          .animate()
                          .fadeIn(duration: 1150.ms)
                          .slideY(begin: 0.2, end: 0),

                      SizedBox(height: 24),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _performTopUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: Size(double.infinity, 56),
                          ),
                          child: Text(
                            "Confirm Top-Up",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 1200.ms).scale(),
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

  Widget _buildSectionHeader(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(
      String label, IconData icon, bool isDark, Color primaryColor) {
    final isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? Color(0xFF262A43) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white60 : Colors.black54),
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpCard(Map<String, dynamic> option, bool isSelected,
      int index, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTopUpOption = option["diamonds"];
          // Auto-deselect Saldo if balance is insufficient
          if (selectedPaymentMethod == "Saldo" &&
              userBalance < option["price"]) {
            selectedPaymentMethod = null;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.2)
              : (isDark ? Color(0xFF262A43) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                option["diamonds"],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                "Rp. ${option["price"].toStringAsFixed(0)}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.diamond_rounded,
                    color: Color(0xFFFFB800),
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${option["rewards"]} Bonus",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              if (index < 2)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "HOT",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: (index * 100).ms)
          .scale(delay: (index * 100).ms),
    );
  }
}
