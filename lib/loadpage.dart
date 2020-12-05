import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_food/sendFile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_food/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'cshape.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';
import 'package:progress_indicators/progress_indicators.dart';


Future<void> main() async{
  RenderErrorBox.backgroundColor = Colors.transparent;
  RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);

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
          home: SingleChildScrollView(child: Homepage()),
          theme: ThemeData(
            fontFamily: 'Raleway',
            primaryColor: Colors.pink,
            accentColor: Colors.deepPurple,
          ),
        )
    );
    Firestore.instance.collection('cartItems${formData['email']}').getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});
  } else {
    runApp(
        MaterialApp(
          title: "AutoFood",
          debugShowCheckedModeBanner: false,
          home: Load(),
          theme: ThemeData(
            fontFamily: 'Raleway',
            primaryColor: Colors.pink,
            accentColor: Colors.deepPurple,
          ),
        )
    );
  }
}


var uuid=Uuid();
List<Ordercard> activeOrders=[];
int cartcnt= addedToCart.length;
int cartSum=0;
bool onCartTap=false;
double cartTileOpacity=1.0;

List<String>orderids=[];

Map<String, dynamic> formData = {'email': null, 'password': null,'phone':null};
Map<String, dynamic> signupData = {'name':null,'email': null, 'password': null,'address':null,'phone':null};

Map<String, dynamic> orderData = {'name':null,'email': null,'address':null,'phone':null};


