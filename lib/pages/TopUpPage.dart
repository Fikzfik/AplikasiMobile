import 'package:flutter/material.dart';
import '../widgets/clipper.dart';
import 'package:fikzuas/main.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  // Game list
  final List<Map<String, dynamic>> games = [
    {"name": "Mobile Legends", "image": "assets/img/ml.jpg"},
    {"name": "League of Legends", "image": "assets/img/lol.jpg"},
    {"name": "Dota 2", "image": "assets/img/dota2.jpg"},
    {"name": "Valorant", "image": "assets/img/valorant.png"},
    {"name": "CS:GO", "image": "assets/img/csgo.png"},
    {"name": "Call of Duty", "image": "assets/img/cod.jpg"},
    {"name": "Genshin Impact", "image": "assets/img/genshin.jpg"},
    {"name": "Elden Ring", "image": "assets/img/eldenring.png"},
    {"name": "Final Fantasy", "image": "assets/img/ff.png"},
    {"name": "PUBG", "image": "assets/img/pubg.jpg"},
    {"name": "Fortnite", "image": "assets/img/fortnite.jpg"},
    {"name": "Apex Legends", "image": "assets/img/apex.png"},
  ];

  // Top-up options for Mobile Legends
  final List<Map<String, dynamic>> topUpOptions = [
    {"diamonds": "100 Diamonds (50+50)", "price": 14203, "rewards": 71},
    {"diamonds": "300 Diamonds (150+150)", "price": 42365, "rewards": 211},
    {"diamonds": "500 Diamonds (250+250)", "price": 70632, "rewards": 353},
    {"diamonds": "1000 Diamonds (500+500)", "price": 142025, "rewards": 710},
  ];

  // Payment methods
  final List<String> paymentMethods = [
    "ShopeePay",
    "GoPay",
    "Dana",
    "OVO",
    "Bank Transfer",
    "Indomaret",
    "Alfamart",
  ];

  String? selectedGame;
  String? selectedTopUpOption;
  String? selectedPaymentMethod;
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController zoneIdController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D40),
        elevation: 0,
        title: const Text(
          "Top-Up",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Wave background with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2C2F50), Color(0xFF1A1D40)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Yellow banner
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Dapatkan Rewards hingga 3% dari Mobile Legends: Bang Bang dan Payment provider",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // Space for banner
                      // Step 1: Masukkan User ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "1. Masukkan User ID",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Help"),
                                  content: const Text(
                                    "Untuk mengetahui User ID Anda, silakan klik menu profile dibagian kiri atas pada menu utama game. User ID akan terlihat dibagian bawah Nama Karakter Game Anda. Silakan masukkan User ID Anda untuk menyelesaikan transaksi. Contoh: 12345678(1234).",
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
                      ),
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
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
                      ),
                      const SizedBox(height: 16),
                      // Step 2: Pilih Nominal Top Up
                      Text(
                        "2. Pilih Nominal Top Up",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "22,751 item dibeli dalam satu jam terakhir",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTopUpButton("2x Recharge Bonus", Icons.replay, isDark),
                          _buildTopUpButton("Diamond", Icons.diamond, isDark),
                          _buildTopUpButton("Twilight Pass", Icons.star, isDark),
                          _buildTopUpButton("Weekly Diamond", Icons.calendar_today, isDark),
                        ],
                      ),
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
                        "Selama event ini, player yang belum top up tingkat 50/150/250/500 Diamond melalui platform lain bisa mendapatkan bonus ganda pada pembelian pertama melebihi item berikut.",
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
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
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
                                color: isSelected
                                    ? Colors.greenAccent.withOpacity(0.3)
                                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.greenAccent : Colors.transparent,
                                  width: 2,
                                ),
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
                                    "Rp. ${option["price"]}",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "-${index * 2 + 12}%",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${option["rewards"]} Rewards",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  if (index < 4)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
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
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Selection
                      Text(
                        "Select Payment Method",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Payment Method",
                          labelStyle: const TextStyle(fontFamily: "Poppins"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        value: selectedPaymentMethod,
                        items: paymentMethods.map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(
                              method,
                              style: const TextStyle(fontFamily: "Poppins"),
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
                      const SizedBox(height: 24),
                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate() && selectedTopUpOption != null && selectedPaymentMethod != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Top-up for Mobile Legends (${selectedTopUpOption}) via $selectedPaymentMethod confirmed!",
                                    style: const TextStyle(fontFamily: "Poppins"),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please fill all fields and select a top-up amount and payment method!",
                                    style: TextStyle(fontFamily: "Poppins"),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Confirm Top-Up",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopUpButton(String label, IconData icon, bool isDark) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isDark ? Colors.white : Colors.black),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 10,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}