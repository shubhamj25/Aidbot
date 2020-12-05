import 'package:auto_food/customshape2.dart';
import 'package:auto_food/restaurant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:progress_indicators/progress_indicators.dart';
Map<String, dynamic> resformData = {'email': null, 'password': null,'phone':null};
Map<String, dynamic> ressignupData = {'name':null,'email': null, 'password': null,'address':null,'phone':null};

class ResScreen extends StatefulWidget {
  bool expandorders=false;
  @override
  _ResScreenState createState() => _ResScreenState();
}

class _ResScreenState extends State<ResScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return SafeArea(
      child: Scaffold(
        key:_scaffoldKey,
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width-40.0,
          child: Drawer(
            child: Container(
              color: Colors.black87,
              child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top:30,bottom:8.0),
                      child: Center(child: Icon(Icons.account_box,color: Colors.white,size: 80.0,)),
                    ),
                    Center(child: Text("Manage Orders\n",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.055,color: Colors.white,fontWeight: FontWeight.w700),)),
                  ],
              )
            ),
          ),
        ),

        body:SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: CustomShape2(),
                    child: Container(height:MediaQuery.of(context).size.height*0.7,decoration: BoxDecoration(
                        gradient: LinearGradient(colors:[
                          Colors.deepPurple,Colors.indigoAccent
                        ])
                    ),),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top:40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left:20.0),
                          child: FloatingActionButton(
                            heroTag: 1,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.menu,color: Colors.black87,),
                            onPressed: (){
                              _scaffoldKey.currentState.openDrawer();
                            },
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(right:20.0),
                          child: FloatingActionButton(
                            heroTag: 2,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.exit_to_app,color: Colors.deepOrange,),
                            onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(
                                builder: (context)=>ResLoadScreen(),
                              ));
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left:8.0,right:8.0,top:120.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            elevation: 12.0,
                            child:  Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.check_circle,color: Colors.blue,size:30.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Total",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.05),),
                                      ),
                                    ],
                                  ),
                                ),

                                StreamBuilder<QuerySnapshot>(
                                  stream: Firestore.instance.collection("Allorders").snapshots(),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top:30.0,left:55.0),
                                      child: AnimatedCount(count: !snapshot.hasData ? 0:snapshot.data.documents.length, duration:  Duration(seconds: 3)),
                                    );
                                  }
                                ),

                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            elevation: 12.0,
                            child:  Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.motorcycle,color: Colors.green,size:30.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Delivered",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.05),),
                                      ),
                                    ],
                                  ),
                                ),

                                StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance.collection("Allorders").snapshots(),
                                    builder: (context, snapshot) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top:30.0,left:55.0),
                                        child: AnimatedCount(count: !snapshot.hasData ? 0:snapshot.data.documents.where((i) => i.data['status'] == "Delivered").toList().length, duration:  Duration(seconds: 3)),
                                      );
                                    }
                                ),

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left:8.0,right:8.0,top:200.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            elevation: 12.0,
                            child:  Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.close,color: Colors.red,size:30.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Canceled",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.05),),
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance.collection("Allorders").snapshots(),
                                    builder: (context, snapshot) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top:30.0,left:55.0),
                                        child: AnimatedCount(count: !snapshot.hasData ? 0:snapshot.data.documents.where((i) => i.data['status'] == "Canceled").toList().length, duration:  Duration(seconds: 3)),
                                      );
                                    }
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.0)),
                            ),
                            elevation: 12.0,
                            child:  Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.play_circle_filled,color: Colors.deepPurpleAccent,size:30.0),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Active",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.05),),
                                      ),
                                    ],
                                  ),
                                ),

                                StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance.collection("Allorders").snapshots(),
                                    builder: (context, snapshot) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top:30.0,left:55.0),
                                        child: AnimatedCount(count: !snapshot.hasData ? 0:snapshot.data.documents.where((i) => i.data['status'] != "Delivered" && i.data['status'] != "Canceled").toList().length, duration:  Duration(seconds: 3)),
                                      );
                                    }
                                ),

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(left:20.0,right:20.0,top:300.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.assignment,size:30.0,color: Colors.white,),
                        ),
                        Text("Customer Orders",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.06,color:Colors.white,fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top:340.0),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('Allorders').snapshots(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasData) {
                            activeOrders.clear();
                            for (int i = 0; i < snapshot.data.documents.length; i++) {
                             activeOrders.add(Ordercard(
                                    OrderCardDetails.fromSnapshot(snapshot.data.documents[i])));

                            }
                            activeOrders.sort((a,b){ return b.orderCardDetails.time.compareTo(a.orderCardDetails.time);});
                          }


                          return !snapshot.hasData? CircularProgressIndicator():
                          Padding(
                            padding: const EdgeInsets.only(top:18.0,bottom: 18.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children:activeOrders,
                              ),
                            ),
                          );
                        }
                    ),
                  ),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Ordercard> activeOrders=[];
