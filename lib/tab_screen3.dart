import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sharing_book/mainScreen.dart';
import 'package:sharing_book/retuerbook.dart';
import 'package:sharing_book/slide_right_route.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import 'book.dart';
//import 'receipt_book.dart';
//import 'slide_right_route.dart';
import 'user.dart';

double perpage = 1;

class TabScreen3 extends StatefulWidget {
  final User user;
  final BOOK book;
  TabScreen3({Key key, this.user, this.book});

  @override
  _TabScreen3State createState() => _TabScreen3State();
}

class _TabScreen3State extends State<TabScreen3> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data;

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.lightBlueAccent[400],
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              elevation: 8.5, //shadow///
              backgroundColor: Colors.lightBlue[600],
              title: Text('MY BORROWS'),
            ),
            body: RefreshIndicator(
              key: refreshKey,
              onRefresh: () async {
                await refreshList();
              },
              child: ListView.builder(
                  //Step 6: Count the data
                  itemCount: data == null ? 1 : data.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Stack(children: <Widget>[
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ]),
                            SizedBox(
                              height: 1.5,
                            ),
                          ],
                        ),
                      );
                    }
                    if (index == data.length && perpage > 1) {
                      return Container(
                        width: 250,
                        color: Colors.white,
                        child: MaterialButton(
                          child: Text(
                            "Load More",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {},
                        ),
                      );
                    }
                    index -= 1;
                    return Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Card(
                        color: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                            //edge
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(30),
                                bottom: Radius.circular(30))),
                        elevation: 5,
                        child: InkWell(
                          onTap: () => _onBookDetail(
                              data[index]['bookid'],
                              data[index]['booktitle'],
                              data[index]['bookowner'],
                              data[index]['phoneowner'],
                              data[index]['nameowner'],
                              data[index]['inasisowner'],
                              data[index]['bookdesc'],
                              data[index]['booktime'],
                              data[index]['bookimage'],
                              data[index]['booklatitude'],
                              data[index]['booklongitude'],
                              data[index]['bookspecialty'],
                              data[index]['yearofbook'],
                              data[index]['bookdurtionloan'],
                              widget.user.radius,
                              widget.user.name,
                              widget.user.inasis),
                          onLongPress: () => _onBookReturn(
                              data[index]['bookid'].toString(),
                              data[index]['booktitle'].toString()),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 3.0,
                                            color: const Color(0xFF616161)),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                "https://ahmedbawazir.com/sharing_books/images/${data[index]['bookimage']}.jpg")))),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            data[index]['booktitle']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "" + data[index]['nameowner'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          data[index]['phoneowner'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Clike to moer deteles...",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )));
  }

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition);
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name},${place.locality}, ${place.postalCode}, ${place.country}";
        init(); //load data from database into list array 'data'
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> makeRequest() async {
    String urlLoadBooks =
        "https://ahmedbawazir.com/sharing_books/php/load_accepted_books.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false); //progress
    pr.style(
      message: "Loading All Posted Books",
    );
    pr.show();
    http.post(urlLoadBooks, body: {
      "email": widget.user.email ?? "notavail",
    }).then((res) {
      // print(res.body);
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["books"];
        perpage = (data.length / 1000);
        print("data"); //////////////////
        print(data);
        pr.hide();
      });
    }).catchError((err) {
      print(err);
      pr.hide();
    });
    return null;
  }

  Future init() async {
    if (widget.user.email == "user@noregister") {
      Toast.show("Please register to view accepted books", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } else {
      this.makeRequest();
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  void _onBookDetail(
      String bookid,
      String bookdesc,
      String bookowner,
      String phoneowner,
      String nameowner,
      String inasisowner,
      String bookimage,
      String booktime,
      String booktitle,
      String booklatitude,
      String booklongitude,
      String bookspecialty,
      String yearofbook,
      String bookdurtionloan,
      String email,
      String name,
      String inasis) {
    BOOK book = new BOOK(
        bookid: bookid,
        booktitle: booktitle,
        bookowner: bookowner,
        nameowner: nameowner,
        inasisowner: inasisowner,
        bookdesc: bookdesc,
        phoneowner: phoneowner,
        booktime: booktime,
        bookimage: bookimage,
        bookporrow: null,
        booklatitude: booklatitude,
        booklongitude: booklongitude,
        bookspecialty: bookspecialty,
        yearofbook: yearofbook,
        bookdurtionloan: bookdurtionloan);
    //print(data);

    Navigator.push(context,
        SlideRightRoute(page: Returnbook(book: book, user: widget.user)));
  }

  void _onBookReturn(String bookid, String bookname) {
    print("Delete " + bookid);
    // _showDialog(bookid, bookname);
  }

  // void _showDialog(String bookid, String bookname) {
  //   // flutter defined function
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // return object of type Dialog
  //       return AlertDialog(
  //         title: new Text(
  //           "Return " + bookname,
  //           style: TextStyle(
  //             fontStyle: FontStyle.italic,
  //           ),
  //         ),
  //         content: new Text(
  //           "Are your sure?",
  //           style: TextStyle(
  //             fontStyle: FontStyle.italic,
  //           ),
  //         ),
  //         actions: <Widget>[
  //           // usually buttons at the bottom of the dialog
  //           new FlatButton(
  //             child: new Text(
  //               "Yes",
  //               style: TextStyle(
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //             onPressed: () {},
  //           ),
  //           new FlatButton(
  //             child: new Text(
  //               "No",
  //               style: TextStyle(
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

}
