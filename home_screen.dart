import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:page_view_indicators/circle_page_indicator.dart';
//import 'package:flutter/services.dart';
//import 'package:qrpoints/Components/mainPhotoDisplay.dart';
import 'package:qrpoints/Components/myAlertDialogue.dart';
import 'package:qrpoints/screens/business_page.dart';
import 'package:qrpoints/screens/history_page.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:qrpoints/screens/list_page.dart';
import 'package:qrpoints/screens/settings_page.dart';
import 'package:qrpoints/screens/wallet_page.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:dots_indicator/dots_indicator.dart';
// import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:qrpoints/screens/workPlace.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final DocumentReference userRef;
  static const String id = 'HomeScreen_id';
  //final QuerySnapshot photoDocSnap;

  HomeScreen({
    @required this.userRef,
    //@required this.photoDocSnap,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController =
      PageController(initialPage: 1, viewportFraction: 0.9);

  dynamic data;
  DocumentSnapshot userSnapshot;
  DocumentSnapshot settingNumberSnapshot;
  DocumentSnapshot settingTextSnapshot;
  DocumentSnapshot listTextSnapshot;
  Future _scan() async {
    String qrResult = await BarcodeScanner.scan();
    if (qrResult == null) {
      print('nothing return.');
    } else {
      return qrResult;
    }
  }

  Future<dynamic> getData() async {
    userSnapshot = await widget.userRef.get();
    settingNumberSnapshot = await FirebaseFirestore.instance
        .collection('Numbers')
        .doc('SettingNumber')
        .get();
    settingTextSnapshot = await FirebaseFirestore.instance
        .collection('Texts')
        .doc('SettingText')
        .get();
    listTextSnapshot = await FirebaseFirestore.instance
        .collection('Texts')
        .doc('ListText')
        .get();

    final DocumentReference document = widget.userRef;

    await document.get().then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        data = snapshot.data();
        print(snapshot.data().toString());
      });
    });
  }

  Future<bool> _checkQR(DocumentSnapshot qrSnapshot) async {
    if (qrSnapshot.exists)
      return Future<bool>.value(true);
    else
      return Future<bool>.value(false);
  }

  Future<void> _updatePoints(var newPoints) async {
    await widget.userRef.update({
      'unapprovedPoints': newPoints,
    });
  }

  Future<int> length;
  _getPhotoLength() {
    setState(() {
      length = FirebaseFirestore.instance
          .collection('Photos')
          .doc()
          .snapshots()
          .length;
    });
  }

  // _buildCircleIndicator2() {
  //   return CirclePageIndicator(
  //     size: 9.0,
  //     selectedSize: 12.0,
  //     itemCount: 3,
  //     currentPageNotifier: _currentPageNotifier,
  //   );
  // }

  @override
  void initState() {
    super.initState();
    //Navigator.pushNamed(context, LoadingSplashScreen.id);
    getData();
    _getPhotoLength();
  }

  // final _pageController = PageController();
  // final _currentPageNotifier = ValueNotifier<int>(0);
  final _carousalController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Image(
            //   image: AssetImage('images/brickk.jpg'),
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   fit: BoxFit.cover,
            // ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: size.width,
                height: 80,
                child: Stack(
                  //overflow: Overflow.visible,
                  children: [
                    CustomPaint(
                      size: Size(size.width, 80),
                      painter: BNBCustomPainter(),
                    ),
                    Center(
                      heightFactor: 0.6,
                      child: FloatingActionButton(
                        backgroundColor: Colors.red,
                        child: Text(
                          "Product Guide",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        elevation: 0.1,
                        onPressed: () {
                          Navigator.pushNamed(context, BusinessPage.id);
                        },
                      ),
                    ),
                    Container(
                      width: size.width,
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.qr_code_scanner,
                                      size: 30, color: Colors.white),
                                  onPressed: () async {
                                    if (userSnapshot.get('flag') != 0) {
                                      String scanString = 'null';
                                      print(scanString);
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Choose'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                var rest = await _scan();
                                                setState(() {
                                                  scanString = rest;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('Scan'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                var image = await ImagePicker()
                                                    .getImage(
                                                        source: ImageSource
                                                            .gallery);
                                                if (image == null) return;
                                                final rest =
                                                    await FlutterQrReader
                                                        .imgScan(image.path);
                                                setState(() {
                                                  scanString = rest;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text('Gallery'),
                                            ),
                                          ],
                                        ),
                                      );
                                      print(scanString);
                                      DocumentReference qrRef =
                                          FirebaseFirestore.instance
                                              .collection('QRS')
                                              .doc(scanString);
                                      DocumentSnapshot qrSnap =
                                          await qrRef.get();
                                      //gayab
                                      bool resultOfCheck =
                                          await _checkQR(qrSnap);
                                      print(resultOfCheck);
                                      if (resultOfCheck) {
                                        var newUnapprovedPoints = userSnapshot
                                                .get('unapprovedPoints') +
                                            qrSnap.get('point');
                                        await _updatePoints(
                                            newUnapprovedPoints);
                                        print('error1');
                                        //taking description
                                        userSnapshot.reference
                                            .collection('descriptions')
                                            .doc()
                                            .set({
                                          'description':
                                              qrSnap.get('description'),
                                          'points': qrSnap.get('point'),
                                          'pointsPresent': true,
                                          'timeStamp': Timestamp.now(),
                                        });

                                        //removing
                                        qrRef.delete();
                                        print('removed');
                                        await getData();
                                        print(userSnapshot.get('points'));
                                        setState(() {
                                          data['points'];
                                        });
                                        //deleted
                                        showDialog(
                                          context: context,
                                          builder: (context) => MyAlertDialogue(
                                              'Your points will be updated shortly'),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              MyAlertDialogue('QR not present'),
                                        );
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => MyAlertDialogue(
                                            'You are not a contractor'),
                                      );
                                    }
                                  },
                                  splashColor: Colors.white,
                                ),
                                Text(
                                  "Scanner",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.wallet_giftcard_sharp,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    getData();
                                    if (userSnapshot.get('flag') != 0) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WalletPage(
                                              userSnapshot: userSnapshot),
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (context) => MyAlertDialogue(
                                            'You are not a contractor'),
                                      );
                                    }
                                  },
                                ),
                                Text(
                                  "Wallet",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                          Container(
                            width: size.width * 0.20,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.history_sharp,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  onPressed: () {
                                    //if (userSnapshot.get('flag') != 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryPage(
                                            userSnapshot: userSnapshot),
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  "History",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  color: Colors.white,
                                  iconSize: 30,
                                  icon: Icon(
                                    Icons.local_post_office_outlined,
                                  ),
                                  onPressed: () {
                                    getData();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListPage(
                                          userSnapshot: userSnapshot,
                                          listTextSnapshot: listTextSnapshot,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  "Help",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black,
                      //     blurRadius: 2.0,
                      //     spreadRadius: 2.0,
                      //     offset: Offset(
                      //         5.0, 5.0), // shadow direction: bottom right
                      //   )
                      // ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 100.0, bottom: 40.0),
                          child: Center(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingsPage(
                                    settingNumberSnapshot:
                                        settingNumberSnapshot,
                                    settingTextSnapshot: settingTextSnapshot,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "ApL BuddY",
                              style: TextStyle(
                                color: Colors.white,
                                //fontStyle: FontStyle.normal,
                                //fontFamily: 'lemonmilk',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          )),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 18,
                            ),
                            // IconButton(
                            //   color: Colors.white,
                            //   iconSize: 30,
                            //   icon: Icon(Icons.message),
                            //   onPressed: () {
                            //     getData();
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => ListPage(
                            //           userSnapshot: userSnapshot,
                            //           listTextSnapshot: listTextSnapshot,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            // ),
                            IconButton(
                                icon: Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsPage(
                                        settingNumberSnapshot:
                                            settingNumberSnapshot,
                                        settingTextSnapshot:
                                            settingTextSnapshot,
                                      ),
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, right: 4.0, left: 4.0, bottom: 8.0),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Photos')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        else {
                          final List<DocumentSnapshot> documents =
                              snapshot.data.docs;
                          return CarouselSlider(
                            // onPageChanged: (int index) {
                            //   _currentPageNotifier.value = index;
                            // },
                            // controller: _pageController,
                            carouselController: _carousalController,
                            options: CarouselOptions(
                              //height: 400,
                              aspectRatio: 16 / 9,
                              viewportFraction: 0.7,
                              initialPage: 1,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: Duration(milliseconds: 5000),
                              autoPlayAnimationDuration:
                                  Duration(milliseconds: 950),
                              autoPlayCurve: Curves.easeIn,
                              enlargeCenterPage: true,
                              scrollDirection: Axis.horizontal,
                            ),
                            items: documents
                                .map((doc) => Padding(
                                      padding: EdgeInsets.only(
                                          top: 12.0,
                                          right: 5.0,
                                          left: 5.0,
                                          bottom: 12.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          String url = doc['url'];
                                          await launch(url);

                                          // if (await canLaunch(url)) {
                                          //   await launch(url);
                                          // } else {
                                          //   throw 'Could not launch $url';
                                          // }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Colors.transparent
                                                .withOpacity(0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black54,
                                                offset: const Offset(
                                                  4.0,
                                                  4.0,
                                                ),
                                                blurRadius: 6.0,
                                                spreadRadius: 1.5,
                                              ), //BoxShadow
                                              BoxShadow(
                                                color: Colors.white,
                                                offset: const Offset(0.0, 0.0),
                                                blurRadius: 0.0,
                                                spreadRadius: 0.0,
                                              ), //BoxShadow
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.network(
                                              doc['link'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                // _buildCircleIndicator2(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 120.0, top: 5.0, left: 10, right: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, WorkPlace.id);
                      },
                      child: Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              offset: const Offset(
                                5.0,
                                5.0,
                              ),
                              blurRadius: 10.0,
                              spreadRadius: 3.0,
                            ), //BoxShadow
                            BoxShadow(
                              color: Colors.lime.shade800,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: Image(
                          image: AssetImage('images/saksham1.png'),
                        ),
                      ),
                    ),
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

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height);

    path.quadraticBezierTo(
        size.width / 500, size.height - 80, size.width / 2, size.height - 30);
    path.quadraticBezierTo(
        3 / 4 * size.width + 20, size.height, size.width, size.height);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
