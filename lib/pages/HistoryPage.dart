import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/widgets/clipper.dart';

class HistoryPage extends StatefulWidget {
  final bool refreshOnLoad;

  const HistoryPage({Key? key, this.refreshOnLoad = false}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  String _sortOption = "Newest First";
  List<Map<String, dynamic>> historyCategories = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> staticCategories = [
    {
      "name": "Top Up",
      "icon": Icons.account_balance_wallet,
      "items": [
        {
          "title": "Top Up Diamond ML",
          "amount": "Rp 50.000",
          "date": "20 Mar 2025",
          "details": "Top up 300 Diamonds for Mobile Legends.",
          "transactionId": "TXN12345",
        },
        {
          "title": "Top Up UC PUBG",
          "amount": "Rp 100.000",
          "date": "18 Mar 2025",
          "details": "Top up 600 UC for PUBG Mobile.",
          "transactionId": "TXN12346",
        },
      ]
    },
    {
      "name": "Joki",
      "icon": Icons.sports_esports,
      "items": [
        {
          "title": "Joki Mythic ML",
          "amount": "Rp 200.000",
          "date": "15 Mar 2025",
          "details": "Rank boost from Legend to Mythic in Mobile Legends.",
          "transactionId": "TXN12347",
        },
      ]
    },
    {
      "name": "Sewa PS",
      "icon": Icons.videogame_asset,
      "items": [
        {
          "title": "Sewa PS5 (3 Jam)",
          "amount": "Rp 30.000",
          "date": "12 Mar 2025",
          "details": "Rented PS5 for 3 hours at GameZone.",
          "transactionId": "TXN12349",
        },
        {
          "title": "Beli Stik PS Baru",
          "amount": "Rp 150.000",
          "date": "10 Mar 2025",
          "details": "Purchased a new PS5 controller.",
          "transactionId": "TXN12350",
        },
      ]
    }
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

  Future<void> _fetchHistory(bool forceRefresh) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/history/1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            historyCategories = [...staticCategories, data['data']];
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
        historyCategories = staticCategories;
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
      print("Error sorting items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Provider.of<ThemeProvider>(context).isDark;

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
              _fetchHistory(true); // Manual refresh
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
        bottom: historyCategories.isEmpty
            ? null
            : TabBar(
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : historyCategories.isEmpty
              ? Center(child: Text('No history available.'))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: screenHeight * 0.65,
                          child: ClipPath(
                            clipper: WaveClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFF2C2F50), const Color(0xFF1A1D40).withOpacity(0.9)]
                                      : [const Color(0xFF3A3D60), const Color(0xFF2C2F50).withOpacity(0.85)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sort By",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                ),
                                DropdownButton<String>(
                                  value: _sortOption,
                                  items: ["Newest First", "Oldest First"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _sortOption = newValue!;
                                    });
                                  },
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                  dropdownColor: isDark ? const Color(0xFF1A1D40) : Colors.white,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: screenHeight * 0.7,
                              child: TabBarView(
                                controller: _tabController,
                                children: historyCategories.map((category) {
                                  List<Map<String, dynamic>> sortedItems = List.from(category["items"]);
                                  _sortItems(sortedItems);
                                  return ListView.builder(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}