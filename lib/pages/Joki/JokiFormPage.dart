import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/Joki/JasaJokiPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/animation_builder/custom_animation_builder.dart';
import 'package:fikzuas/core/themes/theme_provider.dart';

class JokiServicePage extends StatefulWidget {
  final String gameName;

  const JokiServicePage({super.key, required this.gameName});

  @override
  State<JokiServicePage> createState() => _JokiServicePageState();
}

class _JokiServicePageState extends State<JokiServicePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedPackage;
  String? _selectedPaymentMethod;
  int? _starCount;
  final _formKey = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _promoCodeController = TextEditingController();
  bool _isLoading = false;
  String userName = "Loading...";
  int userBalance = 0;
  String? authToken;

  final List<Map<String, dynamic>> packages = [
    {
      "name": "Epic Rank",
      "description": "Boost to Epic Rank",
      "price": 6000,
      "icon": Icons.star_rounded,
      "color": Color(0xFF4CC9F0),
    },
    {
      "name": "Legend Rank",
      "description": "Boost to Legend Rank",
      "price": 8000,
      "icon": Icons.auto_awesome_rounded,
      "color": Color(0xFF4361EE),
    },
    {
      "name": "Mythic Rank",
      "description": "Boost to Mythic Rank",
      "price": 10000,
      "icon": Icons.workspace_premium_rounded,
      "color": Color(0xFFFF4D6D),
    },
    {
      "name": "Mythical Glory",
      "description": "Boost to Mythical Glory",
      "price": 15000,
      "icon": Icons.diamond_rounded,
      "color": Color(0xFF7209B7),
    },
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Gopay",
      "icon": Icons.account_balance_wallet_rounded,
      "color": Color(0xFF4CC9F0)
    },
    {"name": "OVO", "icon": Icons.payment_rounded, "color": Color(0xFF4361EE)},
    {
      "name": "Dana",
      "icon": Icons.monetization_on_rounded,
      "color": Color(0xFFFF4D6D)
    },
    {
      "name": "Bank Transfer",
      "icon": Icons.account_balance_rounded,
      "color": Color(0xFF7209B7)
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAuthToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gameIdController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _promoCodeController.dispose();
    super.dispose();
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
        userName = "Guest User";
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
          userName = "Failed to Load";
          userBalance = 0;
        });
      }
    } catch (e) {
      setState(() {
        userName = "Error Loading";
        userBalance = 0;
      });
    }
  }

  String _calculatePrice() {
    if (_selectedPackage == null || _starCount == null) return "Rp 0";

    int pricePerStar = 0;
    switch (_selectedPackage) {
      case "Epic Rank":
        pricePerStar = 6000;
        break;
      case "Legend Rank":
        pricePerStar = 8000;
        break;
      case "Mythic Rank":
        pricePerStar = 10000;
        break;
      case "Mythical Glory":
        pricePerStar = 15000;
        break;
      default:
        pricePerStar = 0;
    }

    final totalPrice = pricePerStar * _starCount!;
    return "Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  int _calculateAmount() {
    if (_selectedPackage == null || _starCount == null) return 0;

    int pricePerStar = 0;
    switch (_selectedPackage) {
      case "Epic Rank":
        pricePerStar = 6000;
        break;
      case "Legend Rank":
        pricePerStar = 8000;
        break;
      case "Mythic Rank":
        pricePerStar = 10000;
        break;
      case "Mythical Glory":
        pricePerStar = 15000;
        break;
      default:
        pricePerStar = 0;
    }

    return pricePerStar * _starCount!;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() ||
        _selectedPackage == null ||
        _starCount == null ||
        _starCount! <= 0 ||
        _selectedPaymentMethod == null) {
      _showErrorSnackBar("Please fill in all required fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(Duration(seconds: 2)); // Simulate network request

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/jasa_joki'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'game_name': widget.gameName,
          'package': _selectedPackage,
          'star_count': _starCount,
          'payment_method': _selectedPaymentMethod,
          'game_id': _gameIdController.text,
          'email': _emailController.text,
          'whatsapp': _whatsappController.text,
          'amount': _calculateAmount(),
          'promo_code': _promoCodeController.text.isNotEmpty
              ? _promoCodeController.text
              : null,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar("Failed to submit order. Please try again.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFFF4D6D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CC9F0),
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              "Success!",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your boosting order for ${widget.gameName} has been submitted successfully.",
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black12
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Details:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 5),
                  _buildOrderDetailRow("Package", _selectedPackage ?? ""),
                  _buildOrderDetailRow("Stars", "${_starCount ?? 0}"),
                  _buildOrderDetailRow("Game ID", _gameIdController.text),
                  _buildOrderDetailRow("Total", _calculatePrice()),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4361EE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Provider.of<ThemeProvider>(context).isDark;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated background
          BlurBackground(
            colors: isDarkMode
                ? [
                    Color(0xFF1A1F38),
                    Color(0xFF0D1028),
                    Color(0xFF2E0A46),
                    Color(0xFF0A0E21),
                  ]
                : [
                    Color(0xFFD1E5FF),
                    Color(0xFFE6F0FA),
                    Color(0xFFC1D5F0),
                    Color(0xFFF9FAFE),
                  ],
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDarkMode),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Game info
                          _buildGameInfo(isDarkMode),

                          // Tabs
                          _buildTabs(isDarkMode),

                          // Package selection
                          _buildSectionTitle(
                              "1. Select Boosting Package", Icons.star_rounded),
                          SizedBox(height: 15),
                          _buildPackageSelection(isDarkMode),

                          // Star count
                          _buildSectionTitle(
                              "2. Number of Stars", Icons.auto_awesome_rounded),
                          SizedBox(height: 15),
                          _buildStarCountInput(isDarkMode),

                          // Payment method
                          _buildSectionTitle("3. Select Payment Method",
                              Icons.payment_rounded),
                          SizedBox(height: 15),
                          _buildPaymentMethods(isDarkMode),

                          // Account data
                          _buildSectionTitle(
                              "4. Enter Account Details", Icons.person_rounded),
                          SizedBox(height: 15),
                          _buildAccountForm(isDarkMode),

                          // Promo code
                          _buildSectionTitle("5. Promo Code (Optional)",
                              Icons.local_offer_rounded),
                          SizedBox(height: 15),
                          _buildPromoCode(isDarkMode),

                          // Total price
                          _buildTotalPrice(isDarkMode),

                          // Submit button
                          _buildSubmitButton(isDarkMode),

                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildThemeToggle(isDarkMode),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassmorphicContainer(
              width: 45,
              height: 45,
              borderRadius: 15,
              blur: 20,
              alignment: Alignment.center,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                  (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDarkMode ? Colors.white : Colors.black87,
                size: 18,
              ),
            ),
          ),
          Text(
            "Boosting Service",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ).animate().fadeIn(duration: 600.ms),
          GlassmorphicContainer(
            width: 45,
            height: 45,
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
              ],
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: isDarkMode ? Colors.white : Colors.black87,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.gameName,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.2, end: 0),
          SizedBox(height: 5),
          Text(
            "Professional Boosting Service",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4CC9F0).withOpacity(isDarkMode ? 0.2 : 0.1),
                  Color(0xFF4361EE).withOpacity(isDarkMode ? 0.2 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Color(0xFF4CC9F0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CC9F0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF4CC9F0),
                    size: 24,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trusted Boosting Service",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Fast, secure, and professional boosting by top-ranked players",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 900.ms).scale(begin: Offset(0, 95)),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      height: 45,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [
              Color(0xFF4CC9F0),
              Color(0xFF4361EE),
            ],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(text: "Rank Boost"),
          Tab(text: "Win Boost"),
          Tab(text: "Placement"),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms);
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4CC9F0),
                  Color(0xFF4361EE),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          SizedBox(width: 15),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1100.ms);
  }

  Widget _buildPackageSelection(bool isDarkMode) {
    return Column(
      children: packages.map((package) {
        final isSelected = _selectedPackage == package["name"];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPackage = package["name"];
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 80,
              borderRadius: 15,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        package["color"].withOpacity(0.3),
                        package["color"].withOpacity(0.1),
                      ]
                    : [
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
                      ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        package["color"],
                        package["color"].withOpacity(0.5),
                      ]
                    : [
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: package["color"].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        package["icon"],
                        color: package["color"],
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            package["name"],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            package["description"],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            package["color"],
                            package["color"].withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Rp ${package["price"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(
            duration: 1200.ms);
      }).toList(),
    );
  }

  Widget _buildStarCountInput(bool isDarkMode) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 80,
      borderRadius: 15,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF4CC9F0).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.star_rounded,
                color: Color(0xFF4CC9F0),
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Number of Stars",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      _buildStarButton(1, isDarkMode),
                      _buildStarButton(2, isDarkMode),
                      _buildStarButton(3, isDarkMode),
                      _buildStarButton(4, isDarkMode),
                      _buildStarButton(5, isDarkMode),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              title: Text(
                                "Enter Star Count",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                              content: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Enter number of stars",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _starCount = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "OK",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4361EE),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Custom",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 1300.ms);
  }

  Widget _buildStarButton(int value, bool isDarkMode) {
    final isSelected = _starCount == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _starCount = value;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color(0xFF4CC9F0),
                    Color(0xFF4361EE),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05)),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode ? Colors.white30 : Colors.black12),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods(bool isDarkMode) {
    return Column(
      children: paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method["name"];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method["name"];
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 15),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 70,
              borderRadius: 15,
              blur: 20,
              alignment: Alignment.center,
              border: 2,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        method["color"].withOpacity(0.3),
                        method["color"].withOpacity(0.1),
                      ]
                    : [
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
                      ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        method["color"],
                        method["color"].withOpacity(0.5),
                      ]
                    : [
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                        (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: method["color"].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        method["icon"],
                        color: method["color"],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        method["name"],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: method["color"],
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(
            duration: 1400.ms);
      }).toList(),
    );
  }

  Widget _buildAccountForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          GlassmorphicContainer(
            width: double.infinity,
            height: 60,
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: _gameIdController,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Game ID",
                  hintStyle: GoogleFonts.poppins(
                    color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.38),
                  ),
                  prefixIcon: Icon(
                    Icons.gamepad_rounded,
                    color: Color(0xFF4CC9F0),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your Game ID";
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(height: 15),
          GlassmorphicContainer(
            width: double.infinity,
            height: 60,
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: _emailController,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: GoogleFonts.poppins(
                    color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.38),
                  ),
                  prefixIcon: Icon(
                    Icons.email_rounded,
                    color: Color(0xFF4361EE),
                  ),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(height: 15),
          GlassmorphicContainer(
            width: double.infinity,
            height: 60,
            borderRadius: 15,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
                (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: _whatsappController,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "WhatsApp Number",
                  hintStyle: GoogleFonts.poppins(
                    color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.38),
                  ),
                  prefixIcon: Icon(
                    Icons.phone_rounded,
                    color: Color(0xFFFF4D6D),
                  ),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your WhatsApp number";
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1500.ms);
  }

  Widget _buildPromoCode(bool isDarkMode) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 15,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_rounded,
              color: Color(0xFF7209B7),
            ),
            SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: _promoCodeController,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Enter promo code",
                  hintStyle: GoogleFonts.poppins(
                    color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.38),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7209B7),
                    Color(0xFF560BAD),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Apply",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 1600.ms);
  }

  Widget _buildTotalPrice(bool isDarkMode) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4CC9F0).withOpacity(isDarkMode ? 0.3 : 0.1),
            Color(0xFF4361EE).withOpacity(isDarkMode ? 0.3 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(0xFF4CC9F0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Price",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 5),
              Text(
                _calculatePrice(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF4CC9F0).withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF4CC9F0),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Secure Payment",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 1700.ms);
  }

  Widget _buildSubmitButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4CC9F0),
                Color(0xFF4361EE),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Place Order",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 1800.ms).scale(begin: Offset(0, 95));
  }

  Widget _buildThemeToggle(bool isDarkMode) {
    return GlassmorphicContainer(
      width: 50,
      height: 50,
      borderRadius: 25,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.14),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.2),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        onPressed: () {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          themeProvider.toggleTheme();
        },
      ),
    ).animate().fadeIn(duration: 1900.ms);
  }
}

