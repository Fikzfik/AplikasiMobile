import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  final bool refreshOnLoad;

  const HistoryPage({Key? key, this.refreshOnLoad = false}) : super(key: key);

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  String _sortOption = "Newest First";
  List<Map<String, dynamic>> historyCategories = [];
  bool _isLoading = true;

  // Definisikan kategori tetap untuk tabbar
  final List<Map<String, dynamic>> defaultCategories = [
    {
      "name": "PC Rental",
      "icon": Icons.computer,
      "transaction_type": "pc_booking",
      "items": <Map<String, dynamic>>[],
    },
    {
      "name": "Top Up",
      "icon": Icons.account_balance_wallet,
      "transaction_type": "top_up",
      "items": <Map<String, dynamic>>[],
    },
    {
      "name": "Joki",
      "icon": Icons.sports_esports,
      "transaction_type": "joki",
      "items": <Map<String, dynamic>>[],
    },
    {
      "name": "Sewa PS",
      "icon": Icons.videogame_asset,
      "transaction_type": "sewa_ps",
      "items": <Map<String, dynamic>>[],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _fetchHistory(widget.refreshOnLoad);
    _controller.forward();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt('id_user') ?? 0,
      'token': prefs.getString('token'),
    };
  }

  Future<void> _fetchHistory(bool forceRefresh) async {
    setState(() {
      _isLoading = true;
    });

    final userData = await _getUserData();
    final userId = userData['userId'];
    final token = userData['token'];

    if (userId == 0 || token == null) {
      setState(() {
        historyCategories = defaultCategories;
        _tabController = TabController(length: historyCategories.length, vsync: this);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to view history.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/history/$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Inisialisasi historyCategories dengan kategori default
          historyCategories = List<Map<String, dynamic>>.from(defaultCategories);

          // Ambil semua transaksi dari API
          List<dynamic> transactions = data['data'] is List ? data['data'] : [];

          // Kelompokkan transaksi berdasarkan transaction_type
          for (var transaction in transactions) {
            String? transactionType = transaction['transaction_type'];
            Map<String, dynamic> item = {
              'title': transaction['title'] ?? 'Unknown Transaction',
              'amount': transaction['amount'] ?? 'Rp 0',
              'date': transaction['date'] ?? 'Unknown Date',
              'details': transaction['details'] ?? 'No details available',
              'transactionId': transaction['transactionId'] ?? 'Unknown ID',
            };

            // Cari kategori yang sesuai berdasarkan transaction_type
            for (var category in historyCategories) {
              if (category['transaction_type'] == transactionType) {
                category['items'].add(item);
                break;
              }
            }
          }

          setState(() {
            _tabController = TabController(length: historyCategories.length, vsync: this);
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch history: ${data['message']}');
        }
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      setState(() {
        historyCategories = defaultCategories;
        _tabController = TabController(length: historyCategories.length, vsync: this);
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load history: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _sortItems(List<Map<String, dynamic>> items) {
    final dateFormat = DateFormat('dd MMM yyyy');
    try {
      if (_sortOption == "Newest First") {
        items.sort((a, b) => dateFormat.parse(b["date"]).compareTo(dateFormat.parse(a["date"])));
      } else {
        items.sort((a, b) => dateFormat.parse(a["date"]).compareTo(dateFormat.parse(b["date"])));
      }
    } catch (e) {
      debugPrint("Error sorting items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey,
                  border: Border.all(
                    color: isDark ? Colors.white : Colors.black54,
                    width: 3,
                  ),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage("https://picsum.photos/id/798/200/300"),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Welcome, Gamer!",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              _fetchHistory(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshing history...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.purple[700]!, Colors.deepPurple[400]!]
                    : [Colors.blue[300]!, Colors.purple[200]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.purple[900]!.withOpacity(0.5) : Colors.blue[200]!.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            labelColor: isDark ? Colors.white : Colors.black87,
            tabs: historyCategories.map((category) {
              return Container(
                width: screenWidth / historyCategories.length,
                child: Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category["icon"], size: 20, color: isDark ? Colors.white70 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(category["name"]),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: historyCategories.map((category) {
                List<Map<String, dynamic>> sortedItems = List.from(category["items"]);
                _sortItems(sortedItems);
                return sortedItems.isEmpty
                    ? Center(child: Text('No transactions available for ${category["name"]}.'))
                    : ListView.builder(
                        itemCount: sortedItems.length,
                        itemBuilder: (context, index) {
                          final item = sortedItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Theme.of(context).colorScheme.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      item["title"],
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            color: isDark ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Amount: ${item["amount"]}",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.greenAccent,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Date: ${item["date"]}",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Details: ${item["details"]}",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Transaction ID: ${item["transactionId"]}",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Close",
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: isDark ? Colors.white70 : Colors.black54,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Card(
                                elevation: Theme.of(context).cardTheme.elevation,
                                shape: Theme.of(context).cardTheme.shape,
                                color: isDark ? const Color(0xFF262A50) : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"],
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                      ).animate().fade(
                                            duration: 600.ms,
                                            curve: Curves.easeOut,
                                          ).scale(
                                            duration: 600.ms,
                                            curve: Curves.easeOut,
                                          ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Amount: ${item["amount"]}",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ).animate().fade(
                                            duration: 700.ms,
                                            curve: Curves.easeOut,
                                          ).scale(
                                            duration: 700.ms,
                                            curve: Curves.easeOut,
                                          ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Date: ${item["date"]}",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: isDark ? Colors.white70 : Colors.black54,
                                            ),
                                      ).animate().fade(
                                            duration: 700.ms,
                                            curve: Curves.easeOut,
                                          ).scale(
                                            duration: 700.ms,
                                            curve: Curves.easeOut,
                                          ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Details: ${item["details"]}",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: isDark ? Colors.white70 : Colors.black54,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ).animate().fade(
                                            duration: 800.ms,
                                            curve: Curves.easeOut,
                                          ).scale(
                                            duration: 800.ms,
                                            curve: Curves.easeOut,
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              }).toList(),
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