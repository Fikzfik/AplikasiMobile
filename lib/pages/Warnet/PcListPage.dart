// pc_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fikzuas/pages/Warnet/DateSelectionPage.dart';

class PcListPage extends StatefulWidget {
  final String warnetName;
  final int warnetId;

  const PcListPage({Key? key, required this.warnetName, required this.warnetId}) : super(key: key);

  @override
  _PcListPageState createState() => _PcListPageState();
}

class _PcListPageState extends State<PcListPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> pcs = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.forward();
    _fetchPcs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchPcs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/pcs?warnet_id=${widget.warnetId}'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          pcs = data.map((item) => {
            "id_pc": item['id_pc'],
            "pc_name": item['pc_name'],
            "is_available": item['is_available'] ?? true,
            "specs": item['specs'] ?? "Standard Gaming PC",
            "category": _assignRandomCategory(), // For demo purposes
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch PCs: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String _assignRandomCategory() {
    final categories = ['Gaming', 'Standard', 'Premium', 'VIP'];
    return categories[DateTime.now().millisecond % categories.length];
  }

  List<Map<String, dynamic>> getFilteredPcs() {
    if (selectedCategory == 'All') {
      return pcs;
    } else {
      return pcs.where((pc) => pc['category'] == selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      widget.warnetName,
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
                        Icons.info_outline_rounded,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              
              // PC Categories
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('All', isDark, primaryColor),
                    SizedBox(width: 8),
                    _buildCategoryChip('Gaming', isDark, primaryColor),
                    SizedBox(width: 8),
                    _buildCategoryChip('Standard', isDark, primaryColor),
                    SizedBox(width: 8),
                    _buildCategoryChip('Premium', isDark, primaryColor),
                    SizedBox(width: 8),
                    _buildCategoryChip('VIP', isDark, primaryColor),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
              
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.green, 'Available', isDark),
                    const SizedBox(width: 24),
                    _buildLegendItem(Colors.red, 'Reserved', isDark),
                  ],
                ),
              ).animate().fadeIn(duration: 1000.ms),
              
              // PC Grid
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
                                  Icons.error_outline,
                                  color: Colors.red[300],
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error loading PCs',
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
                                  onPressed: _fetchPcs,
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
                        : getFilteredPcs().isEmpty
                            ? Center(
                                child: Text(
                                  'No PCs available in this category',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: getFilteredPcs().length,
                                  itemBuilder: (context, index) {
                                    final pc = getFilteredPcs()[index];
                                    final pcId = pc['id_pc'] as int;
                                    final pcName = pc['pc_name'] as String;
                                    final isAvailable = pc['is_available'] as bool;
                                    final specs = pc['specs'] as String;
                                    final category = pc['category'] as String;
                                    
                                    return _buildPcCard(
                                      context, 
                                      pcId, 
                                      pcName, 
                                      isAvailable, 
                                      specs, 
                                      category,
                                      index,
                                      isDark,
                                      primaryColor,
                                      accentColor
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isDark, Color primaryColor) {
    final isSelected = selectedCategory == category;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor 
              : (isDark ? Color(0xFF262A43) : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: isSelected 
                ? Colors.white 
                : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPcCard(
    BuildContext context, 
    int pcId, 
    String pcName, 
    bool isAvailable, 
    String specs, 
    String category,
    int index,
    bool isDark,
    Color primaryColor,
    Color accentColor
  ) {
    return GestureDetector(
      onTap: isAvailable
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DateSelectionPage(
                    warnetName: widget.warnetName,
                    pcNumber: index + 1,
                    warnetId: widget.warnetId,
                    pcId: pcId,
                    pcName: pcName,
                    pcSpecs: specs,
                  ),
                ),
              );
            }
          : null,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicator
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAvailable 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: isAvailable ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.computer_rounded,
                  color: isAvailable ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              pcName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              isAvailable ? "Available" : "Reserved",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: isAvailable 
                    ? Colors.green 
                    : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms, delay: (index * 50).ms).scale(delay: (index * 50).ms),
    );
  }
}