class BlurBackground extends StatelessWidget {
  final List<Color>? colors;
  final bool? isDarkMode;

  const BlurBackground({Key? key, this.colors, this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? (isDarkMode ?? false
        ? [
            Color(0xFF1A1F38),
            Color(0xFF0D1028),
            Color(0xFF2E0A46),
            Color(0xFF0A0E21),
          ]
        : [
            Color(0xFFD1E5FF),
            Color(0xFFE6F0FA),
            Color(0xFFC1D5F0),
            Color(0xFFF9FAFE),
          ]);

    return SizedBox.expand(
      child: CustomAnimationBuilder<double>(
        control: Control.mirror,
        tween: Tween(begin: -1.0, end: 2.0),
        duration: const Duration(seconds: 20),
        builder: (context, value, child) {
          return Stack(
            children: [
              Positioned(
                top: -100,
                left: -100 + (value * 50),
                child: _buildGradientCircle(300, effectiveColors[0]),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                right: -100 + (value * -30),
                child: _buildGradientCircle(250, effectiveColors[1]),
              ),
              Positioned(
                bottom: -150,
                left: MediaQuery.of(context).size.width * 0.5 + (value * 40),
                child: _buildGradientCircle(350, effectiveColors[2]),
              ),
              // Overlay to darken and add texture
              Container(
                decoration: BoxDecoration(
                  color: effectiveColors[3].withOpacity(0.85),
                  backgroundBlendMode: BlendMode.multiply,
                ),
              ),
              // Noise texture overlay
              Opacity(
                opacity: 0.03,
                child: Image.asset(
                  'assets/img/noise_texture.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradientCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}