class Homepage extends StatefulWidget {
  bool expanded0=false;
  bool expanded1=false;
  bool expanded2=false;
  bool expanded3=false;
  bool expanded4=false;
  bool expandorders=false;
  String orderid="";
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey=new GlobalKey<ScaffoldState>();
  final databaseReference = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDestinations();
    Firestore.instance.collection('users')
        .where("phone", isEqualTo: formData['email'].toString()).getDocuments().then((QuerySnapshot doc){
      if(doc.documents.isNotEmpty){
        setState(() {
          orderData['name']=doc.documents[0].data['name'];
          orderData['email']=doc.documents[0].data['email'];
          orderData['address']=doc.documents[0].data['address'];
          orderData['phone']=doc.documents[0].data['phone'];
        });
      }
      else if(doc.documents.isEmpty){
        Firestore.instance.collection('users')
            .where('email',isEqualTo: formData['email'].toString()).getDocuments().then((QuerySnapshot snapshots){
          if(snapshots.documents.isNotEmpty){
            setState(() {
              orderData['name']=snapshots.documents[0].data['name'];
              orderData['email']=snapshots.documents[0].data['email'];
              orderData['address']=snapshots.documents[0].data['address'];
              orderData['phone']=snapshots.documents[0].data['phone'];
            });
          }
        });
      }
    });
    print(orderData);
  }
  bool placingorder=false;

  String  _selectedDestination="Select Destination";
  List<DropdownMenuItem<String>> destinations = [
    DropdownMenuItem(
      child: new Text('Select Destination',style:GoogleFonts.happyMonkey(
          color: Colors.white,
          fontSize: 16.0
      ),),
      value: "Select Destination",
    ),
  ];

  void initDestinations(){
    Firestore.instance.collection("directions").getDocuments().then((docs) => {
      if(docs.documents.length >0){
        for(int i=0;i<docs.documents.length;i++){
          destinations.add(DropdownMenuItem(
            child: new Text("${docs.documents.elementAt(i).data['roomId']}",style:GoogleFonts.happyMonkey(
                color: Colors.white,
                fontSize: 16.0
            ),),
            value: "${docs.documents.elementAt(i).data['roomId']}",
          ))
        }
      }
    });
  }
  bool destinationNotSelected=false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Container(
      height:MediaQuery.of(context).size.height,
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
                    padding: const EdgeInsets.only(bottom:28.0),
                    child: Column(
                      children: <Widget>[
                        onCartTap==false ?Padding(
                          padding: const EdgeInsets.only(top:30,bottom:8.0),
                          child: Center(child: Icon(Icons.local_dining,color: Colors.white,size: 80.0,)),
                        ):
                        Padding(
                          padding: const EdgeInsets.only(top:30,bottom:8.0),
                          child: Center(child: Icon(Icons.shopping_basket,color: Colors.white,size: 80.0,)),
                        ),

                    Column(
                      children: <Widget>[
                         if(onCartTap==false) Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: ListTile(
                            title:Center(child: Text("Welcome to AIDbot\n",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.05,color: Colors.white,fontWeight: FontWeight.w800),)),
                             subtitle: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: <Widget>[
                                 if(formData['email']!=null)Expanded(child: Text("Loggedin as\n${formData['email']}",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,color: Colors.white,))),
                                 IconButton(
                                   icon:Icon(Icons.exit_to_app,color: Colors.white,size: 30.0,),
                                   onPressed: (){
                                     setState(() {
                                       formData['email']=null;
                                       formData['password']=null;
                                       Navigator.pushReplacement(context, MaterialPageRoute(
                                         builder: (context)=>LoadScreen(),
                                       ));
                                     });
                                   },
                                 ),
                               ],
                             ),

                        ),
                         ),

                        if(onCartTap==false)
                          Column(
                            children: <Widget>[
                              StreamBuilder<QuerySnapshot>(
                                  stream: Firestore.instance.collection("menuItems").snapshots(),
                                  builder: (BuildContext context,snapshot) {
                                    if (snapshot.hasData) {
                                      menuItems.clear();
                                      for (int i = 0; i <
                                          snapshot.data.documents.length; i++) {
                                        menuItems.add(MenuItems(
                                            MenuItemDetails.fromSnapshot(
                                                snapshot.data.documents[i])));
                                      }
                                    }
                                    return !snapshot.hasData ? Padding(
                                      padding: const EdgeInsets.only(top:100.0),
                                      child: Center(
                                          child: Container(height:26,width:26,child:CircularProgressIndicator(strokeWidth:2,backgroundColor:Colors.white))),
                                    ) :
                                    Column(
                                      children: <Widget>[
                                        if(onCartTap==false) ExpansionTile(
                                          leading:Icon(Icons.restaurant_menu,color: Colors.white,),
                                          title:Text("Snacks & Meals",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,color: Colors.white),),
                                          children: menuItems.where((i)=>i.menuItemDetails.menuItemType=='snacks').toList(),
                                          trailing: widget.expanded0 ? Icon(Icons.do_not_disturb_on,color: Colors.white,size: 30.0,):
                                          Icon(Icons.add_circle,color: Colors.white,size: 30.0,),
                                          onExpansionChanged: (x){
                                            setState(() {
                                              widget.expanded0=x;
                                            });
                                          },
                                        ),

                                        if(onCartTap==false) ExpansionTile(
                                          leading:Icon(Icons.attach_file,color: Colors.white,),
                                          title:Text("Stationary",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,color: Colors.white),),
                                          children: menuItems.where((i)=>i.menuItemDetails.menuItemType=='stationary').toList(),
                                          trailing: widget.expanded1 ? Icon(Icons.do_not_disturb_on,color: Colors.white,size: 30.0,):
                                          Icon(Icons.add_circle,color: Colors.white,size: 30.0,),
                                          onExpansionChanged: (x){
                                            setState(() {
                                              widget.expanded1=x;
                                            });
                                          },
                                        ),

                                        if(onCartTap==false) ExpansionTile(
                                          leading:Icon(Icons.help,color: Colors.white,),
                                          title:Text("Utilities",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,color: Colors.white),),
                                          children: menuItems.where((i)=>i.menuItemDetails.menuItemType=='utility').toList(),
                                          trailing: widget.expanded2 ? Icon(Icons.do_not_disturb_on,color: Colors.white,size: 30.0,):
                                          Icon(Icons.add_circle,color: Colors.white,size: 30.0,),
                                          onExpansionChanged: (x){
                                            setState(() {
                                              widget.expanded2=x;
                                            });
                                          },
                                        ),

                                        if(onCartTap==false)
                                          ListTile(
                                            leading:Icon(Icons.insert_drive_file,color: Colors.white,size: 30,),
                                            title: Text("Send/Receive File",style: GoogleFonts.happyMonkey(fontSize: 18,color: Colors.white),),
                                            subtitle: Text("Send Paperback version of a file to your colleague",style: GoogleFonts.happyMonkey(fontSize: 15,color: Colors.white),),
                                            onTap: (){
                                               Navigator.push(context, MaterialPageRoute(builder: (context){
                                                 return SendFile();
                                               }));
                                            },
                                          )



                                      ],
                                    );
                                  }
                              ),
                            ],
                          ),



                          


                        if (onCartTap==true)
                      Column(
                        children: <Widget>[
                          if(onCartTap=true)
                            StreamBuilder<QuerySnapshot>(
                                stream: Firestore.instance.collection('orders${orderData['email']}').snapshots(),
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.hasData) {
                                    activeOrders.clear();
                                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                                        activeOrders.add(Ordercard(
                                            OrderCardDetails.fromSnapshot(snapshot.data.documents[i])));
                                    }
                                    activeOrders.sort((a,b){ return b.orderCardDetails.time.compareTo(a.orderCardDetails.time);});
                                  }
                                  return ExpansionTile(
                                    leading:Icon(Icons.check_circle,color: Colors.white,),
                                    title:Text("All Orders",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,color: Colors.white),),
                                    children:activeOrders,
                                    trailing: widget.expandorders ? Icon(Icons.do_not_disturb_on,color: Colors.white,size: 25.0,):
                                    Icon(Icons.add_circle,color: Colors.white,size: 25.0,),
                                    onExpansionChanged: (x){
                                      setState(() {
                                        widget.expandorders=x;
                                      });
                                    },);
                                }
                            ),

                          if (onCartTap==true) ListTile(
                            leading:Icon(Icons.shopping_cart,color: Colors.white,),
                            title:Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Cart",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,color: Colors.white),),
                                IconButton(icon: Icon(Icons.remove_shopping_cart,color: Colors.white,size:25.0),
                                  onPressed: (){
                                    setState(() {
                                      cartTileOpacity=0.0;
                                      Firestore.instance.collection('cartItems${formData['email']}').getDocuments().then((snapshot) {
                                        for (DocumentSnapshot ds in snapshot.documents){
                                          ds.reference.delete();
                                        }});
                                      cartSum=0;
                                    });
                                  },
                                )
                              ],
                            ),

                          ),


                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance.collection("cartItems${formData['email']}").snapshots(),
                            builder: (BuildContext context,snapshot) {
                              if (snapshot.hasData) {
                                addedToCart.clear();
                                for (int i = 0; i <
                                    snapshot.data.documents.length; i++) {
                                  addedToCart.add(CartItems(
                                      CartItemDetails.fromSnapshot(
                                          snapshot.data.documents[i])));
                                }
                              }
                              return !snapshot.hasData ? Padding(
                                padding: const EdgeInsets.only(top:100.0),
                                child: Center(
                                    child: CircularProgressIndicator(backgroundColor: Colors.white,)),
                              ) :
                              Column(

                                children: <Widget>[
                                  Column(
                                    children: addedToCart,
                                  ),
                                  if (onCartTap==true && addedToCart.isNotEmpty)Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 12.0),
                                    child: Container(height:2.0,width:MediaQuery.of(context).size.width-40.0,color: Colors.white70,),
                                  ),

                                  if (onCartTap==true && addedToCart.isNotEmpty) Container(
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(child: Center(child: Text("Total",style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,fontWeight: FontWeight.w800,color:Colors.white)))),
                                          Expanded(child: Center(child: Text(
                                            'Rs.${addedToCart.map<int>((m)=>m.cartItemDetails.cartItemQuantity*m.cartItemDetails.cartItemPrice).reduce((a,b)=>a+b)}',
                                            style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,fontWeight: FontWeight.w800,color: Colors.white),)))
                                        ],
                                      )
                                  ),
                                  if (onCartTap==true && addedToCart.isNotEmpty)Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 12.0),
                                    child: Container(height:2.0,width:MediaQuery.of(context).size.width-40.0,color: Colors.white70,),
                                  ),

                                  if (onCartTap==true && addedToCart.isNotEmpty)
                                    ListTile(
                                      leading: FloatingActionButton(
                                          child: destinationNotSelected==false?Icon(Icons.timeline,color: Colors.black,):Icon(Icons.error,color: Colors.white,),
                                          backgroundColor: destinationNotSelected==false?Colors.white:Colors.redAccent,
                                      ),
                                      title:Text("Delivery Address",style:GoogleFonts.happyMonkey(fontSize:18,color:Colors.white)),
                                      subtitle:   DropdownButton(
                                        dropdownColor: Colors.grey,
                                        focusColor: Colors.grey,
                                        hint: new Text('Select RoomID'),
                                        items: destinations,
                                        value: _selectedDestination,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedDestination=value;
                                          });
                                        },
                                        isExpanded: true,
                                        style: GoogleFonts.happyMonkey(
                                          color: Colors.white,
                                        ),
                                        underline: null,
                                      ),
                                    ),

                                  SizedBox(height: 10,),
                                  if (onCartTap==true && addedToCart.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal:16.0),
                                      child: MaterialButton(
                                        color:Colors.white,
                                        shape:RoundedRectangleBorder(
                                              borderRadius:BorderRadius.all(Radius.circular(5.0)),
                              ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal:16.0,vertical:8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              placingorder?FadingText("Processing...",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0454,fontWeight: FontWeight.w700),):Text("Place Order",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0458,fontWeight: FontWeight.w700),),
                                            ],
                                          ),
                                        ),
                                        onPressed: (){
                                          if(_selectedDestination!="Select Destination"){
                                            String s="orders"+orderData['email'].toString();
                                            setState(() {
                                              destinationNotSelected=false;
                                              placingorder=true;
                                              String id;
                                              int grandtotal=addedToCart.map<int>((m)=>m.cartItemDetails.cartItemQuantity*m.cartItemDetails.cartItemPrice).reduce((a,b)=>a+b);
                                              List<String> dishes=[];
                                              for(int i=0;i<addedToCart.length;i++){
                                                dishes.add("${addedToCart[i].cartItemDetails.cartItemTitle} x ${addedToCart[i].cartItemDetails.cartItemQuantity} = Rs ${addedToCart[i].cartItemDetails.cartItemPrice * addedToCart[i].cartItemDetails.cartItemQuantity}");
                                              }
                                              print(formData['email']);
                                              print(orderData);

                                              databaseReference.child("counter").once().then((snapshot){
                                                id=snapshot.value.toString();
                                              }).then((value){
                                                Firestore.instance.collection(s).document("$id").setData({
                                                  'orderid':  '$id',
                                                  'dishes':dishes,
                                                  'grandtotal':grandtotal,
                                                  'status':"Preparing...",
                                                  'pin':"Order yet to dispatch",
                                                  'timestamp':Timestamp.now(),
                                                  'deliveryaddress':_selectedDestination,
                                                  'deliverto':orderData['name'],
                                                  'customer_phone':orderData['phone'],
                                                  'customer_email':orderData['email']
                                                });

                                                Firestore.instance.collection('Allorders').document("$id").setData({
                                                  'orderid':  '$id',
                                                  'dishes':dishes,
                                                  'grandtotal':grandtotal,
                                                  'status':"Preparing...",
                                                  'pin':"Order yet to dispatch",
                                                  'timestamp':Timestamp.now(),
                                                  'deliveryaddress':_selectedDestination,
                                                  'deliverto':orderData['name'],
                                                  'customer_phone':orderData['phone'],
                                                  'customer_email':orderData['email']
                                                });
                                                String directions;
                                                Firestore.instance.collection("directions").document("$_selectedDestination").get().then((doc) => {
                                                  if(doc.exists){
                                                    directions=doc.data['address']
                                                  }
                                                }).then((value) => {
                                                  databaseReference.child('Allorders').child("$id").set({
                                                    'orderid':  '$id',
                                                    'dishes':dishes,
                                                    'grandtotal':grandtotal,
                                                    'status':"Preparing...",
                                                    'pin':"Order yet to dispatch",
                                                    'timestamp':Timestamp.now().toString(),
                                                    'deliveryaddress':directions,
                                                    'deliverto':orderData['name'].toString(),
                                                    'customer_phone':orderData['phone'].toString(),
                                                    'customer_email':orderData['email'].toString()
                                                  })
                                                });
                                                widget.orderid="Order Placed Successfully with id:\n$id";
                                                orderids.add("$id");
                                                databaseReference.update({'counter': int.parse(id)+1});
                                              });
                                            });
                                            Timer(Duration(seconds: 3), () {
                                              Firestore.instance.collection('cartItems${formData['email']}').getDocuments().then((snapshot) {
                                                for (DocumentSnapshot ds in snapshot.documents){
                                                  ds.reference.delete();
                                                }});
                                              placingorder=false;
                                              widget.orderid="";
                                            });
                                          }
                                          else{
                                            setState(() {
                                              destinationNotSelected=true;
                                            });
                                          }
                                        },
                                      ),
                                    ),

                                  if (onCartTap==true && addedToCart.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15.0),
                                      child: Text("${widget.orderid}",style: GoogleFonts.happyMonkey(color:Colors.white,fontSize:MediaQuery.of(context).size.width*0.045,fontWeight:FontWeight.w500),),
                                    )
                                ],
                              );
                            }
                            ),

                        ],
                      ),



                      ],
                    ),



                ],
              ),
                  ),


                   ]
          ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(child: HomeScreen()),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top:10.0,left:18.0),
                  child: Container(
                    height: 55.0,
                    width: 55.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(4.0,4.0),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon:Icon(Icons.sort,color: Colors.black,size: 25.0,),
                      onPressed: (){
                        setState(() {
                          onCartTap=false;
                          widget.expanded0=false;
                          widget.expanded1=false;
                          widget.expanded2=false;
                          widget.expanded3=false;
                          widget.expanded4=false;
                          _scaffoldKey.currentState.openDrawer();
                          cartTileOpacity=0.0;
                        });
                      },
                      ),
                  ),
                ),


                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("cartItems${formData['email']}").snapshots(),
                  builder: (BuildContext context,snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(top:45.0,right: 18.0),
                      child: JumpingDotsProgressIndicator(
                        fontSize:MediaQuery.of(context).size.width*0.0450,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top:45.0,right: 18.0),
                      child: RaisedButton(
                          color: Colors.yellow,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                  width:50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  child: Center(child: Icon(Icons.shopping_cart,size:MediaQuery.of(context).size.width*0.1,color:Colors.black)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 21.0,vertical: 9),
                                child: Text('${snapshot.data.documents.length}',style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.035,fontWeight: FontWeight.w700,color: Colors.white),),
                              )
                            ],
                          ),
                        ),
                        onPressed: (){
                          setState(() {
                            widget.expandorders=false;
                            _scaffoldKey.currentState.openDrawer();
                            cartTileOpacity=1.0;
                            onCartTap=true;
                          });
                        },
                      )
                  );
                  }
                }
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PopularDishesDetails{
  final String imageUrl,title,cookTime;
  final double rating;
  final int price;
  int quantity;
  PopularDishesDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['title']!=null),
        assert(map['price']!=null),
        imageUrl=map['imageUrl'],
        title=map['title'],
        cookTime=map['cookTime'],
        rating=map['rating'],
        price=map['price'],
        quantity=map['quantity'];
  PopularDishesDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}



