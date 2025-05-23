import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TopUpDetailsPage extends StatefulWidget {
  final String gameName;
  final String gameImage;

  const TopUpDetailsPage({Key? key, required this.gameName, required this.gameImage}) : super(key: key);

  @override
  _TopUpDetailsPageState createState() => _TopUpDetailsPageState();
}

class _TopUpDetailsPageState extends State<TopUpDetailsPage> {
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
          // Colorful wave background with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6), // Vibrant purple
                        const Color(0xFFEC4899), // Vibrant pink
                        const Color(0xFF1A1D40),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Colorful banner with custom diamond image
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFBBF24), // Amber
                    Color(0xFFFF6B6B), // Coral
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/dia.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.diamond, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Dapatkan Rewards hingga 3% dari dan Payment provider",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60), // Space for banner
                      // Game Info Header
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
                      // Step 1: Masukkan User ID
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
                                  borderSide: const BorderSide(color: Colors.blueAccent),
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
                                  borderSide: const BorderSide(color: Colors.blueAccent),
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
                      // Step 2: Pilih Nominal Top Up
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
                          _buildTopUpButton("2x Recharge Bonus", Icons.replay, isDark),
                          _buildTopUpButton("Diamond", Icons.diamond, isDark),
                          _buildTopUpButton("Twilight Pass", Icons.star, isDark),
                          _buildTopUpButton("Weekly Diamond", Icons.calendar_today, isDark),
                        ],
                      ).animate().slideX(duration: 500.ms, begin: -0.5, end: 0.0),
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
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [
                                          const Color(0xFF34D399), // Green
                                          const Color(0xFF10B981),
                                        ]
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
                                    "Rp. ${option["price"]}",
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
                            ),
                          ).animate().scale(duration: 500.ms, delay: (index * 100).ms).shimmer(
                              duration: 1200.ms, color: Colors.white.withOpacity(0.3));
                        },
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Selection
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
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Payment Method",
                          labelStyle: const TextStyle(fontFamily: "Poppins"),
                          prefixIcon: const Icon(Icons.payment, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent),
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
                      ).animate().slideY(duration: 500.ms, begin: 0.5, end: 0.0),
                      const SizedBox(height: 24),
                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate() &&
                                selectedTopUpOption != null &&
                                selectedPaymentMethod != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Top-up for ${widget.gameName} (${selectedTopUpOption}) via $selectedPaymentMethod confirmed!",
                                    style: const TextStyle(fontFamily: "Poppins"),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context); // Back to the previous page
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
                                colors: [
                                  Color(0xFF34D399), // Green
                                  Color(0xFF10B981),
                                ],
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
        ],
      ),
    );
  }

  Widget _buildTopUpButton(String label, IconData icon, bool isDark) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8),
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
          gradient: LinearGradient(
            colors: [
              isDark ? const Color(0xFF6B7280) : const Color(0xFFE5E7EB),
              isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper for a more dynamic wave effect
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 120);

    var firstControlPoint = Offset(size.width / 6, size.height);
    var firstEndPoint = Offset(size.width / 3, size.height - 80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width / 2, size.height - 200);
    var secondEndPoint = Offset(2 * size.width / 3, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    var thirdControlPoint = Offset(5 * size.width / 6, size.height - 150);
    var thirdEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(
      thirdControlPoint.dx,
      thirdControlPoint.dy,
      thirdEndPoint.dx,
      thirdEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}