List<String>orderids=[];

class OrderCardDetails{
  String orderid;
  List<dynamic> orderItemslist;
  int grandT;
  String status;
  String pin;
  String customername;
  String email;
  String phone;
  String address;
  Timestamp time;
  OrderCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['orderid']!=null),
        orderid=map['orderid'],
        orderItemslist=map['dishes'],
        grandT=map['grandtotal'],
        status=map['status'],
        customername=map['deliverto'],
        email=map['customer_email'],
        phone=map['customer_phone'],
        address=map['deliveryaddress'],
        time=map['timestamp'],
        pin=map['pin'];

  OrderCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}

class Ordercard extends StatefulWidget {
  OrderCardDetails orderCardDetails;
  Ordercard(this.orderCardDetails);
  @override
  _OrdercardState createState() => _OrdercardState();
}

class _OrdercardState extends State<Ordercard> {
  final db=FirebaseDatabase.instance.reference();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    final PinController=TextEditingController(text:"${widget.orderCardDetails.pin}");
    final StatusController=TextEditingController(text:"${widget.orderCardDetails.status}",);
    List<OrderItems> items=[];
    for(int i=0;i<widget.orderCardDetails.orderItemslist.length;i++){
      items.add(OrderItems(widget.orderCardDetails.orderItemslist.elementAt(i)));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 6.0),
      child: GroovinExpansionTile(
        initiallyExpanded: false,
        boxDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2.0,
              spreadRadius: 2.0,
              offset:Offset(2.0,2.0)
            )
          ]
        ),
        backgroundColor: Colors.white,
        leading: widget.orderCardDetails.status=="Delivered"?
        Icon(Icons.check_circle,color: Colors.blue,size: 40.0,):widget.orderCardDetails.status=="Canceled"? Icon(Icons.close,color: Colors.red,size: 40.0,):Icon(Icons.play_circle_filled,color: Colors.green,size: 40.0,),
        title: Text("Orderid : ${widget.orderCardDetails.orderid}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.045),),
        children:<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Card(
              elevation: 12.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(

                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right:15.0,left:15.0,top:10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Deliver To:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.045))),

                        Expanded(child: Text("${widget.orderCardDetails.customername}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.045))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:15.0,vertical:1.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Delivery\nAddress:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.045))),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("${widget.orderCardDetails.address}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.045)),
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:15.0,left:15.0,bottom:10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Placed On:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.045))),
                        Expanded(child: Text("${widget.orderCardDetails.time.toDate().day}/${widget.orderCardDetails.time.toDate().month}/${widget.orderCardDetails.time.toDate().year} at ${widget.orderCardDetails.time.toDate().hour}:${widget.orderCardDetails.time.toDate().minute} hrs",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.045))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: items,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
            child:Material(
              elevation: 12.0,
              color: widget.orderCardDetails.status=="Delivered"?Colors.green:widget.orderCardDetails.status=="Dispatched"?Colors.deepOrangeAccent:widget.orderCardDetails.status=="Canceled"?Colors.red:Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              child: TextFormField(
                style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.white,fontWeight: FontWeight.w700),
                controller: StatusController,
                decoration: InputDecoration(
                  labelText: "Set Status",
                  labelStyle:GoogleFonts.happyMonkey(color:Colors.white,fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.045),
                  contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),
                  suffixIcon:IconButton(icon: Icon(Icons.edit,color: Colors.white,),
                  onPressed: (){
                    setState(() {
                      Firestore.instance.collection("Allorders").document("${widget.orderCardDetails.orderid}").updateData({
                        'status':StatusController.text.toString(),
                      }).then((value) => {
                        db.child("Allorders").child("${widget.orderCardDetails.orderid}").update(
                            {'status':StatusController.text.toString(),})
                      });
                      Firestore.instance.collection("orders${widget.orderCardDetails.email}").document("${widget.orderCardDetails.orderid}").updateData({
                        'status':StatusController.text.toString(),
                      });
                    });
                  },
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          if (widget.orderCardDetails.status!="Delivered" && widget.orderCardDetails.status!="Canceled") Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Material(
              elevation: 12.0,
              color: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              child: TextFormField(
                controller: PinController,
               keyboardType: TextInputType.phone,
               style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color:Colors.white,fontWeight: FontWeight.w700),
               decoration: InputDecoration(
                 labelText: "Set PIN",
                 labelStyle:GoogleFonts.happyMonkey(color:Colors.white,fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.045),
                 contentPadding: EdgeInsets.symmetric(horizontal: 18.0,vertical: 8.0),

                 suffixIcon: IconButton(icon:Icon(Icons.send,color: Colors.white,),
                 onPressed: (){
                   setState(() {
                     Firestore.instance.collection("Allorders").document("${widget.orderCardDetails.orderid}").updateData({
                       'pin':PinController.text.toString(),
                     }).then((value) => {
                       db.child("Allorders").child("${widget.orderCardDetails.orderid}").update(
                           {'pin':PinController.text.toString(),})
                     });
                     Firestore.instance.collection("orders${widget.orderCardDetails.email}").document("${widget.orderCardDetails.orderid}").updateData({
                       'pin':PinController.text.toString(),
                     });
                   });
                 },),
                 border: InputBorder.none,
               ),

                  ),
            ),
          ),
          if (widget.orderCardDetails.status!="Delivered" && widget.orderCardDetails.status!="Canceled" )Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MaterialButton(
                  elevation: 10.0,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.cancel,color:Colors.red),
                      Text("Cancel",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,fontWeight: FontWeight.w600,color: Colors.red),),
                    ],
                  ),
                  onPressed: (){
                    setState(() {
                      Firestore.instance.collection('Allorders').document('${widget.orderCardDetails.orderid}').updateData({
                        'status':"Canceled",
                      }).then((value) => {
                        db.child("Allorders").child("${widget.orderCardDetails.orderid}").update(
                            { 'status':"Canceled",})
                      });
                      Firestore.instance.collection('orders${widget.orderCardDetails.email}').document('${widget.orderCardDetails.orderid}').updateData({
                        'status':"Canceled",
                      });
                    });
                  },
                ),
              )
            ],
          )
        ],
        subtitle: Text("Grand Total: Rs ${widget.orderCardDetails.grandT}",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.048,fontWeight:FontWeight.w600),),
      ),
    );
  }
}



class OrderItems extends StatefulWidget {
  String orderItemTitle;
  OrderItems(this.orderItemTitle);
  @override
  _OrderItemsState createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2.0),
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top:10.0,bottom:10.0),
                child: Text(widget.orderItemTitle,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedCount extends ImplicitlyAnimatedWidget {
  final int count;

  AnimatedCount({
    Key key,
    @required this.count,
    @required Duration duration,
    Curve curve = Curves.linear
  }) : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween _count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Text(_count.evaluate(animation).toString(),style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.06,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
    );
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    _count = visitor(_count, widget.count, (dynamic value) => new IntTween(begin: value));
  }
}