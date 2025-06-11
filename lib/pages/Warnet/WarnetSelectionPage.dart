import 'package:fikzuas/booking_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/pages/Warnet/PcListPage.dart';
import 'package:fikzuas/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class WarnetSelectionPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchWarnetData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/warnets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => {
        "id": item['id_warnet'], // Tambahkan id_warnet
        "name": item['warnet_name'],
        "address": item['address'],
        "availablePcs": item['total_pcs'],
        "rating": item['stars'] != null ? double.parse(item['stars']) : 0.0,
        "image": "assets/img/net${(data.indexOf(item) % 3) + 1}.png",
      }).toList();
    } else {
      print(response);
      throw Exception('Gagal memuat data warnet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Warnet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : theme.colorScheme.primary,
              ),
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.white70 : theme.colorScheme.primary,
              ),
              onPressed: () {
                // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF2C2F50) : Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background dengan WaveClipper
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Color(0xFF2C2F50), Color(0xFF1A1D40).withOpacity(0.9)]
                          : [Color(0xFF3A3D60), Color(0xFF2C2F50).withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Konten utama
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  // Search Bar
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Color(0xFF2C2F50).withOpacity(0.3)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: isDark ? Colors.white70 : Colors.black54),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search warnet...',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.tune,
                            color: isDark ? Colors.white70 : Colors.black54),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // FutureBuilder untuk daftar warnet
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchWarnetData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No warnet available'));
                        } else {
                          final warnetList = snapshot.data!;
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 16.0),
                            itemCount: warnetList.length,
                            itemBuilder: (context, index) {
                              final warnet = warnetList[index];
                              return _buildWarnetCard(context, warnet, theme, isDark);
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarnetCard(BuildContext context, Map<String, dynamic> warnet,
      ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => BookingState()
                ..initializePcSlots(warnet["name"], warnet["availablePcs"]),
              child: PcListPage(
                warnetName: warnet["name"],
                warnetId: warnet["id"], // Kirim id_warnet
              ),
            ),
          ),
        );
      },
      child: Card(
        elevation: theme.cardTheme.elevation ?? 5,
        shape: theme.cardTheme.shape,
        margin: EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Warnet
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.asset(
                  warnet["image"],
                  height: 150.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150.0,
                      color: Colors.grey,
                      child: Center(child: Text('Image not found')),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          warnet["name"],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${warnet["rating"]}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            Icon(
                              Icons.star,
                              size: 16.0,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      warnet["address"],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Available PCs: ${warnet["availablePcs"]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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