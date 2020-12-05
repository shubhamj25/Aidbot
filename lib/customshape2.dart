import 'package:flutter/material.dart';

class CustomShape2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path=Path();
    path.lineTo(0.0,size.height );

    var firstendpt=Offset(size.width *0.5,size.height - 30.0);
    var firstcontrolpt=Offset(size.width *0.25,size.height -50.0);
    path.quadraticBezierTo(firstcontrolpt.dx, firstcontrolpt.dy, firstendpt.dx, firstendpt.dy);

    var secondendpt=Offset(size.width,size.height - 80.0);
    var secondcontrolpt=Offset(size.width *0.75,size.height);
    path.quadraticBezierTo(secondcontrolpt.dx, secondcontrolpt.dy, secondendpt.dx, secondendpt.dy);

    path.lineTo(size.width,0.0);
    path.close();
    return path;

  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}