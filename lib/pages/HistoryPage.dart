import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';

class HistoryPage extends StatefulWidget {
  final bool refreshOnLoad;

  const HistoryPage({Key? key, this.refreshOnLoad = false}) : super(key: key);

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  String _sortOption = "Newest First";
  List<Map<String, dynamic>> historyCategories = [];
  bool _isLoading = true;

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
      "transaction_type": "topup",
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
      "transaction_type": "console_booking",
      "items": <Map<String, dynamic>>[],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    // Initialize TabController with default length
    _tabController =
        TabController(length: defaultCategories.length, vsync: this);
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
          historyCategories =
              List<Map<String, dynamic>>.from(defaultCategories);
          List<dynamic> transactions = data['data'] is List ? data['data'] : [];
          for (var transaction in transactions) {
            String? transactionType = transaction['transaction_type'];
            Map<String, dynamic> item = {
              'title': transaction['title'] ?? 'Unknown Transaction',
              'amount': transaction['amount'] ?? 'Rp 0',
              'date': transaction['date'] ?? 'Invalid Date',
              'details': transaction['details'] ?? 'No details available',
              'transactionId': transaction['transactionId'] ?? 'Unknown ID',
            };
            for (var category in historyCategories) {
              if (category['transaction_type'] == transactionType) {
                category['items'].add(item);
                break;
              }
            }
          }
          setState(() {
            // Update TabController length if necessary
            _tabController.dispose();
            _tabController =
                TabController(length: historyCategories.length, vsync: this);
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to fetch history: ${data['message']}');
        }
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      setState(() {
        historyCategories = defaultCategories;
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
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    try {
      items.sort((a, b) {
        if (a['date'] == 'Invalid Date' || b['date'] == 'Invalid Date') {
          return 0;
        }
        final aStart = a['date'].split(' to ')[0].trim();
        final bStart = b['date'].split(' to ')[0].trim();
        DateTime aDate = dateFormat.parse(aStart);
        DateTime bDate = dateFormat.parse(bStart);
        return _sortOption == "Newest First"
            ? bDate.compareTo(aDate)
            : aDate.compareTo(bDate);
      });
    } catch (e) {
      debugPrint('Error sorting items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: buildHeader(context),
            ),
            if (historyCategories.isNotEmpty) ...[
              Container(
                color: isDark
                    ? Theme.of(context).colorScheme.surface
                    : Colors.white,
                padding: EdgeInsets.symmetric(
                    vertical: 8), // Add vertical padding for better spacing
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false, // Ensure tabs stretch to fill width
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: 8), // Consistent padding
                  labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Smaller font for better fit
                      ),
                  unselectedLabelStyle:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                  unselectedLabelColor:
                      isDark ? Colors.grey[400] : Colors.grey[600],
                  labelColor: Theme.of(context).colorScheme.primary,
                  tabs: historyCategories.map((category) {
                    return Tab(
                      child: Container(
                        constraints: BoxConstraints(
                            minWidth:
                                100), // Ensure minimum width for consistency
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(category["icon"],
                                size: 18), // Smaller icon size
                            SizedBox(width: 6), // Reduced spacing
                            Flexible(
                              child: Text(
                                category["name"],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary))
                    : TabBarView(
                        controller: _tabController,
                        children: historyCategories.map((category) {
                          List<Map<String, dynamic>> sortedItems =
                              List.from(category["items"]);
                          _sortItems(sortedItems);
                          return sortedItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No transactions available for ${category["name"]}.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  itemCount: sortedItems.length,
                                  itemBuilder: (context, index) {
                                    final item = sortedItems[index];
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12),
                                      child: Card(
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        color: isDark
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                            : Colors.white,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(16),
                                          title: Text(
                                            item["title"],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 8),
                                              Text(
                                                "Amount: ${item["amount"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Colors.greenAccent,
                                                    ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Date: ${item["date"]}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: isDark
                                                          ? Colors.grey[400]
                                                          : Colors.grey[600],
                                                    ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                backgroundColor: isDark
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .surface
                                                    : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                title: Text(
                                                  item["title"],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Amount: ${item["amount"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Colors
                                                                .greenAccent,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "Date: ${item["date"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "Details: ${item["details"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "Transaction ID: ${item["transactionId"]}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text("Close",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                          .animate()
                                          .fadeIn(duration: 800.ms)
                                          .scale(duration: 800.ms),
                                    );
                                  },
                                );
                        }).toList(),
                      ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    'No history categories available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                backgroundImage:
                    NetworkImage("https://picsum.photos/id/798/200/300"),
              ),
              SizedBox(width: 12),
              Text(
                "Welcome, Gamer!",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.refresh,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () {
                  _fetchHistory(true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Refreshing history...'),
                        duration: Duration(seconds: 2)),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.notifications,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
