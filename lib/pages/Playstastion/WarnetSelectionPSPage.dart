import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fikzuas/pages/Playstastion/PsListPage.dart';
import 'package:fikzuas/core/BookingState/booking_state.dart';
import 'package:fikzuas/main.dart';
import '../Warnet/WarnetSelectionPage.dart'; // For WaveClipper

class WarnetSelectionPSPage extends StatefulWidget {
  @override
  _WarnetSelectionPSPageState createState() => _WarnetSelectionPSPageState();
}

class _WarnetSelectionPSPageState extends State<WarnetSelectionPSPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String searchQuery = '';
  bool isLoading = false;
  List<Map<String, dynamic>> allWarnets = [];
  List<Map<String, dynamic>> filteredWarnets = [];
  String? errorMessage;

  // Filter options
  String sortBy = 'rating'; // 'rating', 'name', 'availablePs'
  bool showOnlyAvailable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    _fetchWarnets();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchWarnets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/warnets'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allWarnets = data.map((item) => {
            "id": item['id_warnet'],
            "name": item['warnet_name'],
            "address": item['address'],
            "availablePs": item['total_ps'], // Use total_ps from API
            "rating": item['stars'] != null ? double.parse(item['stars'].toString()) : 0.0,
            "image": "assets/img/net${(data.indexOf(item) % 3) + 1}.png",
          }).toList();
          _applyFilters();
          isLoading = false;
        });
        return allWarnets;
      } else {
        throw Exception('Failed to load warnet data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      return [];
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> result = List.from(allWarnets);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((warnet) =>
        warnet['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
        warnet['address'].toString().toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // Apply availability filter
    if (showOnlyAvailable) {
      result = result.where((warnet) => warnet['availablePs'] > 0).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'rating':
        result.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'name':
        result.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'availablePs':
        result.sort((a, b) => (b['availablePs'] as int).compareTo(a['availablePs'] as int));
        break;
    }

    setState(() {
      filteredWarnets = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);
    final accentColor = isDark ? Color(0xFFFFB800) : Color(0xFFFFB800);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF191B2F), Color(0xFF191B2F)]
                : [Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                    Text(
                      "Find Warnet - PlayStations",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF262A43) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _applyFilters();
                            });
                          },
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search warnet for PlayStations...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),

              SizedBox(height: 16),

              // Warnet list
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      )
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[300],
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading warnets',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _fetchWarnets,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredWarnets.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No warnets found',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try changing your search or filters',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredWarnets.length,
                                itemBuilder: (context, index) {
                                  final warnet = filteredWarnets[index];
                                  return _buildWarnetCard(context, warnet, index, isDark, primaryColor, accentColor);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarnetCard(BuildContext context, Map<String, dynamic> warnet, int index, bool isDark, Color primaryColor, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => BookingState(),
              child: PsListPage(
                warnetName: warnet['name'],
                warnetId: warnet['id'],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF262A43) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warnet image with rating overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    warnet['image'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: isDark ? Color(0xFF1F2236) : Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          warnet['rating'].toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Warnet details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warnet['name'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warnet['address'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.videogame_asset,
                        label: "${warnet['availablePs']} PlayStations",
                        color: primaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => BookingState(),
                            child: PsListPage(
                              warnetName: warnet['name'],
                              warnetId: warnet['id'],
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text(
                      "Select",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms, delay: (index * 100).ms).slideY(begin: 0.1, end: 0, delay: (index * 100).ms),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = isDark ? Color(0xFF6C5DD3) : Color(0xFF6C5DD3);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF191B2F) : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filter & Sort",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Sort by",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSortChip('Rating', 'rating', setModalState, isDark, primaryColor),
                      _buildSortChip('Name', 'name', setModalState, isDark, primaryColor),
                      _buildSortChip('Available PlayStations', 'availablePs', setModalState, isDark, primaryColor),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Switch(
                        value: showOnlyAvailable,
                        onChanged: (value) {
                          setModalState(() {
                            showOnlyAvailable = value;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Show only available",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Apply Filters",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(String label, String value, StateSetter setModalState, bool isDark, Color primaryColor) {
    final isSelected = sortBy == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setModalState(() {
            sortBy = value;
          });
        }
      },
      backgroundColor: isDark ? Color(0xFF262A43) : Colors.grey[200],
      selectedColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        fontFamily: 'Poppins',
      ),
    );
  }
}