List<PopularDishes> popDish=[];


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int photoIndex=0;
  void _previousImage(){
    setState(() {
      photoIndex=photoIndex >0 ? photoIndex-1:0;
    });
  }
  void _nextImage(){
    setState(() {
      photoIndex=photoIndex <popDish.length-1 ? photoIndex+1:photoIndex;
    });
  }
  int _current=0;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Container(
      color: Color.fromARGB(255, 255, 255,204),
      child: Stack(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/twigger-93153.appspot.com/o/table.jpg?alt=media&token=02988165-fa7f-4efc-8df9-1a291d07da0f',
            fit: BoxFit.cover,
            fadeInDuration: Duration(milliseconds: 500),
            fadeInCurve: Curves.easeIn,
          ),

            Padding(
              padding: const EdgeInsets.only(top:125.0,left:25.0),
              child: Text("AIDbot",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.08,color: Colors.white)),
            ),

            Padding(
              padding: const EdgeInsets.only(top:160.0,left:25.0),
              child: Text("Delivery at DoorStep",style: GoogleFonts.happyMonkey(fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.06,color: Colors.white),),
            ),

          ClipPath(
            clipper: CustomShape(),
            child: Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
               color: Color.fromARGB(255, 255, 255,204),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  offset: Offset(4.0,4.0),
                )
              ],
            ),
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(left:25.0,right:25.0,top:220.0),
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              child: TextField(
                style: GoogleFonts.happyMonkey(color:Colors.black,fontSize:MediaQuery.of(context).size.width*0.039),
                decoration: InputDecoration(
                  hintText: "What would you like to buy?",
                  contentPadding: EdgeInsets.symmetric(horizontal: 32.0,vertical: 14.0),
                  suffixIcon: Material(
                    elevation:5.0,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: InkWell(
                      child: Icon(Icons.search,color: Colors.black,),
                      onTap: (){

                      },
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top:280.0),
            child: Container(
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top:15,left:25),
                        child: Icon(Icons.local_offer),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:15,left:8),
                        child: Text("Snack Time Special",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.0450,fontWeight:FontWeight.bold),),
                      ),
                    ],
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection("popDish").snapshots(),
                    builder: (BuildContext context,snapshot){
                      popDish.clear();
                      if(snapshot.hasData){
                        for(int i=0;i<snapshot.data.documents.length;i++) {
                          popDish.add(PopularDishes(
                              PopularDishesDetails.fromSnapshot(
                                  snapshot.data.documents[i])));
                        }
                      }
                      return !snapshot.hasData ? Scaffold(body: Center(child:Container(height:26,width:26,child:CircularProgressIndicator(strokeWidth:2,backgroundColor:Colors.white))))
                          : Padding(
                        padding: const EdgeInsets.only(top:50.0),
                        child: CarouselSlider.builder(
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll:true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          pauseAutoPlayOnTouch: Duration(seconds: 10),
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                          height:330,
                          itemCount: popDish.length,
                          itemBuilder: (BuildContext context,int itemIndex){
                            return popDish[itemIndex];
                          },
                          onPageChanged: (index){
                            setState(() {

                              _current=index;
                            });
                          },
                        ),
                      );
                    },
                  ),


                  Positioned(
                      top: 315.0,
                      left:25.0,
                      right: 25.0,
                      child:carouseldots(popDish.length,_current)
                  ),



                  Padding(
                    padding: const EdgeInsets.only(top:330.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top:15,left:25,bottom: 8.0),
                              child: Icon(Icons.attach_file),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top:15,left:8,bottom: 8.0),
                              child: Text("Stationary & Utilities",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.050,fontWeight:FontWeight.bold),),
                            ),
                          ],
                        ),

                      StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection("dishCard").snapshots(),
                        builder: (BuildContext context,snapshot) {
                          dishCards.clear();
                          if (snapshot.hasData) {
                            for (int i = 0; i <
                                snapshot.data.documents.length; i++) {
                              dishCards.add(DishCard(
                                  DishCardDetails.fromSnapshot(
                                      snapshot.data.documents[i])));
                            }
                          }
                          return !snapshot.hasData ? Center(
                              child: Container(height:26,width:26,child:CircularProgressIndicator(strokeWidth:2,backgroundColor:Colors.white))) :
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Column(
                              children: dishCards,
                            ),
                          );
                          }
                            ),
                         ],
                    ),
                  ),


                ],
              ),
            ),
          ),



        ],
      ),
    );
  }
}


