import 'package:fikzuas/core/themes/theme_provider.dart';
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
  _HistoryPageRedesignedState createState() => _HistoryPageRedesignedState();
}

class _HistoryPageRedesignedState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  String _sortOption = "Newest First";
  List<Map<String, dynamic>> historyCategories = [];

  // Dashboard-style stats
  Map<String, dynamic> _stats = {
    'totalTransactions': 0,
    'totalAmount': 0.0,
    'completedTransactions': 0,
    'pendingTransactions': 0,
  };

  final List<Map<String, dynamic>> defaultCategories = [
    {
      "name": "All",
      "icon": Icons.dashboard,
      "transaction_type": "all",
      "items": <Map<String, dynamic>>[],
      "color": Colors.blue,
    },
    {
      "name": "PC Rental",
      "icon": Icons.computer,
      "transaction_type": "pc_booking",
      "items": <Map<String, dynamic>>[],
      "color": Colors.purple,
    },
    {
      "name": "Top Up",
      "icon": Icons.account_balance_wallet,
      "transaction_type": "topup",
      "items": <Map<String, dynamic>>[],
      "color": Colors.green,
    },
    {
      "name": "Joki",
      "icon": Icons.sports_esports,
      "transaction_type": "joki",
      "items": <Map<String, dynamic>>[],
      "color": Colors.orange,
    },
    {
      "name": "Console",
      "icon": Icons.videogame_asset,
      "transaction_type": "console_booking",
      "items": <Map<String, dynamic>>[],
      "color": Colors.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    try {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );
      _fadeAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      );
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      );
      _tabController =
          TabController(length: defaultCategories.length, vsync: this);
      _fetchHistory(widget.refreshOnLoad);
      _controller.forward();
      _tabController.addListener(_onTabChanged);
    } catch (e) {
      print('Animation initialization error: $e');
    }
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

  void _calculateStats() {
    int totalTrans = 0;
    double totalAmt = 0.0;
    int completed = 0;
    int pending = 0;

    for (var category in historyCategories) {
      if (category['name'] == 'All') {
        List<Map<String, dynamic>> allItems = category['items'];
        totalTrans = allItems.length;

        for (var item in allItems) {
          String amountStr = item['amount'] as String? ?? 'Rp 0';
          // Hapus "Rp " dan ganti koma dengan titik sebelum parsing
          double amount = double.tryParse(amountStr
                  .replaceAll('Rp ', '')
                  .replaceAll('.', '')
                  .replaceAll(',', '.')) ??
              0.0;
          totalAmt += amount;

          String status = (item['status'] as String? ?? '').toLowerCase();
          if (status == 'completed') {
            completed++;
          } else if (status == 'pending') {
            pending++;
          }
        }
        break;
      }
    }

    setState(() {
      _stats = {
        'totalTransactions': totalTrans,
        'totalAmount': totalAmt,
        'completedTransactions': completed,
        'pendingTransactions': pending,
      };
    });
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
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          historyCategories =
              List<Map<String, dynamic>>.from(defaultCategories);
          List<dynamic> transactions = data['data'] is List ? data['data'] : [];

          for (var transaction in transactions) {
            String? transactionType =
                transaction['transaction_type'] as String?;
            Map<String, dynamic> item = {
              'title': transaction['title'] as String? ?? 'Unknown Transaction',
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

          _calculateStats();

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
          return (double.tryParse((b['amount'] as String)
                      .replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0)
              .compareTo(double.tryParse((a['amount'] as String)
                      .replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0);
        case "Lowest Amount":
          return (double.tryParse((a['amount'] as String)
                      .replaceAll(RegExp(r'[^\d.]'), '')) ??
                  0)
              .compareTo(double.tryParse((b['amount'] as String)
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                // Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: buildHeader(context, isDark),
                ),
                SizedBox(height: 24),
                // Stats Cards
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildStatsCards(
                      context, primaryColor, secondaryColor, isDark),
                ),
                SizedBox(height: 24),
                // Quick Actions

                SizedBox(height: 24),
                // Categories Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    "Transaction Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: buildCategoryGrid(context, isDark),
                ),
                SizedBox(height: 24),
                // Recent Transactions
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: buildRecentTransactions(context, isDark),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
                arguments: {'selectedIndex': 0},
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transaction",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.refresh,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onPressed: () => _fetchHistory(true),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
              onSelected: (value) => setState(() => _sortOption = value),
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: "Newest First", child: Text("Newest First")),
                PopupMenuItem(
                    value: "Oldest First", child: Text("Oldest First")),
                PopupMenuItem(
                    value: "Highest Amount", child: Text("Highest Amount")),
                PopupMenuItem(
                    value: "Lowest Amount", child: Text("Lowest Amount")),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildStatsCards(BuildContext context, Color primaryColor,
      Color secondaryColor, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Transaction Overview",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Rp ${NumberFormat('#,###').format(_stats['totalAmount'])}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Total", "${_stats['totalTransactions']}",
                  Icons.receipt_long),
              _buildStatItem("Completed", "${_stats['completedTransactions']}",
                  Icons.check_circle),
              _buildStatItem(
                  "Pending", "${_stats['pendingTransactions']}", Icons.pending),
              _buildStatItem("Active", "Live", Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildCategoryGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics:
          NeverScrollableScrollPhysics(), // Prevent grid from scrolling independently
      crossAxisCount: 2,
      childAspectRatio:
          1.5, // Reduced from 1.8 to 1.5 to make boxes taller (lower ratio = taller)
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: defaultCategories.map((category) {
        int itemCount = category['items'].length;
        return _buildCategoryCard(
          category['name'],
          category['icon'],
          category['color'],
          itemCount,
          () => _showCategoryDetails(context, category),
          isDark,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, int count,
      VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
            maxHeight: 180), // Increased from 160 to 180 to make it taller
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 12), // Increased from 8 to 12 for better spacing
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Add extra space or content if needed to utilize height
              Spacer(), // Pushes content to the top, utilizing extra height
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecentTransactions(BuildContext context, bool isDark) {
    List<Map<String, dynamic>> recentItems = [];
    if (historyCategories.isNotEmpty) {
      var allCategory = historyCategories.firstWhere(
          (cat) => cat['name'] == 'All',
          orElse: () => {'items': []});
      recentItems = List.from(allCategory['items']);
      _sortItems(recentItems);
      recentItems = recentItems.take(5).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            TextButton(
              onPressed: () => _showAllTransactions(context),
              child: Text("View All"),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (recentItems.isEmpty)
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history,
                      size: 48,
                      color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    "No recent transactions",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...recentItems.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> transaction = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getCategoryColor(
                      transaction['category'] as String? ?? 'Unknown'),
                  child: Icon(
                    _getCategoryIcon(
                        transaction['category'] as String? ?? 'Unknown'),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  transaction["title"] as String? ?? 'Unknown Transaction',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  transaction["date"] as String? ?? 'Invalid Date',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      transaction["amount"] as String? ?? 'Rp 0',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                                transaction["status"] as String? ?? 'Unknown')
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction["status"] as String? ?? 'Unknown',
                        style: TextStyle(
                          color: _getStatusColor(
                              transaction["status"] as String? ?? 'Unknown'),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () => _showEnhancedDetailsDialog(context, transaction),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index))
                .scale();
          }).toList(),
      ],
    );
  }

  void _showCategoryDetails(
      BuildContext context, Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(category: category),
      ),
    );
  }

  void _showAllTransactions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening full transaction list...')),
    );
  }

  void _showEnhancedDetailsDialog(
      BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Provider.of<ThemeProvider>(context).isDark
            ? Color(0xFF1F2937)
            : Colors.white,
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        transaction["title"] as String? ??
                            'Unknown Transaction',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Provider.of<ThemeProvider>(context).isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
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
                _buildDetailRow(
                    Icons.calendar_today,
                    "Date",
                    transaction["date"] as String? ?? 'Invalid Date',
                    Colors.blue),
                SizedBox(height: 15),
                _buildDetailRow(
                    Icons.info_outline,
                    "Details",
                    transaction["details"] as String? ?? 'No details available',
                    Colors.orange),
                SizedBox(height: 15),
                _buildDetailRow(
                    Icons.confirmation_number,
                    "Transaction ID",
                    transaction["transactionId"] as String? ?? 'Unknown ID',
                    Colors.purple),
                SizedBox(height: 15),
                _buildDetailRow(
                    Icons.check_circle,
                    "Status",
                    transaction["status"] as String? ?? 'Unknown',
                    _getStatusColor(
                        transaction["status"] as String? ?? 'Unknown')),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Provider.of<ThemeProvider>(context).isDark
                              ? Color(0xFF4B5EFC)
                              : Color(0xFF4B5EFC),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color color) {
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
        Flexible(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                color: Provider.of<ThemeProvider>(context).isDark
                    ? Colors.white
                    : Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
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
    switch (category.toLowerCase()) {
      case "pc_booking":
      case "pc rental":
        return Colors.blue;
      case "topup":
      case "top up":
        return Colors.purple;
      case "joki":
        return Colors.teal;
      case "console_booking":
      case "console":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "pc_booking":
      case "pc rental":
        return Icons.computer;
      case "topup":
      case "top up":
        return Icons.account_balance_wallet;
      case "joki":
        return Icons.sports_esports;
      case "console_booking":
      case "console":
        return Icons.videogame_asset;
      default:
        return Icons.history;
    }
  }
}

// Category Detail Page
class CategoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryDetailPage({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    List<Map<String, dynamic>> items = category['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(category['name'] ?? 'Category'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'], size: 64, color: category['color']),
                  SizedBox(height: 16),
                  Text(
                    'No transactions in ${category['name']}',
                    style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final transaction = items[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: category['color'],
                      child: Icon(category['icon'], color: Colors.white),
                    ),
                    title: Text(
                      transaction['title'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(transaction['date'] ?? 'Unknown date'),
                    trailing: Text(
                      transaction['amount'] ?? 'Rp 0',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            ),
    );
  }
}
