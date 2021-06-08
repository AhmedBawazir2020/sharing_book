import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;

import 'accept_book.dart';
import 'book.dart';
import 'slide_right_route.dart';
import 'user.dart';

double perpage = 1;

class TabScreen1 extends StatefulWidget {
  final User user;

  TabScreen1({Key key, this.user});

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen1> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  TextEditingController editingController = TextEditingController();

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
              elevation: 5.0, //shadow
              backgroundColor: Colors.lightBlue[600],
              title: Text('MENU BOOKS'),
              actions: <Widget>[
                // IconButton(
                //   icon: Icon(
                //     Icons.search,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {
                //     showSearch(context: context, delegate: DataSearch());
                //   },
                // ),
              ],
            ),
            body: RefreshIndicator(
              key: refreshKey,
              color: Colors.blue,
              onRefresh: () async {
                await refreshList();
              },
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: editingController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      //labelText: "Search",

                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  Expanded(
                      child: Center(
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
                                          height: 0,
                                        ),

                                        SizedBox(height: 0),
                                        /////
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
                                    widget.user.name,
                                    widget.user.inasis),
                                onLongPress: _onBookDelete,
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
                                                  color:
                                                      const Color(0xFF616161)),
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  data[index]['yearofbook']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "" +
                                                    data[index]
                                                        ['bookdurtionloan'],
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
                  ))
                ],
              ),
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
    String _onBookDetail =
        "https://ahmedbawazir.com/sharing_books/php/load_books.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading Books");
    pr.show();
    http.post(_onBookDetail, body: {
      "email": widget.user.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      "radius": widget.user.radius ?? "10",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["books"];
        perpage = (data.length / 1000);
        print("data");
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
    this.makeRequest();
    //_getCurrentLocation();
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
      String phone,
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
        SlideRightRoute(page: Acceptbook(book: book, user: widget.user)));
  }

  void _onBookDelete() {
    print("Delete");
  }
}

//////

//////

final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
Position _currentPosition;
String _currentAddress = "Searching current location...";

class DataSearch extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    // icon Action
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //icon leading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String selectedResult = "";

  @override
  Widget buildResults(BuildContext context) {
    // Result Search
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  /*  List<String> listExample;
  DataSearch(this.listExample);

  List booklist; */

  @override
  Widget buildSuggestions(BuildContext context) {
    //TODO: implement buildSuggestions

    List<String> sugdata = [];
    // query.isEmpty
    //     ? sugdata = booklist
    //     : sugdata.addAll(booklist.where((element) => element.contains(query)));

    return ListView.builder(

        //Step 6: Count the data
        itemCount: sugdata == null ? 1 : sugdata.length + 1,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(sugdata[index]),
            onTap: () {
              selectedResult = sugdata[index];

              showResults(context);
            },
          );
        });
  }
/*
  Future<String> makeRequest() async {
    String _onBookDetail2 =
        "https://ahmedbawazir.com/sharing_books/php/load_books.php";
    // ProgressDialog pr = new ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false);
    // pr.style(message: "Loading Books");
    // pr.show();
    http.post(_onBookDetail2, body: {
      // "email": widget.user.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      // "radius": widget.user.radius ?? "10",
    }).then((res) {
      // setState(() {
      //   var extractdata = json.decode(res.body);
      //   booklist = extractdata["books"];
      //   perpage = (booklist.length / 10);
      //   print("data");
      //   print(booklist);
      //  // pr.hide();
      // });
    }).catchError((err) {
      print(err);
      // pr.hide();
    });
    return null;
  }

  Future init() async {
    this.makeRequest();
    //_getCurrentLocation();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }*/
}