class DishCardDetails{
  final String dishImg,dishTitle,dishCaption;
  final int dishPrice;
  int dishQuant;
  DishCardDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['dishTitle']!=null),
        assert(map['dishPrice']!=null),
        dishImg=map['dishImg'],
        dishTitle=map['dishTitle'],
        dishCaption=map['dishCaption'],
        dishPrice=map['dishPrice'],
        dishQuant=map['dishQuant'];
  DishCardDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}


List<DishCard> dishCards=[];

class carouseldots extends StatelessWidget {
  final int numberOfDots;
  final int photoIndex;
  carouseldots(this.numberOfDots,this.photoIndex);
  Widget _inactivePhoto(){
    return Padding(
      padding: const EdgeInsets.only(left:3.0,right:3.0),
      child: new Container(
        height: 8.0,
        width: 8.0,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius:BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    );
  }

  Widget _activePhoto(){
    return Padding(
      padding: const EdgeInsets.only(left:5.0,right:5.0),
      child: new Container(
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:BorderRadius.all(Radius.circular(5.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
              spreadRadius: 0.0,
            )
          ]
        ),
      ),
    );
  }

  List<Widget> _buildDots(){
    List<Widget> dots=[];
    for(int i=0;i<numberOfDots;++i){
      dots.add(
        i==photoIndex ? _activePhoto() : _inactivePhoto()
      );
    }
    return dots;
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:_buildDots(),
      ),
    );
  }
}

