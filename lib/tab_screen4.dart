import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sharing_book/Request.dart';
import 'package:sharing_book/requestbooks.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';

//import 'details_book.dart';

//import 'slide_right_route.dart';
import 'user.dart';

double perpage = 1;
int number = 0;

class TabScreen4 extends StatefulWidget {
  final User user;

  TabScreen4({Key key, this.user});

  @override
  _TabScreen4State createState() => _TabScreen4State();
}

class _TabScreen4State extends State<TabScreen4> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data;

  @override
  void initState() {
    super.initState();
    //init();
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
              elevation: 8.5, //shadow
              backgroundColor: Colors.lightBlue[600],
              title: Text('REQUEST BOOKS'),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.blue[700],
              elevation: 2.0,
              onPressed: requestNewBook,
              tooltip: 'Request New Book Now',
            ),
            body: RefreshIndicator(
              key: refreshKey,
              color: Colors.blue,
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
                              //
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 5,
                                  ),

                                  ///
                                ],
                              ),
                            ]),
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
                                top: Radius.circular(15),
                                bottom: Radius.circular(15))),
                        elevation: 5,
                        child: InkWell(
                          ///////////////////////////////////////
                          onTap: () => _onBookDetail(
                              data[index]['reqbookid'],
                              data[index]['reqbooktitle'],
                              data[index]['reqemail'],
                              data[index]['reqphone'],
                              data[index]['reqnameowner'],
                              data[index]['reqinasisowner'],
                              data[index]['reqbooktime'],
                              data[index]['reqbookspecialty'],
                              data[index]['reqyearofbook'],
                              widget.user.name,
                              widget.user.name,
                              widget.user.inasis),
                          /////////////////////////////////////////
                          onLongPress: () => _onBookDelete(
                              data[index]['reqbookid'].toString(),
                              data[index]['reqbooktitle'].toString()),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    height: 115,
                                    width: 97,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            width: 3.0,
                                            color: const Color(0xFF616161)),
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: new NetworkImage(
                                                "https://ahmedbawazir.com/sharing_books/profile/${data[index]['reqemail']}.jpg?dummy=${(number)}'")))),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "Title:  " +
                                                data[index]['reqbooktitle']
                                                    .toString()
                                                    .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Specialty:  " +
                                              data[index]['reqbookspecialty'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Year  :  " +
                                              data[index]['reqyearofbook'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Name  :  " + data[index]['reqphone'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Phone  :  " +
                                              data[index]['reqnameowner'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
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

  void requestNewBook() {
    print(widget.user.email);
    if (widget.user.email != "user@noregister") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  RequstBook(user: widget.user)));
    } else {
      Toast.show("Please Register First to request new books", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      //RegisterScreen
    }
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
        "https://ahmedbawazir.com/sharing_books/php/load_requste_book.php";
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
        data = extractdata["request"];
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
      Toast.show("Please register to view posted books", context,
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

  void _onBookDelete(String bookid, String bookname) {
    print("Delete " + bookid);
    _showDialog(bookid, bookname);
  }

  void _showDialog(String bookid, String bookname) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Delete " + bookname,
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new Text(
            "Are your sure?",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteRequest(bookid);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> deleteRequest(String reqbookid) async {
    String urlLoadBooks =
        "https://ahmedbawazir.com/sharing_books/php/delete_requste_book.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting Books");
    pr.show();
    http.post(urlLoadBooks, body: {
      "reqbookid": reqbookid,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        init();
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
      pr.hide();
    });
    return null;
  }

  /////////////////
  void _onBookDetail(
      String reqbookid,
      String reqbooktitle,
      String reqemail,
      String reqphone,
      String reqnameowner,
      String reqinasisowner,
      String reqbooktime,
      String reqbookspecialty,
      String reqyearofbook,
      String email,
      String name,
      String inasis) {
    REQU requ = new REQU(
      reqbookid: reqbookid,
      reqbooktitle: reqbooktitle,
      reqemail: reqemail,
      reqphone: reqphone,
      reqemailowner: reqnameowner,
      reqinasisowner: reqinasisowner,
      reqbooktime: reqbooktime,
      reqbookspecialty: reqbookspecialty,
      reqyearofbook: reqyearofbook,
    );
    //print(data);
/*
    Navigator.push(context,
        SlideRightRoute(page: EditBook(book: book, user: widget.user)));*/
  }
//////////////////////
}

class SlideMenu extends StatefulWidget {
  final Widget child;
  final List<Widget> menuItems;

  SlideMenu({this.child, this.menuItems});

  @override
  _SlideMenuState createState() => new _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = new Tween(
            begin: const Offset(0.0, 0.0), end: const Offset(-0.2, 0.0))
        .animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        // we can access context.size here
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500)
          _controller
              .animateTo(.0); //close menu on fast swipe in the right direction
        else if (_controller.value >= .5 ||
            data.primaryVelocity <
                -2500) // fully open if dragged a lot to left or on fast swipe to left
          _controller.animateTo(1.0);
        else // close if none of above
          _controller.animateTo(.0);
      },
      child: new Stack(
        children: <Widget>[
          new SlideTransition(position: animation, child: widget.child),
          new Positioned.fill(
            child: new LayoutBuilder(
              builder: (context, constraint) {
                return new AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return new Stack(
                      children: <Widget>[
                        new Positioned(
                          right: .0,
                          top: .0,
                          bottom: .0,
                          width: constraint.maxWidth * animation.value.dx * -1,
                          child: new Container(
                            color: Colors.black26,
                            child: new Row(
                              children: widget.menuItems.map((child) {
                                return new Expanded(
                                  child: child,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
