import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // Garis ke bawah
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 50); // Gelombang
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 100, size.width, size.height - 50); // Gelombang
    path.lineTo(size.width, 0); // Garis ke atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}