List<CartItems> addedToCart=[];
class CartItemDetails{
  final String cartItemTitle;
  final int cartItemPrice;
  int cartItemQuantity;
  CartItemDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['cartItemTitle']!=null),
        assert(map['cartItemPrice']!=null),
        cartItemTitle=map['cartItemTitle'],
        cartItemPrice=map['cartItemPrice'],
        cartItemQuantity=map['cartItemQuantity'];
  CartItemDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}

class CartItems extends StatefulWidget {
  CartItemDetails cartItemDetails;
  CartItems(this.cartItemDetails);
  @override
  _CartItemsState createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return AnimatedOpacity(
      duration: Duration(seconds: 2),
      opacity: cartTileOpacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
        child: Card(
          color: Color.fromARGB(255,  254, 251, 240),
          elevation: 20.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left:20.0,top:8.0,right:8.0,bottom:8.0),
                  child: Text(widget.cartItemDetails.cartItemTitle,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700)),
                ),
              ),
              Row(
                children: <Widget>[
                  StreamBuilder(
                      stream: Firestore.instance.collection("cartItems${formData['email']}").document(widget.cartItemDetails.cartItemTitle).snapshots(),
                      builder: (BuildContext context,snapshot) {
                        return !snapshot.hasData?Container(child: Padding(
                          padding: const EdgeInsets.only(top:65.0),
                          child: Center(child: Container(height:26,width:26,child:CircularProgressIndicator(strokeWidth:2,backgroundColor:Colors.white)),),
                        ),)
                            : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Icon(Icons.do_not_disturb_on,size:MediaQuery.of(context).size.width*0.045),
                                    ),
                                  ),
                                  onTap: (){
                                    setState(() {
                                      widget.cartItemDetails.cartItemQuantity=snapshot.data['cartItemQuantity'];
                                      if(widget.cartItemDetails.cartItemQuantity==1||widget.cartItemDetails.cartItemQuantity==0){
                                        Firestore.instance.collection('cartItems${formData['email']}').document(widget.cartItemDetails.cartItemTitle).delete();
                                      }
                                      else if(widget.cartItemDetails.cartItemQuantity>0){
                                        widget.cartItemDetails.cartItemQuantity--;
                                        Firestore.instance.collection('cartItems${formData['email']}').document(widget.cartItemDetails.cartItemTitle).updateData({'cartItemQuantity':widget.cartItemDetails.cartItemQuantity});
                                      }
                                    });
                                  },
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        border: Border.all(color: Colors.black,width: 2.0)
                                    ),
                                    child:Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text('${snapshot.data["cartItemQuantity"]}',style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w600),),
                                    )
                                ),

                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Icon(Icons.add_circle,size:MediaQuery.of(context).size.width*0.045),
                                    ),
                                  ),
                                  onTap:(){
                                    setState(() {
                                      widget.cartItemDetails.cartItemQuantity=snapshot.data['cartItemQuantity']+1;
                                      Firestore.instance
                                          .collection('cartItems${formData['email']}')
                                          .document(widget.cartItemDetails.cartItemTitle)
                                          .updateData({'cartItemQuantity':widget.cartItemDetails.cartItemQuantity});
                                    });
                                  },
                                ),

                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right:20.0),
                  child: Center(child: Text('Rs.${widget.cartItemDetails.cartItemQuantity*widget.cartItemDetails.cartItemPrice}',style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700))),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}


List<Icon> dishRating=[];
double counterOpac=0.0;

