import 'package:auto_food/customshape.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendFile extends StatefulWidget {
  @override
  _SendFileState createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                 TopBar(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top:40.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left:20.0),
                              child: FloatingActionButton(
                                heroTag: 1,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.home,color: Colors.black87,),
                                onPressed: (){
                                 Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right:32.0,top:32),
                            child: Container(
                              width:80,
                              height:80,
                              child: CachedNetworkImage(
                                imageUrl: "https://firebasestorage.googleapis.com/v0/b/twigger-93153.appspot.com/o/wallpapers%2Fic_launcher.png?alt=media&token=c661070d-9bb9-4f09-860b-c029827a7718",
                                fadeInCurve: Curves.easeIn,
                                fadeInDuration: Duration(seconds: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.only(left:30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("AIDbot",style: GoogleFonts.happyMonkey(fontSize: 32,fontWeight: FontWeight.bold),),
                            Text("File Transfer",style: GoogleFonts.happyMonkey(fontSize: 18),),

                          ],
                        ),
                      ),

                    ],
                  ),
                ],
              ),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 0),
          child: ListTile(
            title: Text("Paperback File Transfer",style: GoogleFonts.happyMonkey(fontSize: 18),),
            subtitle: Text("Send Paperback version of a file to your colleague",style: GoogleFonts.happyMonkey(fontSize: 15),),
            onTap: (){
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  backgroundColor: Colors.deepOrange,
                  content: ListTile(
                    leading: Icon(Icons.sentiment_very_satisfied,color:Colors.white,size:30),
                      title: Text("Feature Coming Soon !",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize:16 ),)),
                ));
            },
          ),
        ),
            ],
          ),
        ),
      ),
    );
  }
}
