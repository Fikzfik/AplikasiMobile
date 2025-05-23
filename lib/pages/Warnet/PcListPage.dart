import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/Warnet/WarnetSelectionPage.dart';
import 'package:fikzuas/pages/Warnet/DateSelectionPage.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PcListPage extends StatefulWidget {
  final String warnetName;

  const PcListPage({Key? key, required this.warnetName, required warnetId}) : super(key: key);

  @override
  _PcListPageState createState() => _PcListPageState();
}

class _PcListPageState extends State<PcListPage>
    with SingleTickerProviderStateMixin {
  int? selectedPcIndex; // Menyimpan indeks PC yang dipilih
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final pcSlots =
        Provider.of<BookingState>(context).warnetPcSlots[widget.warnetName]!;

    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang dengan efek wave clipper
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
                          ? [
                              Color(0xFF2C2F50),
                              Color(0xFF1A1D40).withOpacity(0.9),
                            ]
                          : [
                              Color(0xFF3A3D60),
                              Color(0xFF2C2F50).withOpacity(0.85),
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Consumer<BookingState>(
                builder: (context, bookingState, child) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // AppBar Custom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white70,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                '${widget.warnetName}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.grey.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Header Elegan
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Choose Your PC',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Legenda
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(Colors.white, 'Available'),
                              const SizedBox(width: 16),
                              _buildLegendItem(Colors.red[300]!, 'Reserved'),
                              const SizedBox(width: 16),
                              _buildLegendItem(Colors.amberAccent, 'Selected'),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Grid PC dengan Efek Hover
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: pcSlots.length,
                          itemBuilder: (context, index) {
                            final pcNumber = index + 1;
                            final isAvailable = pcSlots[index];
                            final isSelected = selectedPcIndex == index;

                            return GestureDetector(
                              onTap: isAvailable
                                  ? () {
                                      setState(() {
                                        selectedPcIndex =
                                            isSelected ? null : index;
                                      });
                                    }
                                  : null,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isSelected
                                        ? [Colors.amberAccent, Colors.amber]
                                        : (isAvailable
                                            ? [Colors.white, Colors.grey[200]!]
                                            : [
                                                Colors.red[300]!,
                                                Colors.red[400]!
                                              ]),
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.amberAccent
                                              .withOpacity(0.7),
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? Colors.amber.withOpacity(0.5)
                                          : (isAvailable
                                              ? Colors.grey.withOpacity(0.3)
                                              : Colors.red.withOpacity(0.3)),
                                      blurRadius: isSelected ? 12 : 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.computer,
                                      color: isSelected
                                          ? Colors.black87
                                          : (isAvailable
                                              ? Colors.black54
                                              : Colors.white),
                                      size: 28,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'PC $pcNumber',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.black87
                                            : (isAvailable
                                                ? Colors.black54
                                                : Colors.white),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms + (index * 40).ms)
                                  .scale(),
                            );
                          },
                        ),
                        SizedBox(height: 24),
                        // Tombol dengan Efek Gradasi Bergerak
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              child: ElevatedButton(
                                onPressed: selectedPcIndex != null
                                    ? () {
                                        final pcNumber = selectedPcIndex! + 1;
                                        bookingState.bookSlot(
                                            widget.warnetName, pcNumber);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'PC $pcNumber reserved! Select a date.',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins'),
                                            ),
                                            backgroundColor: Colors.green[700],
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        // Navigasi ke halaman pemilihan tanggal
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DateSelectionPage(
                                              warnetName: widget.warnetName,
                                              pcNumber: pcNumber,
                                              pcId: null,
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          selectedPcIndex =
                                              null; // Reset setelah booking
                                        });
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: selectedPcIndex != null
                                          ? [
                                              Colors.purpleAccent,
                                              Colors.blueAccent
                                            ]
                                          : [
                                              Colors.grey[600]!,
                                              Colors.grey[700]!
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedPcIndex != null
                                            ? Colors.purpleAccent
                                                .withOpacity(0.4)
                                            : Colors.grey.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 12),
                                    child: Center(
                                      child: Text(
                                        'Reserve PC',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 600.ms).scale(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk legenda
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white70,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Clipper untuk efek wave (diambil dari DashboardPage)
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