class PopularDishes extends StatefulWidget {
  PopularDishesDetails popularDishesDetails;
  PopularDishes(this.popularDishesDetails);
  bool onaddtocartbuttontap=false;
  @override
  _PopularDishesState createState() => _PopularDishesState();
}
class _PopularDishesState extends State<PopularDishes> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    dishRating.clear();
    int approxRating=widget.popularDishesDetails.rating.round();
    for(int i=0;i<approxRating;i++){
      dishRating.add(Icon(Icons.star,color:Colors.black));
    }
    for(int j =approxRating-1;j<5;j++){
      dishRating.add(Icon(Icons.star_border,color: Colors.black,));
    }

    return Padding(
      padding: const EdgeInsets.only(left:5.0,right:10.0),
      child: Container(
        height: 280.0,
        width: MediaQuery.of(context).size.width,
        child:  Stack(
          children: <Widget>[

            Card(
              color: Colors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              elevation: 10.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CachedNetworkImage(
                        width: 200.0,
                        height: 100.0,
                        imageUrl: widget.popularDishesDetails.imageUrl,
                        fit: BoxFit.contain,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeInCurve: Curves.easeIn,
                      ),
                    ),
                  ),

                  Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top:20,left:20.0),
                        child: Text(widget.popularDishesDetails.title,style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w600),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:20.0,top:45.0),
                        child: Text('Rs.${widget.popularDishesDetails.price}',style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700),),
                      ),




                      if(widget.onaddtocartbuttontap==false)
                        Positioned(
                          left: MediaQuery.of(context).size.width*0.54,
                          child: Padding(
                          padding: const EdgeInsets.only(top:20.0,bottom:8.0),
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(4.0,4.0),
                                  )
                                ],
                              ),
                              child:Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 5.0),
                                child: Icon(Icons.add_shopping_cart,color: Colors.white,),
                              ) ,
                            ),
                            onTap: (){
                              setState(() {
                                Firestore.instance.collection("cartItems${formData['email']}").document(widget.popularDishesDetails.title).get().then((onValue){
                                  onValue.exists ?
                                  widget.popularDishesDetails.quantity=onValue['cartItemQuantity']
                                      :Firestore.instance.collection("cartItems${formData['email']}").document(widget.popularDishesDetails.title).setData({
                                    'cartItemTitle':widget.popularDishesDetails.title,
                                    'cartItemPrice':widget.popularDishesDetails.price,
                                    'cartItemQuantity':widget.popularDishesDetails.quantity
                                  });

                                });
                                widget.onaddtocartbuttontap=true;
                              });
                            },
                          ),
                      ),
                        ),

                      if(widget.onaddtocartbuttontap==true)Positioned(
                        left: MediaQuery.of(context).size.width*0.5,
                        child: Padding(
                            padding: const EdgeInsets.only(top:6.0,bottom:8.0),
                            child: Container(
                                child: Row(
                                  children: <Widget>[

                                    widget.onaddtocartbuttontap==true?StreamBuilder(
                                        stream: Firestore.instance.collection("cartItems${formData['email']}").document(widget.popularDishesDetails.title).snapshots(),
                                        builder: (BuildContext context,AsyncSnapshot snapshot) {
                                          return !snapshot.hasData?Padding(
                                            padding: const EdgeInsets.only(top:18.0,left:18.0),
                                            child: CollectionScaleTransition(
                                              children: <Widget>[
                                                Icon(Icons.fiber_manual_record,color:Colors.red,size: 15.0,),
                                                Icon(Icons.fiber_manual_record,color: Colors.blue,size: 15.0,),
                                                Icon(Icons.fiber_manual_record,color: Colors.green,size: 15.0,),
                                              ],
                                            ),
                                          )
                                              : Padding(
                                            padding: const EdgeInsets.only(top:8.0),
                                            child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  InkWell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Container(
                                                        child: Icon(Icons.do_not_disturb_on,size:MediaQuery.of(context).size.width*0.042),
                                                      ),
                                                    ),
                                                    onTap: (){
                                                      setState(() {
                                                        widget.popularDishesDetails.quantity=snapshot.data['cartItemQuantity'];
                                                        if(widget.popularDishesDetails.quantity==1||widget.popularDishesDetails.quantity==0){
                                                          widget.onaddtocartbuttontap=false;
                                                          Firestore.instance.collection('cartItems${formData['email']}').document(widget.popularDishesDetails.title).delete();
                                                        }
                                                        else if(widget.popularDishesDetails.quantity>0){
                                                          widget.popularDishesDetails.quantity--;
                                                          Firestore.instance.collection('cartItems${formData['email']}').document(widget.popularDishesDetails.title).updateData({'cartItemQuantity':widget.popularDishesDetails.quantity});
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                          border: Border.all(color: Colors.black,width: 2.0)
                                                      ),
                                                      child:Padding(
                                                        padding: const EdgeInsets.all(5.0),
                                                        child: Text('${snapshot.data['cartItemQuantity']}',style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700),),
                                                      )
                                                  ),

                                                  InkWell(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left:8.0),
                                                      child: Container(
                                                        child: Icon(Icons.add_circle,size:MediaQuery.of(context).size.width*0.042 ,),
                                                      ),
                                                    ),
                                                    onTap:(){
                                                      setState(() {
                                                        widget.popularDishesDetails.quantity=snapshot.data['cartItemQuantity']+1;
                                                        Firestore.instance
                                                            .collection('cartItems${formData['email']}')
                                                            .document(widget.popularDishesDetails.title)
                                                            .updateData({'cartItemQuantity':widget.popularDishesDetails.quantity});
                                                      });
                                                    },
                                                  ),

                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                    ):Container(
                                      color: Colors.transparent,
                                      child: Text(""),
                                    ),

                                  ],
                                )
                            )
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top:65.0,left:20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                dishRating[0],
                                dishRating[1],
                                dishRating[2],
                                dishRating[3],
                                dishRating[4],
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right:20.0,bottom: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(2.0,2.0),
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 5.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.timer,color: Colors.black,),
                                      Text(widget.popularDishesDetails.cookTime,style: GoogleFonts.happyMonkey(color: Colors.orange,fontWeight: FontWeight.bold,fontSize:MediaQuery.of(context).size.width*0.04),)
                                    ],
                                  ),
                                ),
                              ),
                            )

                          ],
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}


