import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpDetailsPage extends StatefulWidget {
  final String gameName;
  final String gameImage;

  const TopUpDetailsPage({Key? key, required this.gameName, required this.gameImage}) : super(key: key);

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
          print('Invalid response data: $data');
        }
      } else {
        setState(() {
          userName = "Failed to Load: ${response.statusCode}";
          userBalance = 0;
        });
        print('Failed to load user data. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        userName = "Error: $e";
        userBalance = 0;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _performTopUp() async {
    if (!formKey.currentState!.validate() || selectedTopUpOption == null || selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a top-up amount and payment method")),
      );
      return;
    }

    final selectedOption = topUpOptions.firstWhere((option) => option["diamonds"] == selectedTopUpOption);
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

    // Determine if Saldo is disabled based on selected amount and balance
    final selectedOption = selectedTopUpOption != null
        ? topUpOptions.firstWhere((option) => option["diamonds"] == selectedTopUpOption)
        : null;
    final isSaldoDisabled = selectedOption != null && selectedPaymentMethod == "Saldo" && userBalance < selectedOption["price"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D40),
        elevation: 0,
        title: Text(
          "Top-Up ${widget.gameName}",
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
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
                      colors: isDark
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 70),
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
                              Container(color: Colors.grey, width: 60, height: 60),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.gameName,
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          shadows: const [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "1. Masukkan User ID",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.blueAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Help"),
                              content: const Text(
                                "Untuk mengetahui User ID Anda, silakan klik menu profile di bagian kiri atas pada menu utama game. User ID akan terlihat di bawah Nama Karakter Game Anda. Silakan masukkan User ID Anda untuk menyelesaikan transaksi. Contoh: 12345678(1234).",
                                style: TextStyle(fontFamily: "Poppins"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userIdController,
                          decoration: InputDecoration(
                            labelText: "Masukkan User ID",
                            labelStyle: const TextStyle(fontFamily: "Poppins"),
                            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your User ID";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: zoneIdController,
                          decoration: InputDecoration(
                            labelText: "Zone ID",
                            labelStyle: const TextStyle(fontFamily: "Poppins"),
                            prefixIcon: const Icon(Icons.map, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
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
                  ).animate().slideY(duration: 500.ms, begin: 0.5, end: 0.0),
                  const SizedBox(height: 16),
                  Text(
                    "2. Pilih Nominal Top Up",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "22,751 item dibeli dalam satu jam terakhir",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(child: _buildTopUpButton("2x Recharge Bonus", Icons.replay, isDark, onTap: () => setTab("2x Recharge Bonus"))),
                      Flexible(child: _buildTopUpButton("Diamond", Icons.diamond, isDark, onTap: () => setTab("Diamond"))),
                      Flexible(child: _buildTopUpButton("Twilight Pass", Icons.star, isDark, onTap: () => setTab("Twilight Pass"))),
                      Flexible(child: _buildTopUpButton("Weekly Diamond", Icons.calendar_today, isDark, onTap: () => setTab("Weekly Diamond"))),
                    ],
                  ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
                  if (selectedTab != null) ...[
                    const SizedBox(height: 16),
                    if (selectedTab == "2x Recharge Bonus") ...[
                      const SizedBox(height: 8),
                      Text(
                        "2x Recharge Bonus",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Selama event ini, player yang belum top up tingkat 50/150/250/500 Diamond melalui platform lain bisa mendapatkan bonus ganda pada pembelian pertama melebihi item berikut. Top-up sekarang untuk bonus tambahan!",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: topUpOptions.length,
                        itemBuilder: (context, index) {
                          final option = topUpOptions[index];
                          final isSelected = selectedTopUpOption == option["diamonds"];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTopUpOption = option["diamonds"];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [const Color(0xFF34D399), const Color(0xFF10B981)]
                                      : [
                                          isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                                          isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    option["diamonds"],
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp. ${option["price"].toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/dia.png',
                                        width: 12,
                                        height: 12,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.diamond, color: Colors.blueAccent, size: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "-${index * 2 + 12}%",
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/dia.png',
                                        width: 12,
                                        height: 12,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.diamond, color: Colors.orangeAccent, size: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${option["rewards"]} Bonus",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (index < 4)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.redAccent, Colors.red],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "HOT",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ).animate().scale(duration: 500.ms, delay: (index * 100).ms).shimmer(
                                  duration: 1200.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                          );
                        },
                      ),
                    ],
                    if (selectedTab == "Diamond") ...[
                      const SizedBox(height: 8),
                      Text(
                        "Diamond Purchase Options",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Choose from various diamond packs to enhance your gameplay. More diamonds, more fun!",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: topUpOptions.length,
                        itemBuilder: (context, index) {
                          final option = topUpOptions[index];
                          final isSelected = selectedTopUpOption == option["diamonds"];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTopUpOption = option["diamonds"];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [const Color(0xFF34D399), const Color(0xFF10B981)]
                                      : [
                                          isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                                          isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    option["diamonds"],
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 12,
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp. ${option["price"].toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/dia.png',
                                        width: 12,
                                        height: 12,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.diamond, color: Colors.blueAccent, size: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "-${index * 2 + 12}%",
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/dia.png',
                                        width: 12,
                                        height: 12,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.diamond, color: Colors.orangeAccent, size: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${option["rewards"]} Rewards",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 10,
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (index < 4)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.redAccent, Colors.red],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        "HOT",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 8,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ).animate().scale(duration: 500.ms, delay: (index * 100).ms).shimmer(
                                  duration: 1200.ms,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                          );
                        },
                      ),
                    ],
                    if (selectedTab == "Twilight Pass") ...[
                      const SizedBox(height: 8),
                      Text(
                        "Twilight Pass Details",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Unlock exclusive Twilight Pass rewards including skins, emotes, and missions. Available for a limited time!",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Tier ${index + 1} Reward",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (selectedTab == "Weekly Diamond") ...[
                      const SizedBox(height: 8),
                      Text(
                        "Weekly Diamond Offer",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Weekly diamond packs with up to 20% discount. Renew every Monday for new offers!",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 10,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFF6B7280), const Color(0xFF4B5563)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "Pack ${index + 1} - 20% Off",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 12,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User: $userName",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "Balance: Rp. $userBalance",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select Payment Method",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Payment Method",
                            labelStyle: const TextStyle(fontFamily: "Poppins"),
                            prefixIcon: const Icon(Icons.payment, color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                          ),
                          value: selectedPaymentMethod,
                          items: paymentMethods.map((String method) {
                            final isDisabled = method == "Saldo" && isSaldoDisabled;
                            return DropdownMenuItem<String>(
                              value: method,
                              enabled: !isDisabled,
                              child: Row(
                                children: [
                                  Text(
                                    method,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      color: isDisabled ? Colors.grey : (isDark ? Colors.white : Colors.black),
                                    ),
                                  ),
                                  if (isDisabled)
                                    const Text(
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
                        ),
                      ),
                    ],
                  ).animate().slideY(duration: 500.ms, begin: 0.5, end: 0.0),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performTopUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.transparent,
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.8);
                            }
                            return Colors.white;
                          },
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF34D399), Color(0xFF10B981)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            "Confirm Top-Up",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setTab(String tab) {
    setState(() {
      selectedTab = tab;
    });
  }

  Widget _buildTopUpButton(String label, IconData icon, bool isDark, {VoidCallback? onTap}) {
    final isSelected = selectedTab == label;
    return ElevatedButton(
      onPressed: onTap ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2),
        ),
        padding: const EdgeInsets.all(4),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => isSelected
              ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))
              : Colors.transparent,
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.8);
            }
            return Colors.white;
          },
        ),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (states) => Colors.white.withOpacity(0.2),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? const Color(0xFF6B7280) : const Color(0xFFE5E7EB),
              isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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