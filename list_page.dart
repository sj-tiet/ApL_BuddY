import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
//import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:whatsapp_unilink/whatsapp_unilink.dart';
// import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
//import 'package:qrpoints/screens/home_screen.dart';

class ListPage extends StatefulWidget {
  static const String id = 'list_page_id';
  final DocumentSnapshot userSnapshot;
  final DocumentSnapshot listTextSnapshot;
  ListPage({
    @required this.userSnapshot,
    @required this.listTextSnapshot,
  });

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  _callNumber(var num) async {
    var number = num; //set the number here
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  TextEditingController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inquiry / Orders',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'lemonmilk',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Text(
                  '${widget.listTextSnapshot.get('text')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextField(
                  minLines: 1,
                  maxLines: 25,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter: Inquiry / Orders',
                  ),
                ),
              ),

              //alignment: Alignment.center,

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                  onPressed: () async {
                    DocumentSnapshot numberSnap = await FirebaseFirestore
                        .instance
                        .collection('Numbers')
                        .doc('WhatsAppNumber')
                        .get();
                    await launch(
                        "https://wa.me/${numberSnap['number']}?text= Sent by: ${widget.userSnapshot['name']} \n ${_controller.text} \n via Apl Buddy");
                  },
                  // child: Text('Open Whatsapp'),

                  // {
                  //   launchWhatsApp() async {
                  //     //print(_controller.text);
                  //     DocumentSnapshot numberSnap = await FirebaseFirestore
                  //         .instance
                  //         .collection('Numbers')
                  //         .doc('WhatsAppNumber')
                  //         .get();
                  //     // print("By: ${widget.userSnapshot['name']} \n ${_controller.text} \n via Apl Buddy");
                  //     final link = WhatsAppUnilink(
                  //       phoneNumber: numberSnap['number'],
                  //       text:
                  //           "By: ${widget.userSnapshot['name']} \n ${_controller.text} \n via Apl Buddy",
                  //     );
                  //    launch('$link');
                  //     // FlutterOpenWhatsapp.sendSingleMessage(numberSnap['number'],
                  //     //     "By: ${widget.userSnapshot['name']} \n ${_controller.text} \n via Apl Buddy");
                  //   }
                  // },
                  child: Text('WhatsApp'),
                ),
                // Icon(
                //   Icons.message_sharp,
                //   size: 25,
                // )
              ]),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   width: 10,
                  // ),
                  ElevatedButton(
                      onPressed: () async {
                        DocumentSnapshot callNumberSnap =
                            await FirebaseFirestore.instance
                                .collection('Numbers')
                                .doc('OrderCallingNumber')
                                .get();
                        _callNumber(callNumberSnap['number']);
                      },
                      child: Text('Call')),
                  // Icon(
                  //   Icons.call,
                  //   size: 25,
                  //   color: Colors.black54,
                  // ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Image(
                  image: AssetImage('images/saksham1.png'),
                ),
              ),

              Text(
                "Kapurthala road Nakodar-144040",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 100,
              ),
            ]),
      ),
    );
    //   body: StreamBuilder(
    //     stream: FirebaseFirestore.instance.collection('List').snapshots(),
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData)
    //         return Center(
    //           child: CircularProgressIndicator(),
    //         );
    //       return ListView.builder(
    //         itemCount: snapshot.data.docs.length,
    //         itemBuilder: (context, index) =>
    //             _buildListTiles(context, snapshot.data.docs[index]),
    //       );
    //     },
    //   ),
    // );
  }
}