class DishCard extends StatefulWidget {
  DishCardDetails dishCardDetails;
  DishCard(this.dishCardDetails);
  bool onTapped=false;
  @override
  _DishCardState createState() => _DishCardState();
}
class _DishCardState extends State<DishCard> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Padding(
      padding: const EdgeInsets.only(top:4.0,left:8.0,right:12.0,bottom:4.0),
      child: InkWell(
        child: Material(
          elevation: 12.0,color:  Color.fromARGB(255,  254, 251, 240),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  width:90,
                  height: 90.0,
                  imageUrl: widget.dishCardDetails.dishImg,
                  fit: BoxFit.contain,
                  fadeInDuration: Duration(milliseconds: 500),
                  fadeInCurve: Curves.easeIn,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left:10.0,right:12.0),
                        child: Text(widget.dishCardDetails.dishTitle,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700 )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:10.0,right:12.0),
                        child: Text(widget.dishCardDetails.dishCaption,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.038,fontWeight: FontWeight.w500 )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:10.0,bottom: 10.0,right:12.0),
                        child: Text('Rs.${widget.dishCardDetails.dishPrice}',style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w500)),
                      ),

                      if(widget.onTapped==true)
                        StreamBuilder(
                            stream:Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).snapshots(),
                            builder: (BuildContext context,snapshot) {
                              return !snapshot.hasData ? Padding(
                                padding: const EdgeInsets.only(top:10.0,bottom: 30.0),
                                child: CollectionScaleTransition(
                                  children: <Widget>[
                                    Icon(Icons.fiber_manual_record,color: Colors.red,size: 20.0,),
                                    Icon(Icons.fiber_manual_record,color:Colors.blue,size: 20.0,),
                                    Icon(Icons.fiber_manual_record,color: Colors.yellow,size: 20.0,),
                                    Icon(Icons.fiber_manual_record,color: Colors.green,size: 20.0,),
                                  ],
                                )
                              ) :
                              AnimatedOpacity(
                                duration: Duration(seconds: 1),
                                opacity: counterOpac,
                                child: Container(

                                  child: Row(
                                    children: <Widget>[
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            child: Icon(Icons.do_not_disturb_on,size: MediaQuery.of(context).size.width*0.05,),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            widget.dishCardDetails.dishQuant =
                                            snapshot.data['cartItemQuantity'];
                                            if (widget.dishCardDetails.dishQuant == 1 ||
                                                widget.dishCardDetails.dishQuant== 0) {
                                              widget.onTapped=false;
                                              Firestore.instance.collection(
                                                  'cartItems${formData['email']}').document(
                                                  widget.dishCardDetails.dishTitle).delete();
                                            }
                                            else if (widget.dishCardDetails.dishQuant > 0) {
                                              widget.dishCardDetails.dishQuant--;
                                              Firestore.instance.collection(
                                                  'cartItems${formData['email']}').document(
                                                  widget.dishCardDetails.dishTitle).updateData({
                                                'cartItemQuantity': widget
                                                    .dishCardDetails.dishQuant
                                              });
                                            }
                                          });
                                        },
                                      ),

                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2.0)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.0),
                                            child: Text(
                                              '${snapshot.data['cartItemQuantity']}',
                                              style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.042,
                                                  fontWeight: FontWeight
                                                      .w600),),
                                          )
                                      ),
                                      InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            child: Icon(Icons.add_circle,size: MediaQuery.of(context).size.width*0.05,),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            widget.dishCardDetails.dishQuant=snapshot.data['cartItemQuantity']+1;

                                            Firestore.instance
                                                .collection('cartItems${formData['email']}')
                                                .document(widget.dishCardDetails.dishTitle)
                                                .updateData({'cartItemQuantity':widget.dishCardDetails.dishQuant});
                                          });
                                        },
                                      ),

                                      StreamBuilder(
                                          stream: Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).snapshots(),
                                          builder: (BuildContext context,snapshot) {
                                            return !snapshot.hasData?Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 38.0,
                                                    left: 30.0,
                                                    right: 8.0,
                                                    bottom: 8.0),
                                                child: GlowingProgressIndicator(
                                                  child: Icon(Icons.restaurant,size:20.0),
                                                ),
                                              ),
                                            )
                                                :InkWell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0,
                                                    left: 30.0,
                                                    right: 8.0,
                                                    bottom: 8.0),
                                                child: Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration: BoxDecoration(
                                                        color: Colors.deepOrange,
                                                        borderRadius: BorderRadius
                                                            .all(
                                                            Radius.circular(30.0)),

                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 2.0,
                                                              spreadRadius: 0.0,
                                                              offset: Offset(
                                                                  2.0, 2.0),
                                                              color: Colors.grey
                                                          )
                                                        ]
                                                    ),

                                                    child: snapshot.data['cartItemQuantity'] ==0
                                                        ? Icon(
                                                      Icons.add_shopping_cart,
                                                      color: Colors.white,
                                                      size:MediaQuery.of(context).size.width*0.06,
                                                    )
                                                        : Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: MediaQuery.of(context).size.width*0.06,
                                                    )

                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).get().then((onValue){
                                                    onValue.exists ?
                                                    Container()
                                                        :Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).setData({
                                                      'cartItemTitle':widget.dishCardDetails.dishTitle,
                                                      'cartItemPrice':widget.dishCardDetails.dishPrice,
                                                      'cartItemQuantity':widget.dishCardDetails.dishQuant
                                                    });
                                                  });

                                                  cartSum = cartSum +
                                                      widget.dishCardDetails
                                                          .dishQuant *
                                                          widget.dishCardDetails
                                                              .dishPrice;
                                                  cartTileOpacity = 0.0;
                                                });
                                              },
                                            );
                                          }
                                      )



                                    ],
                                  ),
                                ),
                              );
                            }
                        ),

                    ],
                  ),
                ),
              )
            ],
          ) ,
          ),
        onTap: (){
          setState(() {
            counterOpac=1;
            if(widget.onTapped==true){
              widget.onTapped=false;
            }
            else {
              Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).get().then((onValue){
                onValue.exists ?
                Container()
                    :
                Firestore.instance.collection("cartItems${formData['email']}").document(widget.dishCardDetails.dishTitle).setData({
                  'cartItemTitle':widget.dishCardDetails.dishTitle,
                  'cartItemPrice':widget.dishCardDetails.dishPrice,
                  'cartItemQuantity':widget.dishCardDetails.dishQuant
                });
              });
              widget.onTapped=true;
            }
          });
        },
      ),
    );
  }

}


List<MenuItems> menuItems=[];
class MenuItemDetails{
  final String menuItemTitle;
  final int menuItemPrice;
  final String menuItemType;
  int menuItemQuantity;
  MenuItemDetails.fromMap(Map<dynamic ,dynamic> map)
      : assert(map['menuItemTitle']!=null),
        assert(map['menuItemPrice']!=null),
        assert(map['menuItemType']!=null),
        menuItemTitle=map['menuItemTitle'],
        menuItemPrice=map['menuItemPrice'],
        menuItemType=map['menuItemType'],
        menuItemQuantity=map['menuItemQuantity'];
  MenuItemDetails.fromSnapshot(DocumentSnapshot snapshot):this.fromMap(snapshot.data);
}

