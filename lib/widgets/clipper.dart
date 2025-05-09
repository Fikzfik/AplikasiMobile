import 'package:flutter/material.dart';

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.7);
    path.lineTo(size.width, size.height * 0.6);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
class InverseDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height); // Mulai dari kiri bawah
    path.lineTo(0, size.height * 0.3); // Garis ke atas
    path.lineTo(size.width, size.height * 0.4); // Garis miring ke kanan bawah
    path.lineTo(size.width, size.height); // Garis lurus ke kanan bawah
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}


class TopDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0); // Garis lurus ke kanan atas
    path.lineTo(size.width, size.height - 60); // Garis miring ke bawah kiri
    path.lineTo(0, size.height); // Garis lurus ke kiri bawah
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

// Clipper untuk Container Bawah (terpotong di atas seperti jajar genjang)
class BottomDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 60); // Potongan mulai dari kiri atas turun sedikit
    path.lineTo(size.width, 0); // Sambungkan ke kanan atas
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
