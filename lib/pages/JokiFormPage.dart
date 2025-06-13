import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JokiServicePage extends StatefulWidget {
  final String gameName;

  const JokiServicePage({super.key, required this.gameName});

  @override
  State<JokiServicePage> createState() => _JokiServicePageState();
}

class _JokiServicePageState extends State<JokiServicePage> {
  String? _selectedPackage;
  String? _selectedPayment;
  int? _starCount; // New field for number of stars
  final _formKey = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _gameIdController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  String _calculatePrice() {
    if (_selectedPackage == null || _starCount == null) return "Rp 0";
    switch (_selectedPackage) {
      case "Epic Rank":
        return "Rp ${6 * _starCount! * 1000}";
      case "Legend Rank":
        return "Rp ${8 * _starCount! * 1000}";
      case "Mythic Rank":
        return "Rp ${10 * _starCount! * 1000}";
      default:
        return "Rp 0";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Enhanced Wave Background with Gradient Overlay
          Positioned.fill(
            child: ClipPath(
              clipper: EnhancedWaveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1A1D40), const Color(0xFF2C2F50)]
                        : [const Color(0xFF4A90E2), const Color(0xFF6B48FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          // Subtle Particle Effect
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  Icons.star,
                  color: isDark ? Colors.white : Colors.black,
                  size: 40,
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      duration: const Duration(seconds: 4),
                      begin: Offset(0,7),
                      end: Offset(1, 3),
                    ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: Colors.white70, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          "Joki Pro - ${widget.gameName}",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.white,
                            letterSpacing: 1.0,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.5),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFFFFA500),
                          child: Icon(Icons.gamepad, color: Colors.black, size: 22),
                        ).animate().fadeIn(duration: 700.ms).scale(),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Package Selection
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: isDark
                          ? const Color(0xFF2E335A).withOpacity(0.9)
                          : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2E335A), const Color(0xFF3A4060)]
                                : [Colors.white, const Color(0xFFF0F4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pilih Paket",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ).animate().fadeIn(duration: 800.ms),
                                  Icon(Icons.star, color: Colors.orangeAccent, size: 30)
                                      .animate()
                                      .fadeIn(duration: 850.ms)
                                      .scale(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildPackageOption(
                                  "Rank Epic", "Rp 6,000/bintang", "Epic Rank"),
                              _buildPackageOption(
                                  "Rank Legend", "Rp 8,000/bintang", "Legend Rank"),
                              _buildPackageOption(
                                  "Rank Mythic", "Rp 10,000/bintang", "Mythic Rank"),
                              const SizedBox(height: 15),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Jumlah Bintang",
                                  labelStyle: const TextStyle(fontFamily: "Poppins"),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF2E335A).withOpacity(0.8)
                                      : Colors.grey[100],
                                  suffixIcon: Icon(Icons.star,
                                      color: Colors.orangeAccent, size: 20),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _starCount = int.tryParse(value) ?? 0;
                                  });
                                },
                                validator: (value) =>
                                    (int.tryParse(value ?? "") ?? 0) <= 0
                                        ? "Masukkan jumlah bintang yang valid"
                                        : null,
                              )
                                  .animate()
                                  .fadeIn(duration: 950.ms)
                                  .slideY(begin: 0.5),
                              const SizedBox(height: 10),
                              Text(
                                "Total: ${_calculatePrice()}",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ).animate().fadeIn(duration: 1000.ms),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Payment Method
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: isDark
                          ? const Color(0xFF2E335A).withOpacity(0.9)
                          : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2E335A), const Color(0xFF3A4060)]
                                : [Colors.white, const Color(0xFFF0F4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Pilih Metode Bayar",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ).animate().fadeIn(duration: 1100.ms),
                                  Icon(Icons.payment, color: Colors.orangeAccent, size: 30)
                                      .animate()
                                      .fadeIn(duration: 1150.ms)
                                      .scale(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              _buildPaymentOption("Gopay", "Gopay"),
                              _buildPaymentOption("OVO", "OVO"),
                              _buildPaymentOption("Dana", "Dana"),
                              _buildPaymentOption("Bank Transfer", "Bank"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Customer Details
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: isDark
                          ? const Color(0xFF2E335A).withOpacity(0.9)
                          : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2E335A), const Color(0xFF3A4060)]
                                : [Colors.white, const Color(0xFFF0F4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Masukan Data Akun",
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ).animate().fadeIn(duration: 1200.ms),
                                    Icon(Icons.person, color: Colors.orangeAccent, size: 30)
                                        .animate()
                                        .fadeIn(duration: 1250.ms)
                                        .scale(),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _gameIdController,
                                  decoration: InputDecoration(
                                    labelText: "Game ID",
                                    labelStyle: const TextStyle(fontFamily: "Poppins"),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF2E335A).withOpacity(0.8)
                                        : Colors.grey[100],
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.orangeAccent
                                            : Colors.purpleAccent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? "Required" : null,
                                )
                                    .animate()
                                    .fadeIn(duration: 1300.ms)
                                    .slideY(begin: 0.5),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    labelStyle: const TextStyle(fontFamily: "Poppins"),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF2E335A).withOpacity(0.8)
                                        : Colors.grey[100],
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.orangeAccent
                                            : Colors.purpleAccent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? "Required" : null,
                                )
                                    .animate()
                                    .fadeIn(duration: 1400.ms)
                                    .slideY(begin: 0.5),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _whatsappController,
                                  decoration: InputDecoration(
                                    labelText: "No. WhatsApp",
                                    labelStyle: const TextStyle(fontFamily: "Poppins"),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF2E335A).withOpacity(0.8)
                                        : Colors.grey[100],
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? Colors.orangeAccent
                                            : Colors.purpleAccent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value?.isEmpty ?? true ? "Required" : null,
                                )
                                    .animate()
                                    .fadeIn(duration: 1500.ms)
                                    .slideY(begin: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Promo Code
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: isDark
                          ? const Color(0xFF2E335A).withOpacity(0.9)
                          : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2E335A), const Color(0xFF3A4060)]
                                : [Colors.white, const Color(0xFFF0F4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Punya Kode Promo?",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ).animate().fadeIn(duration: 1600.ms),
                                  Icon(Icons.local_offer,
                                          color: Colors.orangeAccent, size: 30)
                                      .animate()
                                      .fadeIn(duration: 1650.ms)
                                      .scale(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _promoCodeController,
                                decoration: InputDecoration(
                                  hintText: "Masukan kode promo",
                                  hintStyle: TextStyle(
                                      color:
                                          isDark ? Colors.white70 : Colors.grey),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF2E335A).withOpacity(0.8)
                                      : Colors.grey[100],
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.orangeAccent
                                          : Colors.purpleAccent,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () {
                                      print(
                                          "Promo code applied: ${_promoCodeController.text}");
                                    },
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 1700.ms)
                                  .slideY(begin: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            print(
                                "Order submitted: Game ID: ${_gameIdController.text}, "
                                "Email: ${_emailController.text}, "
                                "WhatsApp: ${_whatsappController.text}, "
                                "Package: $_selectedPackage, "
                                "Stars: $_starCount, "
                                "Total: ${_calculatePrice()}, "
                                "Payment: $_selectedPayment, "
                                "Promo: ${_promoCodeController.text}");
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA500),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                          elevation: 10,
                        ),
                        child: const Text(
                          "Pesan Sekarang",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ).animate().fadeIn(duration: 1800.ms).scale(begin: Offset(0, 9)),
                    ),
                    const SizedBox(height: 25),
                    // Footer Information
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: isDark
                          ? const Color(0xFF2E335A).withOpacity(0.9)
                          : Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF2E335A), const Color(0xFF3A4060)]
                                : [Colors.white, const Color(0xFFF0F4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Top Up Game Voucher MBA",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ).animate().fadeIn(duration: 1900.ms),
                              const SizedBox(height: 10),
                              Text(
                                "Arena of Valor, Honor of Kings, Legends of Legends, Mobile Legends, Mobile Legends: Bang Bang, Arena of Valor, Free Fire, PUBG Mobile, Call of Duty Mobile, dan lainnya...",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageOption(String title, String pricePerStar, String rank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(Icons.star, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      subtitle: Text(
        pricePerStar,
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
      ),
      value: rank,
      groupValue: _selectedPackage,
      onChanged: (value) {
        setState(() {
          _selectedPackage = value;
        });
      },
      activeColor: Colors.orangeAccent,
      tileColor:
          isDark ? const Color(0xFF2E335A).withOpacity(0.8) : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.5);
  }

  Widget _buildPaymentOption(String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(_getPaymentIcon(title), color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      value: value,
      groupValue: _selectedPayment,
      onChanged: (value) {
        setState(() {
          _selectedPayment = value;
        });
      },
      activeColor: Colors.orangeAccent,
      tileColor:
          isDark ? const Color(0xFF2E335A).withOpacity(0.8) : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.5);
  }

  IconData _getPaymentIcon(String title) {
    switch (title) {
      case "Gopay":
        return Icons.payment;
      case "OVO":
        return Icons.account_balance_wallet;
      case "Dana":
        return Icons.monetization_on;
      case "Bank Transfer":
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

// Enhanced WaveClipper for a smoother wave effect
class EnhancedWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 120);

    var firstControlPoint = Offset(size.width / 6, size.height - 60);
    var firstEndPoint = Offset(size.width / 2, size.height - 100);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(5 * size.width / 6, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 120);
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