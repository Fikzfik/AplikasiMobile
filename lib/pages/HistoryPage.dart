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
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String _sortOption = "Newest First";
  List<Map<String, dynamic>> historyCategories = [];

  final List<Map<String, dynamic>> defaultCategories = [
    {
      "name": "All",
      "icon": Icons.history,
      "transaction_type": "all",
      "items": <Map<String, dynamic>>[]
    },
    {
      "name": "PC Rental",
      "icon": Icons.computer,
      "transaction_type": "pc_booking",
      "items": <Map<String, dynamic>>[]
    },
    {
      "name": "Top Up",
      "icon": Icons.account_balance_wallet,
      "transaction_type": "topup",
      "items": <Map<String, dynamic>>[]
    },
    {
      "name": "Joki",
      "icon": Icons.sports_esports,
      "transaction_type": "joki",
      "items": <Map<String, dynamic>>[]
    },
    {
      "name": "Console",
      "icon": Icons.videogame_asset,
      "transaction_type": "console_booking",
      "items": <Map<String, dynamic>>[]
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
      curve: Curves.easeInOut,
    );
    _tabController = TabController(length: defaultCategories.length, vsync: this);
    _fetchHistory(widget.refreshOnLoad);
    _controller.forward();
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _tabController.animateTo(_tabController.index);
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt('id_user') ?? 0,
      'token': prefs.getString('token'),
    };
  }

  Future<void> _fetchHistory(bool forceRefresh) async {
    setState(() => _isLoading = true);

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
            backgroundColor: Colors.redAccent),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/history/$userId'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          historyCategories = List<Map<String, dynamic>>.from(defaultCategories);
          List<dynamic> transactions = data['data'] is List ? data['data'] : [];
          for (var transaction in transactions) {
            String? transactionType = transaction['transaction_type'] as String?;
            Map<String, dynamic> item = {
              'title':
                  transaction['title'] as String? ?? 'Unknown Transaction',
              'amount': transaction['amount'] as String? ?? 'Rp 0',
              'date': transaction['date'] as String? ?? 'Invalid Date',
              'details':
                  transaction['details'] as String? ?? 'No details available',
              'transactionId':
                  transaction['transactionId'] as String? ?? 'Unknown ID',
              'status': transaction['status'] as String? ?? 'Completed',
              'category':
                  transaction['category'] as String? ?? 'Unknown Category',
            };
            for (var category in historyCategories) {
              if ((transactionType != null &&
                      category['transaction_type'] == transactionType) ||
                  category['name'] == 'All') {
                category['items'].add(item);
              }
            }
          }
          setState(() {
            _tabController.dispose();
            _tabController =
                TabController(length: historyCategories.length, vsync: this);
            _tabController.addListener(_onTabChanged);
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
            backgroundColor: Colors.redAccent),
      );
    }
  }

  void _sortItems(List<Map<String, dynamic>> items) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    items.sort((a, b) {
      if (a['date'] == 'Invalid Date' || b['date'] == 'Invalid Date') return 0;
      final aStart = (a['date'] as String).split(' to ')[0].trim();
      final bStart = (b['date'] as String).split(' to ')[0].trim();
      DateTime aDate = dateFormat.parse(aStart);
      DateTime bDate = dateFormat.parse(bStart);
      switch (_sortOption) {
        case "Newest First":
          return bDate.compareTo(aDate);
        case "Oldest First":
          return aDate.compareTo(bDate);
        case "Highest Amount":
          return (double.tryParse(
                      (b['amount'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0)
              .compareTo(
                  double.tryParse((a['amount'] as String)
                          .replaceAll(RegExp(r'[^\d.]'), '')) ??
                      0);
        case "Lowest Amount":
          return (double.tryParse(
                      (a['amount'] as String).replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0)
              .compareTo(
                  double.tryParse((b['amount'] as String)
                          .replaceAll(RegExp(r'[^\d.]'), '')) ??
                      0);
        default:
          return bDate.compareTo(aDate);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                            arguments: {'selectedIndex': 0},
                          ),
                        ),
                        Text(
                          "Transaction History",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter'),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list,
                          color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      onSelected: (value) => setState(() => _sortOption = value),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: "Newest First", child: Text("Newest First")),
                        PopupMenuItem(value: "Oldest First", child: Text("Oldest First")),
                        PopupMenuItem(value: "Highest Amount", child: Text("Highest Amount")),
                        PopupMenuItem(value: "Lowest Amount", child: Text("Lowest Amount")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (historyCategories.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF1F2937) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      isDark ? Colors.grey[400] : Colors.grey[600],
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  tabs: historyCategories.map((category) => Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(category["icon"], size: 18),
                            SizedBox(width: 4),
                            Text(category["name"] as String? ?? 'Unknown'),
                          ],
                        ),
                      )).toList(),
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
                          if (sortedItems.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      Icons.history,
                                      size: 64,
                                      color: isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[300]),
                                  SizedBox(height: 16),
                                  Text(
                                    "No transactions found for ${category["name"] as String? ?? 'Unknown'}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return RefreshIndicator(
                            onRefresh: () => _fetchHistory(true),
                            child: ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: sortedItems.length,
                              itemBuilder: (context, index) {
                                final transaction = sortedItems[index];
                                return GestureDetector(
                                  onTap: () =>
                                      _showEnhancedDetailsDialog(context, transaction),
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: isDark ? Color(0xFF1F2937) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: Offset(0, 5))
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: _getCategoryColor(
                                                transaction['transaction_type']
                                                        as String? ??
                                                    'Unknown'),
                                            child: Icon(
                                                _getCategoryIcon(
                                                    transaction['transaction_type']
                                                            as String? ??
                                                        'Unknown'),
                                                size: 20,
                                                color: Colors.white),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  transaction["title"] as String? ??
                                                      'Unknown Transaction',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter'),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  transaction["date"] as String? ??
                                                      'Invalid Date',
                                                  style: TextStyle(
                                                      color: isDark
                                                          ? Colors.grey[400]
                                                          : Colors.grey[600],
                                                      fontSize: 14,
                                                      fontFamily: 'Inter'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                transaction["amount"] as String? ??
                                                    'Rp 0',
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                    fontFamily: 'Inter'),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          transaction["status"]
                                                                  as String? ??
                                                              'Unknown')
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  transaction["status"] as String? ??
                                                      'Unknown',
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                        transaction["status"]
                                                                as String? ??
                                                            'Unknown'),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(
                                      delay: Duration(milliseconds: 100 * index))
                                      .scale(),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    'No history categories available.',
                    style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'Inter'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEnhancedDetailsDialog(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Provider.of<ThemeProvider>(context).isDark ? Color(0xFF1F2937) : Colors.white,
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction["title"] as String? ?? 'Unknown Transaction',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Provider.of<ThemeProvider>(context).isDark
                              ? Colors.white
                              : Colors.black87),
                    ),
                    IconButton(
                      icon: Icon(
                          Icons.close,
                          color: Provider.of<ThemeProvider>(context).isDark
                              ? Colors.grey[400]
                              : Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildDetailRow(Icons.monetization_on, "Amount",
                    transaction["amount"] as String? ?? 'Rp 0', Colors.green),
                SizedBox(height: 15),
                _buildDetailRow(Icons.calendar_today, "Date",
                    transaction["date"] as String? ?? 'Invalid Date', Colors.blue),
                SizedBox(height: 15),
                _buildDetailRow(Icons.info_outline, "Details",
                    transaction["details"] as String? ?? 'No details available', Colors.orange),
                SizedBox(height: 15),
                _buildDetailRow(Icons.confirmation_number, "Transaction ID",
                    transaction["transactionId"] as String? ?? 'Unknown ID', Colors.purple),
                SizedBox(height: 15),
                _buildDetailRow(Icons.check_circle, "Status",
                    transaction["status"] as String? ?? 'Unknown',
                    _getStatusColor(transaction["status"] as String? ?? 'Unknown')),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Provider.of<ThemeProvider>(context).isDark
                          ? Color(0xFF4B5EFC)
                          : Color(0xFF4B5EFC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text("Close",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            color: Colors.white)),
                  ).animate().scale(duration: 300.ms),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),
          ),
        ),
      ).animate().scale(duration: 300.ms),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              color: Provider.of<ThemeProvider>(context).isDark
                  ? Colors.grey[400]
                  : Colors.grey[700]),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: Provider.of<ThemeProvider>(context).isDark
                  ? Colors.white
                  : Colors.black87),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "pc_booking":
        return Colors.blue;
      case "topup":
        return Colors.purple;
      case "joki":
        return Colors.teal;
      case "console_booking":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "pc_booking":
      case "PC Rental":
        return Icons.computer;
      case "topup":
      case "Top Up":
        return Icons.account_balance_wallet;
      case "joki":
      case "Joki":
        return Icons.sports_esports;
      case "console_booking":
      case "Console":
        return Icons.videogame_asset;
      default:
        return Icons.history;
    }
  }
}