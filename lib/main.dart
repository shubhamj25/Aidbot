import 'dart:io';
import 'package:auto_food/loadpage.dart';
import 'package:auto_food/restaurant.dart';
import 'package:auto_food/restaurantportal.dart';
import 'package:auto_food/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:progress_indicators/progress_indicators.dart';

Future<void> main() async{
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  WidgetsFlutterBinding.ensureInitialized();
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.wifi||connectivityResult == ConnectivityResult.mobile) {

    final FirebaseApp app = await FirebaseApp.configure(
        name:'autofood-firestore',
        options: Platform.isIOS
            ? const FirebaseOptions(
            googleAppID: "1:989070411476:ios:7cb60d8304fe68a1ac9d41",
            gcmSenderID: "989070411476",
            databaseURL: "https://twigger-93153.firebaseio.com/"

        )
            :const FirebaseOptions(
            googleAppID: '1:989070411476:android:ef50d196b519da98ac9d41',
            apiKey: "AIzaSyA1_qOHzJyn9xklzQ4AlCXIge4G-xB_59A",
            databaseURL: "https://twigger-93153.firebaseio.com/"
        ));
    runApp(
        MaterialApp(
          title: "AutoFood",
          debugShowCheckedModeBanner: false,
          routes: <String, WidgetBuilder> {
            '/main': (BuildContext context) => new LoadScreen(),
            '/loadpage': (BuildContext context) => new Homepage(),
            '/restaurant_signin': (BuildContext context) => new ResLoadScreen(),
            '/ResScreen':(BuildContext context) => new ResScreen(),
          },
          home: SingleChildScrollView(child: LoadScreen()),
          theme: ThemeData(
            fontFamily: 'Raleway',
            primaryColor: Colors.pink,
            accentColor: Colors.deepPurple,
          ),
        )
    );
    Firestore.instance.collection('cartItems').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});
  } else {
    runApp(
        MaterialApp(
          title: "AutoFood",
          debugShowCheckedModeBanner: false,
          home: SingleChildScrollView(child: Load()),
          theme: ThemeData(
            fontFamily: 'Raleway',
            primaryColor: Colors.pink,
            accentColor: Colors.deepPurple,
          ),
        )
    );
  }
}



