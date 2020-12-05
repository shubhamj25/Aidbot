import 'package:flutter/material.dart';

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path=Path();
    path.moveTo(0.0,size.height);
    path.lineTo(0.0, size.height*0.35);

    num degTorad(num deg) => deg * (3.14/180);
var point1=Offset(0,size.height*0.35);
var point2=Offset(0.2*size.width,size.height*0.3);
    path.arcTo(Rect.fromPoints(point1,point2), degTorad(180), degTorad(90),false);

    path.lineTo(size.width*0.8, size.height*0.3);

    var point11=Offset(size.width*0.8,size.height*0.3);
    var point22=Offset(size.width,size.height*0.35);
    path.arcTo(Rect.fromPoints(point11,point22), degTorad(270), degTorad(90),false);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