class MenuItems extends StatefulWidget {
  MenuItemDetails menuItemDetails;
  MenuItems(this.menuItemDetails);
  bool onaddmenuitemtocart=false;
  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: Color.fromARGB(255,  254, 251, 240),
        elevation: 20.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left:20.0,top:8.0,right:8.0,bottom:8.0),
                child: Text(widget.menuItemDetails.menuItemTitle,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w600)),
              ),
            ),




            Expanded(
              child: Row(
                children: <Widget>[
                  if(widget.onaddmenuitemtocart==false)
                  Expanded(child:IconButton(icon:Icon(Icons.add_shopping_cart,color: Colors.black,),color: Colors.white,
                    onPressed:(){
                    setState(() {
                      Firestore.instance.collection('cartItems${formData['email']}').document(widget.menuItemDetails.menuItemTitle).setData(
                        {
                          'cartItemTitle':widget.menuItemDetails.menuItemTitle,
                          'cartItemQuantity':widget.menuItemDetails.menuItemQuantity,
                          'cartItemPrice':widget.menuItemDetails.menuItemPrice,
                        }
                      );
                      widget.onaddmenuitemtocart=true;

                    });

                    },)),

                  if(widget.onaddmenuitemtocart==true) StreamBuilder(
                      stream: Firestore.instance.collection("cartItems${formData['email']}").document(widget.menuItemDetails.menuItemTitle).snapshots(),
                      builder: (BuildContext context,snapshot) {
                        return !snapshot.hasData?Container(child: Padding(
                          padding: const EdgeInsets.only(top:30.0,left:35.0),
                          child: Center(child: Container(height:26,width:26,child:CircularProgressIndicator(strokeWidth:2,backgroundColor:Colors.white))),
                        ),)
                            : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Icon(Icons.do_not_disturb_on),
                                    ),
                                  ),
                                  onTap: (){
                                    setState(() {
                                      widget.menuItemDetails.menuItemQuantity=snapshot.data['cartItemQuantity'];
                                      if(widget.menuItemDetails.menuItemQuantity==1||widget.menuItemDetails.menuItemQuantity==0){
                                        widget.onaddmenuitemtocart=false;
                                        Firestore.instance.collection('cartItems${formData['email']}').document(widget.menuItemDetails.menuItemTitle).delete();
                                      }
                                      else if(widget.menuItemDetails.menuItemQuantity>0){
                                        widget.menuItemDetails.menuItemQuantity--;
                                        Firestore.instance.collection('cartItems${formData['email']}').document(widget.menuItemDetails.menuItemTitle).updateData({'cartItemQuantity':widget.menuItemDetails.menuItemQuantity});
                                      }
                                    });
                                  },
                                ),
                                Container(
                                       decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                        border: Border.all(color: Colors.black,width: 3.0)
                                    ),
                                    child:Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${snapshot.data["cartItemQuantity"]}',style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.042,fontWeight: FontWeight.w800),),
                                    )
                                ),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: Icon(Icons.add_circle),
                                    ),
                                  ),
                                  onTap:(){
                                    setState(() {
                                      widget.menuItemDetails.menuItemQuantity=snapshot.data['cartItemQuantity']+1;
                                      Firestore.instance
                                          .collection('cartItems${formData['email']}')
                                          .document(widget.menuItemDetails.menuItemTitle)
                                          .updateData({'cartItemQuantity':widget.menuItemDetails.menuItemQuantity});
                                    });
                                  },
                                ),

                              ],
                            ),
                          ),
                        );
                      }
                  ),


              ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right:20.0),
              child: Center(child: Text('Rs.${widget.menuItemDetails.menuItemPrice}',style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.042,fontWeight: FontWeight.w700))),
            )

          ],
        ),
      ),
    );
  }
}





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
  final db =FirebaseDatabase.instance.reference();
  String status,pin;
  @override
  void initState() {
    super.initState();
    updatefields();
  }
  void updatefields(){
    db.child("Allorders").child("${widget.orderCardDetails.orderid}").child("status").once().then((DataSnapshot snapshot) {
      setState(() {
        status=snapshot.value;
      });
    });
    db.child("Allorders").child("${widget.orderCardDetails.orderid}").child("pin").once().then((DataSnapshot snapshot) {
      setState(() {
        pin=snapshot.value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  
    List<OrderItems> items=[];
    for(int i=0;i<widget.orderCardDetails.orderItemslist.length;i++){
      items.add(OrderItems(widget.orderCardDetails.orderItemslist.elementAt(i)));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0,vertical: 6.0),
      child: GroovinExpansionTile(
        initiallyExpanded: false,
        boxDecoration: BoxDecoration(
          color: Color.fromARGB(255,  254, 251, 240),
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        backgroundColor: Color.fromARGB(255,  254, 251, 240),
        leading: widget.orderCardDetails.status=="Delivered"?
            Icon(Icons.check_circle,color: Colors.blue,size: 40.0,):widget.orderCardDetails.status=="Canceled"? Icon(Icons.close,color: Colors.red,size: 40.0,):Icon(Icons.play_circle_filled,color: Colors.green,size: 40.0,),
        title: Text("Orderid : ${widget.orderCardDetails.orderid}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.04),),
        children:<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Card(
              elevation: 6.0,
              color: Color.fromARGB(255,  254, 251, 240),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right:15.0,left:15.0,top:10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Deliver To:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.04))),

                        Expanded(child: Text("${widget.orderCardDetails.customername}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.04))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:15.0,vertical:1.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Delivery Address:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.04))),
                        Expanded(child: Text("${widget.orderCardDetails.address}",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.04))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:15.0,left:15.0,bottom:10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text("Placed On:",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w800,fontSize:MediaQuery.of(context).size.width*0.04))),
                        Expanded(child: Text("${widget.orderCardDetails.time.toDate().day}/${widget.orderCardDetails.time.toDate().month}/${widget.orderCardDetails.time.toDate().year} at ${widget.orderCardDetails.time.toDate().hour}:${widget.orderCardDetails.time.toDate().minute} hrs",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w600,fontSize:MediaQuery.of(context).size.width*0.04))),
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
            padding: const EdgeInsets.symmetric(horizontal:15.0,vertical:8.0),
            child: Text("For Queries Contact +919999292135",style: GoogleFonts.happyMonkey(color: Colors.black,fontWeight: FontWeight.w700,fontSize:MediaQuery.of(context).size.width*0.04),textAlign: TextAlign.center,),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Card(
              color: status=="Delivered"?Colors.green:status=="Dispatched"?Colors.deepOrangeAccent:status=="Canceled"?Colors.red:Colors.blue,
              elevation: 20.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left:20.0,top:8.0,right:8.0,bottom:8.0),
                      child: Text('Status : $status',style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700,color: Color.fromARGB(255,  254, 251, 240))),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.orderCardDetails.status!="Delivered" && widget.orderCardDetails.status!="Canceled")
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
            child: Card(
              color: Colors.deepPurpleAccent,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left:20.0,top:8.0,right:8.0,bottom:8.0),
                      child: Text('PIN : $pin',style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700,color: Color.fromARGB(255,  254, 251, 240))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.orderCardDetails.status!="Delivered" && widget.orderCardDetails.status!="Canceled")Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MaterialButton(
                  elevation: 10.0,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.cancel,color:Colors.red),
                      Text("Cancel",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.045,fontWeight: FontWeight.w600,color: Colors.red),),
                    ],
                  ),
                  onPressed: (){
                    setState(() {
                      status="Canceled";
                      Firestore.instance.collection('orders${orderData['email']}').document('${widget.orderCardDetails.orderid}').updateData({
                        'status':"Canceled"
                      });
                      Firestore.instance.collection('Allorders').document('${widget.orderCardDetails.orderid}').updateData({
                        'status':"Canceled"
                      }).then((value) => {
                        db.child("Allorders").child(widget.orderCardDetails.orderid).update(
                            {'status':"Canceled"})
                      });
                    });
                  },
                ),
              )
            ],
          )
        ],
        subtitle: Text("Grand Total: Rs ${widget.orderCardDetails.grandT}",style: GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight:FontWeight.w800),),
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
        color: Color.fromARGB(255,  254, 251, 240),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left:20.0,top:8.0,right:8.0,bottom:8.0),
                child: Text(widget.orderItemTitle,style:GoogleFonts.happyMonkey(fontSize:MediaQuery.of(context).size.width*0.04,fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