class LoadScreen extends StatefulWidget {
  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailFieldController=TextEditingController();
  final searchFieldController=TextEditingController();
  final _pinEditingController=TextEditingController();
  final phoneFieldController=TextEditingController();
  showAlertDialog(BuildContext context){
    Dialog alert=Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:80.0,horizontal: 30.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                      child: FadingText("Verifying..",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),)
                  ),
                ],
              ),
            ),

          ],),
      ),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
  bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  var status="You are not Signed In";
  bool signupvalidation=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
  bool signingin=false;
  bool signinerror=false;
  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  Future<bool> loginUser(String phone,BuildContext context) async{
    FirebaseAuth _auth=FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();
          AuthResult result= await _auth.signInWithCredential(credential).catchError((err){
           print("error");
          }
          );
          FirebaseUser user=result.user;
          if(user!=null){
            formData['email']=user.phoneNumber;
            Navigator.of(context).pushNamedAndRemoveUntil('/loadpage', (Route<dynamic> route) => false);
          }
          else{
            print('error');
          }
        },
        verificationFailed: (AuthException exception){
          print('ererer');
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context){
              return StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.sms,size:20.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Enter OTP",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700),),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.close,size: 20.0,),
                              onPressed: (){
                                requestingotp=false;
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          PinInputTextField(
                            controller: _pinEditingController,
                            textInputAction: TextInputAction.go,
                            autoFocus: true,
                            pinLength: 6,     // The length of the pin
                            decoration: UnderlineDecoration(),
                            // or BoxLooseDecoration, UnderlineDecoration
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 8.0),
                          child: Material(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  signingin ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CollectionScaleTransition(
                                      children: <Widget>[
                                        Icon(Icons.fiber_manual_record,color: Colors.blue,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color:Colors.red,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color: Colors.yellow,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color: Colors.green,size: 20.0,),
                                      ],
                                    )
                                  ):Container(),
                                 Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Sign In",style: GoogleFonts.happyMonkey(color: Colors.blue,fontSize: MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600),),
                                  ),
                                ],
                              ),
                              onPressed: ()async{
                                  final code=_pinEditingController.text;
                                  AuthCredential credential=PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);
                                  //showAlertDialog(context);
                                  setState(() {
                                    signingin=true;
                                  });
                                  AuthResult result=await _auth.signInWithCredential(credential).catchError((err){
                                   Navigator.pop(context);
                                  }
                                  );
                                  FirebaseUser user=result.user;
                                  if(user!=null){
                                    formData['email']=user.phoneNumber;
                                    Navigator.of(context).pushNamedAndRemoveUntil('/loadpage', (Route<dynamic> route) => false);
                                  }else{
                                      print("error");
                                  }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              );
           }
          );
        },
        codeAutoRetrievalTimeout: null);
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        body: Material(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration:BoxDecoration(
                image: DecorationImage(
                  image:AssetImage("images/watch-tower.png"),
                  fit: BoxFit.cover,
                ),
              ),

              child:ListView(
                shrinkWrap: true,
                children: <Widget>[
                  if(!onsignupclick)Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left:20.0,top:25.0,right:20.0,bottom: 4.0),
                      child: Material(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: GroovinExpansionTile(
                          boxDecoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                          title: Text("Welcome to AIDbot !",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize: MediaQuery.of(context).size.width*0.045 ,fontWeight: FontWeight.w700),),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
                              child: Text("AIDbot is an online Application for controlling and placing orders via an Autonomous Indoor Delivery Vehicle",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600),textAlign: TextAlign.left,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                elevation: 10.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                  child: Text("Please Login/SignUp in order to procede !",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600)),
                                ),
                              ),
                            )
                          ],
                          trailing: Icon(Icons.wb_incandescent,size: 20.0,color: Colors.white,),
                        ),
                      ),
                    ),
                  ),


                  Center(
                    child: Padding(
                      padding: !onsignupclick ?const EdgeInsets.only(left:20.0,right:20.0):const EdgeInsets.only(left:20.0,right:20.0,top:20.0),
                      child: Material(
                        elevation: 20.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(topLeft:Radius.circular(5.0),topRight:Radius.circular(5.0)),
                        ),
                        child: GroovinExpansionTile(
                          boxDecoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                          title: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.account_circle,size:20.0,color:Colors.black87),
                              ),
                              Text("Seller Sign In!",style: GoogleFonts.happyMonkey(color: Colors.black87,fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w700),),
                            ],
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
                              child: Text("Make sure your Store is registered on the App !",style: GoogleFonts.happyMonkey(color:Colors.black87,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Card(
                                  color: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  elevation: 10.0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
                                    child: Text("Procede to Login",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              onTap: (){
                                Navigator.of(context).pushNamed('/restaurant_signin');
                              },
                            )
                          ],
                          trailing: Icon(Icons.store,size: 20.0,color: Colors.black,),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:16.0),
                    child: Card(
                      color: Color.fromARGB(255,254,253,248),
                      elevation: 12.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomRight:Radius.circular(12.0),bottomLeft: Radius.circular(12)),
                      ),
                      child: Column(
                        children: <Widget>[
                          if(loading)LinearProgressIndicator(),
                          ListTile(
                            leading:(status=="Number Verified :)"||status=="Successfully Loggedin")?Icon(Icons.check_circle,color: Colors.green,):(status=="Invalid Credentials"|| status=="Unregistered Number")?Icon(Icons.error,color: Colors.red):Icon(Icons.notifications,color: Colors.blueAccent),
                              title: Text('$status',  style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600,)),
                              subtitle: Text("Active Status",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.042)),
                          ),
                          Form(
                            key:_formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                onsignupclick ?Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.account_circle,size: 25.0,),
                                          ),
                                          Text("Sign Up",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700,color: Colors.blue),),

                                        ],
                                      ),
                                    ),
                                    if (onsignupclick) Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: IconButton(
                                        icon: Icon(Icons.arrow_back,size: 25.0,),
                                          onPressed: (){
                                            setState(() {
                                              onsignupclick=false;
                                              onsubmit=false;
                                              loading=false;
                                            });
                                          },
                                      ),
                                    )
                                  ],
                                ):Padding(
                                  padding: const EdgeInsets.only(top:20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      !phonesignup?
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:8.0),
                                          child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.account_box,color: Colors.blueAccent,size:30.0),
                                            ),
                                            Text("Login",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700,color: Colors.blue),),
                                          ],
                                      ),
                                        ):
                              Row(
                                  children: <Widget>[
                                  Row(
                                  children: <Widget>[
                                  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.phone_android),
                                   ),
                                  Text("Sign In with Phone",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700,color: Colors.blue),),
                                      ],
                                       ),

                                  if (phonesignup) Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back,size: 25.0,),
                                      onPressed: (){
                                        setState(() {
                                          phonesignup=false;
                                          phoneregistered=true;
                                          status="You are not Signed In";
                                          requestingotp=false;
                                          loading=false;
                                        });
                                      },
                                    ),
                                  ),
                                  ],
                              ),
                                      if(!phonesignup)MaterialButton(
                                        elevation:10.0,
                                        color:Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                        ),
                                       child: Row(
                                         children: <Widget>[
                                           Icon(Icons.phone,color: Colors.white,size: 20,),
                                           Text(" Sign In",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.042,fontWeight: FontWeight.w600,color: Colors.white)),
                                         ],
                                       ),
                                        onPressed: (){
                                          setState(() {
                                            phonesignup=true;
                                          });
                                        },
                                      ),

                                    ],
                                  ),
                                ),

                                if(onsignupclick)
                                  AnimatedOpacity(
                                    opacity: signupfieldopac,
                                    duration: Duration(seconds: 1),
                                    child: Padding(
                                    padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      child: TextFormField(
                                        style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                        onSaved: (var value){
                                          signupData['name']=value;
                                        },
                                        validator: (val){
                                          if(val==""||val==null){
                                            return "Empty Field";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                          labelText: "Your Fullname",
                                          errorStyle: GoogleFonts.balooBhai(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                          suffixIcon: Icon(Icons.person,color: Colors.black,),
                                          border: InputBorder.none,
                                        ),

                                      ),
                                    ),
                                ),
                                  ),

                                if(!phonesignup)Padding(
                                  padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                      controller: emailFieldController,
                                      onSaved: (var value){
                                        formData['email']=value.trim();
                                        signupData['email']=value.trim();
                                      },
                                        validator:(String value){
                                          Pattern pattern =
                                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                          RegExp regex = new RegExp(pattern);
                                          if (!regex.hasMatch(value)) {
                                            signupvalidation=false;
                                            return "Invalid Email Address";
                                          }
                                          else{
                                            signupvalidation=true;
                                          }
                                          return null;
                                        },
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        errorStyle: GoogleFonts.balooBhai(),
                                        suffixIcon: !signinerror ?Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.email,color: Colors.black,),
                                        ):Icon(Icons.error,color: Colors.red,),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (String val){
                                        setState(() {
                                          signinerror=false;
                                        });
                                      },
                                    ),
                                  ),
                                ),


                                if(phonesignup)
                                  Padding(
                                  padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                      controller: phoneFieldController,
                                      keyboardType: TextInputType.phone,
                                      onSaved: (var value){
                                        formData['phone']="+91"+value;
                                      },
                                      validator:(String value){
                                        if (value.trim().length!=10) {
                                          signupvalidation=false;
                                          return "10 digits required";
                                        }
                                        else{
                                          signupvalidation=true;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                        labelText: "Phone",
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        errorStyle: GoogleFonts.balooBhai(),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: phoneregistered ? Icon(Icons.phone,color: Colors.black,): Icon(Icons.error,color: Colors.red,),
                                        ),
                                        border: InputBorder.none,
                                      ),


                                    ),
                                  ),
                                ),

                                if(!phonesignup)Padding(
                                  padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(color:Colors.black,fontSize: MediaQuery.of(context).size.width*0.038,fontWeight: FontWeight.w700),
                                      onSaved: (var value){
                                        formData['password']=value;
                                        signupData['password']=value;
                                      },
                                      onChanged: (String val){
                                        setState(() {
                                          signinerror=false;
                                        });
                                      },
                                      validator: (val){
                                        if(val==""||val==null){
                                          return "Empty Password";
                                        }
                                        else{
                                          return null;
                                        }
                                      },
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                        labelText: "Password",
                                        errorStyle: GoogleFonts.balooBhai(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical:5.0),
                                        suffixIcon: !signinerror?
                                        IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 25.0,):
                                        Icon(Icons.lock_open,color: Colors.black,size: 25.0,),
                                          onPressed: _toggle,):
                                        Icon(Icons.error,color: Colors.red,),
                                        border: InputBorder.none,
                                      ),

                                    ),
                                  ),
                                ),

                                if(onsignupclick)
                                  Padding(
                                  padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                      onSaved: (var value){
                                        signupData['phone']=value;
                                      },
                                      validator:(String value){
                                        if (value.trim().length!=10) {
                                          signupvalidation=false;
                                          return "10 digits required";
                                        }
                                        else{
                                          signupvalidation=true;
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: "Phone Number",
                                        errorStyle: GoogleFonts.balooBhai(),
                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.phone,color: Colors.black,),
                                        ),
                                        border: InputBorder.none,
                                      ),


                                    ),
                                  ),
                                ),

                                if(onsignupclick)
                                  AnimatedOpacity(
                                    opacity: signupfieldopac,
                                    duration: Duration(seconds: 1),
                                    child: Padding(
                                    padding: const EdgeInsets.only(left:20,right:20,top:9.0,bottom:5.0),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      child: TextFormField(
                                        maxLines: 3,
                                        style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.038,color:Colors.black,fontWeight: FontWeight.w700),
                                        onSaved: (var value){
                                          signupData['address']=value;
                                        },
                                        validator: (val){
                                          if(val==""||val==null){
                                            return "Empty Field";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.04),
                                          labelText: "Room Details",
                                          errorStyle: GoogleFonts.balooBhai(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                          suffixIcon: Icon(Icons.home,size:25.0,color: Colors.black,),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                   ),
                                  ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      if(onsubmit==false && !phonesignup)
                                        Padding(
                                        padding: const EdgeInsets.only(left:20.0,right:10.0,),
                                        child: MaterialButton(
                                          elevation: 10.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.assignment_ind,color: Colors.red,),
                                              Text("Login",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.red)),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                                _formKey.currentState.save();
                                                if(formData['email']==""||formData['password']==""){
                                                  setState(() {
                                                    signinerror=true;
                                                  });
                                                }else{
                                                  loading=true;
                                                  Firestore.instance.collection('users').document(formData['email']).get().then((snapshot) {
                                                    if(snapshot.exists && formData['email']==snapshot.data['email'] && formData['password']==snapshot.data['password']){
                                                      setState(() {
                                                        status="Successfully Loggedin";
                                                        Navigator.pushReplacement(context, MaterialPageRoute(
                                                            builder: (context)=>Homepage()
                                                        ));
                                                      });
                                                    }
                                                    else{
                                                      setState(() {
                                                        status="Invalid Credentials";
                                                        signinerror=false;
                                                        loading=false;
                                                      });
                                                    }
                                                  });
                                                }
                                            });
                                          },
                                        ),
                                      ),

                                      if(onsubmit==true && !phonesignup)
                                        Padding(
                                          padding: const EdgeInsets.only(left:10.0,right:10.0,),
                                          child: MaterialButton(
                                            elevation: 10.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.person_add,color: Colors.lightGreen,),
                                                Text("Submit",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.lightGreen)),
                                              ],
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                _formKey.currentState.validate();
                                                if (signupvalidation) {
                                                  _formKey.currentState.save();
                                                  loading=true;
                                                  print(signupData);
                                                  Firestore.instance.collection('users').document(signupData['email']).setData({
                                                    'name':signupData['name'],
                                                    'email':signupData['email'],
                                                    'password':signupData['password'],
                                                    'address':signupData['address'],
                                                    'phone':signupData['phone']
                                                  });
                                                  Firestore.instance.collection('regphones').document("${signupData['phone']}").setData({
                                                    'phone_number': signupData['phone'],
                                                  });
                                                  signupfieldopac=0.0;
                                                  onsignupclick=false;
                                                  onsubmit=false;
                                                  status="Signed Up Successfully";
                                                  loading=false;
                                                }
                                                else {
                                                  setState(() {
                                                    loading=true;
                                                  });
                                                }

                                              });
                                            },
                                          ),
                                        ),

                                      if(onsignupclick && !phonesignup)
                                        Padding(
                                          padding: const EdgeInsets.only(left:10.0,right:10.0,),
                                          child: MaterialButton(
                                            elevation: 10.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.home,color: Colors.blueGrey,),
                                                Text("Return",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.blueGrey)),
                                              ],
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                onsignupclick=false;
                                                onsubmit=false;
                                                loading=false;
                                              });
                                            },
                                          ),
                                        ),

                                      if(phonesignup)Padding(
                                        padding: const EdgeInsets.only(left:10.0,right:10.0,),
                                        child: MaterialButton(
                                          elevation: 10.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: !requestingotp ?Row(
                                            children: <Widget>[
                                              Icon(Icons.message,color: Colors.red,),
                                              Text("Request OTP",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.red)),
                                            ],
                                          ):Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: CollectionScaleTransition(
                                                children: <Widget>[
                                                  Icon(Icons.fiber_manual_record,color: Colors.blue,size: 20.0,),
                                                  Icon(Icons.fiber_manual_record,color:Colors.red,size: 20.0,),
                                                  Icon(Icons.fiber_manual_record,color: Colors.yellow,size: 20.0,),
                                                  Icon(Icons.fiber_manual_record,color: Colors.green,size: 20.0,),
                                                ],
                                              ),
                                              ),
                                          onPressed: (){
                                            setState(() {
                                              _formKey.currentState.save();
                                              loading=true;
                                              requestingotp=true;
                                              Firestore.instance.collection('regphones').document('${formData['phone']}').get().then((doc){
                                                if(doc.exists){
                                                  setState(() {
                                                    phoneregistered=true;
                                                    status="Number Verified :)";
                                                  });
                                                  final phone="+91"+phoneFieldController.text.trim();
                                                  loginUser(phone,context);
                                                }
                                                else if(!doc.exists){
                                                  setState(() {
                                                    phoneregistered=false;
                                                    status="Unregistered Number";
                                                    requestingotp=false;
                                                  });
                                                }
                                                else{
                                                  setState(() {
                                                    phoneregistered=false;
                                                    status="Network Issues";
                                                    requestingotp=false;
                                                  });
                                                }
                                              });
                                            });
                                          },
                                        ),
                                      ),


                                      if(onsubmit==false && !phonesignup)
                                        Padding(
                                          padding: const EdgeInsets.only(left:10.0,right:20.0),
                                          child: MaterialButton(
                                            elevation: 10.0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Icon(Icons.person,color: Colors.blueAccent,),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                                  child: Text("Signup",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.blueAccent)),
                                                ),
                                              ],
                                            ),
                                            onPressed: (){
                                              setState(() {
                                                signupfieldopac=1.0;
                                                onsignupclick=true;
                                                onsubmit=true;
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                   ListView(
                     shrinkWrap: true,
                    children: <Widget>[
                      if(!onsignupclick) Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10,),
                          Container(
                            width:80,
                            height:80,
                            child: CachedNetworkImage(
                              imageUrl: "https://firebasestorage.googleapis.com/v0/b/twigger-93153.appspot.com/o/wallpapers%2Fic_launcher.png?alt=media&token=c661070d-9bb9-4f09-860b-c029827a7718",
                              fadeInCurve: Curves.easeIn,
                              fadeInDuration: Duration(seconds: 1),
                            ),
                          ),
                          Text("AIDbot",style: GoogleFonts.happyMonkey(color: Colors.white,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.07),),
                          SizedBox(height: 20,),
                        ],
                      )),
                    ],
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
}


class Load extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              CircularProgressIndicator(backgroundColor: Colors.white,),
            ],
          )
        ],
      ),
    );
  }
}
