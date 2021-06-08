import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sharing_book/slide_right_route.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';

//import 'details_book.dart';
import 'book.dart';
import 'newbook.dart';
//import 'slide_right_route.dart';
import 'user.dart';

double perpage = 1;

class TabScreen2 extends StatefulWidget {
  final User user;

  TabScreen2({Key key, this.user});

  @override
  _TabScreen2State createState() => _TabScreen2State();
}

class _TabScreen2State extends State<TabScreen2> {
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
              title: Text('MY BOOKS'),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.blue[700],
              elevation: 2.0,
              onPressed: requestNewBook,
              tooltip: 'Add New Now',
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
                                top: Radius.circular(30),
                                bottom: Radius.circular(30))),
                        elevation: 5,
                        child: InkWell(
                          ///////////////////////////////////////
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
                            widget.user.inasis,
                          ),
                          /////////////////////////////////////////
                          onLongPress: () => _onBookDelete(
                              data[index]['bookid'].toString(),
                              data[index]['booktitle'].toString()),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
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
                                          "" + data[index]['bookdurtionloan'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          data[index]['booktime'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Text(
                                          data[index]['yearofbook'],
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
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
        "https://ahmedbawazir.com/sharing_books/php/load_book_user.php";
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
        perpage = (data.length / data.length);
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

  void requestNewBook() {
    print(widget.user.email);
    if (widget.user.email != "user@noregister") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => NewBook(user: widget.user)));
    } else {
      Toast.show("Please Register First to request new books", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      //RegisterScreen
    }
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

  Future<String> deleteRequest(String bookid) async {
    String urlLoadBooks =
        "https://ahmedbawazir.com/sharing_books/php/delete_book.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Deleting Books");
    pr.show();
    http.post(urlLoadBooks, body: {
      "bookid": bookid,
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

/*     Navigator.push(context, SlideRightRoute(page: NewBook(user: widget.user)));
 */
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
