import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = GoogleFonts.happyMonkey(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String _versionName = 'V1.0';
  final splashDelay = 5;

  @override
  void initState() {
    super.initState();

    _loadWidget();
  }

  _loadWidget() async {
    var _duration = Duration(seconds: splashDelay);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SingleChildScrollView(child: LoadScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(height: 10,),
                                  Container(
                                    width:180,
                                    height:180,
                                    child: CachedNetworkImage(
                                      imageUrl: "https://firebasestorage.googleapis.com/v0/b/twigger-93153.appspot.com/o/wallpapers%2Fic_launcher.png?alt=media&token=c661070d-9bb9-4f09-860b-c029827a7718",
                                      fadeInCurve: Curves.easeIn,
                                      fadeInDuration: Duration(seconds: 1),
                                    ),
                                  ),
                                  SizedBox(height: 50,),
                                  Text("AIDbot",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.07),),
                                  SizedBox(height: 20,),
                                ],
                              )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Container(
                        height: 10,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Spacer(),
                            Text(_versionName),
                            Spacer(
                              flex: 4,
                            ),
                            Text('Loading..'),
                            Spacer(),
                          ])
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}