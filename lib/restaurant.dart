import 'package:auto_food/restaurantportal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:auto_food/main.dart';

class ResLoadScreen extends StatefulWidget {
  @override
  _ResLoadScreenState createState() => _ResLoadScreenState();
}

class _ResLoadScreenState extends State<ResLoadScreen> {
  final _formKey2 = GlobalKey<FormState>();
  final searchFieldController=TextEditingController();
  final emailFieldController=TextEditingController();

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
                      child: FadingText("Verifying..",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0452,fontWeight: FontWeight.w700),)
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
bool  signinerror=false;
bool signingin=false;
  bool _obscureText = true;
  bool onsignupclick=false;
  bool onsubmit=false;
  double signupfieldopac=0.0;
  String status="You are not Signed In";
  bool signupvalidation=false;
  bool loading=false;
  bool phonesignup=false;
  bool requestingotp=false;
  bool phoneregistered=true;
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
            resformData['email']=user.phoneNumber;
            Navigator.of(context).pushNamedAndRemoveUntil('/ResScreen', (Route<dynamic> route) => false);
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
                          borderRadius: BorderRadius.all(Radius.circular(12.0))),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.sms,size:MediaQuery.of(context).size.width*0.07),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Enter OTP",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0455,fontWeight: FontWeight.w700),),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.close,size: MediaQuery.of(context).size.width*0.07,),
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
                                        Icon(Icons.fiber_manual_record,color: Colors.white,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color:Colors.red,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color: Colors.yellow,size: 20.0,),
                                        Icon(Icons.fiber_manual_record,color: Colors.green,size: 20.0,),
                                      ],
                                    )
                                ):Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Sign In",style: GoogleFonts.happyMonkey(color: Colors.white,fontSize:MediaQuery.of(context).size.width*0.0455,fontWeight: FontWeight.w600),),
                                  ),
                                ],
                              ),
                              color: Colors.blue,
                              onPressed: ()async{
                                  final code=_pinEditingController.text;
                                  AuthCredential credential=PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);
                                  setState(() {
                                    signingin=true;
                                  });
                                  AuthResult result=await _auth.signInWithCredential(credential).catchError((err){
                                   Navigator.pop(context);
                                  }
                                  );
                                  FirebaseUser user=result.user;
                                  if(user!=null){
                                    resformData['email']=user.phoneNumber;
                                    Navigator.of(context).pushNamedAndRemoveUntil('/ResScreen', (Route<dynamic> route) => false);
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
                  image: AssetImage("images/wp.png"),
                  fit: BoxFit.cover,
                ),
              ),

              child:ListView(
                shrinkWrap: true,
                children: <Widget>[

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:8.0,vertical:8.0),
                        child: IconButton(
                          icon:Icon(Icons.arrow_back,color: Colors.white,size: MediaQuery.of(context).size.width*0.07),
                          onPressed: (){
                            Navigator.popAndPushNamed(context,'/main');
                          },
                        ),
                      ),
                    ],
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left:20.0,right:20.0),
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
                                child: Icon(Icons.account_circle,size: 30.0,color:Colors.black87),
                              ),
                              Text("Seller Sign In!",style: GoogleFonts.happyMonkey(color: Colors.black87,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w700),),
                            ],
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 8.0),
                              child: Text("Make sure your store is registered on the App !",style: GoogleFonts.happyMonkey(color:Colors.black87,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Card(
                                color: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                ),
                                elevation: 10.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: <Widget>[
                                      Text("Happy Delivery",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.tag_faces,color:Colors.white,size:25.0),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                          trailing: Icon(Icons.store,size: 25.0,color: Colors.black,),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom:10,right:16.0,left:16),
                    child: Card(
                      color: Color.fromARGB(255,254,253,248),
                      elevation: 12.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomLeft:Radius.circular(12.0),bottomRight:Radius.circular(12.0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          if(loading)LinearProgressIndicator(),
                          ListTile(
                            leading:status=="Number Verified :)"||status=="Successfully Loggedin"?Icon(Icons.check_circle,color: Colors.green,):(status=="Registration Incomplete"||status=="Invalid Credentials"|| status=="Unregistered Number")?Icon(Icons.error,color: Colors.red):Icon(Icons.notifications,color: Colors.blueAccent),
                            title: Text('$status',  style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600,)),
                            subtitle: Text("Active Status",style: GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.042)),
                          ),
                          Form(
                            key:_formKey2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                onsignupclick ?Padding(
                                  padding: const EdgeInsets.only(top:20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal:16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.account_circle,size: 30.0,),
                                            ),
                                            Text("Sign Up",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700,color: Colors.blue),),

                                          ],
                                        ),
                                      ),
                                      if (onsignupclick) Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: IconButton(
                                          icon: Icon(Icons.arrow_back,),
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
                                  ),
                                ):Padding(
                                  padding: const EdgeInsets.only(top:20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      !phonesignup?
                                        Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.account_box,color:Colors.blueAccent,size:30.0),
                                          ),
                                          Text("Login",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w700,color: Colors.blue),),
                                        ],
                                      ):
                              Row(
                                children: <Widget>[

                                  Row(
                                  children: <Widget>[
                                  Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.phone_android),
                                   ),
                                  Text("Sign In with Phone",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0455,fontWeight: FontWeight.w700,color: Colors.blue),),
                                      ],
                                       ),

                                  if (phonesignup) Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back,size: 30.0,),
                                      onPressed: (){
                                        setState(() {
                                          phonesignup=false;
                                          phoneregistered=true;
                                          status="You are not Signed In";
                                          requestingotp=false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                                      if(!phonesignup)MaterialButton(
                                        color:Colors.green,
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.phone,size:20,color: Colors.white,),
                                            Text(" Sign In",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600,color: Colors.white)),
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
                                    padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      child: TextFormField(
                                        style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                        onSaved: (var value){
                                          ressignupData['name']=value;
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
                                          labelText: "Store Name",
                                          errorStyle: GoogleFonts.balooBhai(),

                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                          suffixIcon: Icon(Icons.store,color: Colors.black,),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                ),
                                  ),

                                if(!phonesignup)Padding(
                                  padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                      controller: emailFieldController,
                                      onSaved: (var value){
                                        resformData['email']=value.trim();
                                        ressignupData['email']=value.trim();
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
                                        errorStyle: GoogleFonts.balooBhai(),

                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.email,color: Colors.black,),
                                        ),
                                        border: InputBorder.none,
                                      ),


                                    ),
                                  ),
                                ),


                                if(phonesignup)
                                  Padding(
                                  padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                      controller: phoneFieldController,
                                      keyboardType: TextInputType.phone,
                                      onSaved: (var value){
                                        resformData['phone']="+91"+value;
                                      },
                                      onChanged: (var value){
                                        setState(() {
                                          phoneregistered=true;
                                          requestingotp=false;
                                        });
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
                                        labelText: "Phone Number",
                                        errorStyle: GoogleFonts.balooBhai(),

                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
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
                                  padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(color:Colors.black,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w700),
                                      onSaved: (var value){
                                        resformData['password']=value;
                                        ressignupData['password']=value;
                                      },
                                      validator:(val){
                                        if(val==""||val==null){
                                          return "Empty Password";
                                        }
                                        else{
                                          return null;
                                        }
                                      },
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        errorStyle: GoogleFonts.balooBhai(),

                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        suffixIcon: IconButton(icon:_obscureText ? Icon(Icons.lock,color: Colors.black,size: 28.0,):
                                        Icon(Icons.lock_open,color: Colors.black,size: 28.0,),
                                          onPressed: _toggle,),
                                        border: InputBorder.none,
                                      ),

                                    ),
                                  ),
                                ),

                                if(onsignupclick)
                                  Padding(
                                  padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: TextFormField(
                                      style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                      onSaved: (var value){
                                        ressignupData['phone']="+91"+value;
                                      },
                                      onChanged: (var value){
                                        setState(() {
                                          phoneregistered=false;
                                        });
                                      },
                                      validator:(String value){
                                        if (value.trim().length!=13) {
                                          signupvalidation=false;
                                          return "Invalid Phone Number";
                                        }
                                        else{
                                          signupvalidation=true;
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: "Phone Number",
                                        labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                        errorStyle: GoogleFonts.balooBhai(),

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
                                    padding: const EdgeInsets.only(left:25.0,right:25.0,top:9.0,bottom:5.0),
                                    child: Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      child: TextFormField(
                                        maxLines: 3,
                                        style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.black,fontWeight: FontWeight.w700),
                                        onSaved: (var value){
                                          ressignupData['address']=value;
                                        },
                                        validator:(val){
                                          if(val==""||val==null){
                                            return "Please enter something";
                                          }
                                          else{
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Store Address",
                                          errorStyle: GoogleFonts.balooBhai(),
                                          labelStyle:GoogleFonts.happyMonkey(fontSize: MediaQuery.of(context).size.width*0.045),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 5.0),
                                          suffixIcon: Icon(Icons.home,size:30.0,color: Colors.black,),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                   ),
                                  ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    if(onsubmit==false && !phonesignup)
                                      Padding(
                                      padding: const EdgeInsets.only(left:20.0,right:10.0,top:17.0,bottom:20.0),
                                      child: MaterialButton(
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Icon(Icons.assignment_ind,color: Colors.red,),
                                            Text("Login",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0452,fontWeight: FontWeight.w600,color: Colors.red)),
                                          ],
                                        ),
                                        onPressed: (){
                                          setState(() {
                                              _formKey2.currentState.save();
                                              loading=true;
                                            Firestore.instance.collection('restaurants').document(resformData['email']).get().then((snapshot) {
                                              if(snapshot.exists && snapshot.data['registrationapproved']!=false &&resformData['email']==snapshot.data['email'] && resformData['password']==snapshot.data['password']){
                                                setState(() {
                                                  status="Successfully Loggedin";
                                                  Navigator.pushReplacement(context, MaterialPageRoute(
                                                      builder: (context)=>ResScreen()
                                                  ));
                                                });
                                              }
                                              else{
                                                if(snapshot.exists && snapshot.data['registrationapproved']==false){
                                                  setState(() {
                                                    status="Registration Incomplete";
                                                    loading=false;
                                                  });
                                                }
                                                else{
                                                  setState(() {
                                                    status="Invalid Credentials";
                                                    loading=false;
                                                  });
                                                }
                                              }
                                            });
                                          });
                                        },
                                      ),
                                    ),

                                    if(onsubmit==true && !phonesignup)
                                      Padding(
                                        padding: const EdgeInsets.only(left:10.0,right:10.0,top:17.0,bottom:20.0),
                                        child: MaterialButton(
                                          elevation: 10.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.assignment,color:Colors.lightGreen),
                                              Text("Submit",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0452,fontWeight: FontWeight.w600,color: Colors.lightGreen)),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              _formKey2.currentState.validate();
                                              if (signupvalidation) {
                                                _formKey2.currentState.save();
                                                print(ressignupData);
                                                Firestore.instance.collection('restaurants').document(ressignupData['email']).setData({
                                                  'name':ressignupData['name'],
                                                  'email':ressignupData['email'],
                                                  'password':ressignupData['password'],
                                                  'address':ressignupData['address'],
                                                  'phone':ressignupData['phone'],
                                                  'registrationapproved':false,
                                                });
                                                Firestore.instance.collection('regphones_restaurant').document("${ressignupData['phone']}").setData({
                                                  'phone_number': ressignupData['phone'],
                                                });
                                                signupfieldopac=0.0;
                                                onsignupclick=false;
                                                onsubmit=false;
                                                status="Wait for Approval";
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
                                        padding: const EdgeInsets.only(left:10.0,right:10.0,top:17.0,bottom:20.0),
                                        child: MaterialButton(
                                          elevation: 10.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.reply,color:Colors.blueGrey),
                                              Text("Return",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0452,fontWeight: FontWeight.w600,color: Colors.blueGrey)),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              onsignupclick=false;
                                              onsubmit=false;
                                            });
                                          },
                                        ),
                                      ),

                                    if(phonesignup)Padding(
                                      padding: const EdgeInsets.only(left:10.0,right:10.0,top:17.0,bottom:20.0),
                                      child: MaterialButton(
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: !requestingotp ?Row(
                                          children: <Widget>[
                                            Icon(Icons.message,color: Colors.red,),
                                            Text("Request OTP",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600,color: Colors.red)),
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
                                            _formKey2.currentState.save();
                                            if(resformData['phone']!=""){
                                              loading=true;
                                              requestingotp=true;
                                              Firestore.instance.collection('restaurants').where('phone',isEqualTo: resformData['phone']).getDocuments().then((QuerySnapshot docs){
                                                if(docs.documents.isNotEmpty){
                                                  if(docs.documents.elementAt(0).data['registrationapproved']==true){
                                                    Firestore.instance.collection('regphones_restaurant').document('${resformData['phone']}').get().then((doc){
                                                      if(doc.exists){
                                                        setState(() {
                                                          phoneregistered=true;
                                                          status="Number Verified :)";
                                                        });
                                                        final phone=phoneFieldController.text.trim();
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
                                                  }
                                                  else{
                                                    setState(() {
                                                      phoneregistered=false;
                                                      status="Unregistered Number";
                                                      requestingotp=false;

                                                    });
                                                  }
                                                }
                                                else{
                                                  setState(() {
                                                    phoneregistered=false;
                                                    status="Unregistered Number";
                                                    requestingotp=false;

                                                  });
                                                }
                                              });
                                            }
                                            else{
                                              setState(() {
                                               phoneregistered=false;
                                               requestingotp=false;
                                              });
                                            }

                                          });
                                        },
                                      ),
                                    ),


                                    if(onsubmit==false && !phonesignup)
                                      Padding(
                                        padding: const EdgeInsets.only(left:10.0,right:20.0,top:17.0,bottom:20.0),
                                        child: MaterialButton(
                                          elevation: 10.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.person,color:Colors.blueAccent),
                                              Text("Signup",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0452,fontWeight: FontWeight.w600,color: Colors.blueAccent)),
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
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}


