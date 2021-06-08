import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharing_book/mainScreen.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'book.dart';
import 'mainScreen.dart';
import 'user.dart';

class Returnbook extends StatefulWidget {
  final BOOK book;
  final User user;

  const Returnbook({Key key, this.book, this.user}) : super(key: key);

  @override
  _Returntbook createState() => _Returntbook();
}

class _Returntbook extends State<Returnbook> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('RETURN BOOK'),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: AcceptInterface(
                book: widget.book,
                user: widget.user,
              ),
            ),
          )),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(
            user: widget.user,
          ),
        ));
    return Future.value(false);
  }
}

class AcceptInterface extends StatefulWidget {
  final BOOK book;
  final User user;
  AcceptInterface({this.book, this.user});

  @override
  _AcceptInterfaceState createState() => _AcceptInterfaceState();
}

class _AcceptInterfaceState extends State<AcceptInterface> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;

  @override
  void initState() {
    super.initState();
    _myLocation = CameraPosition(
      target: LatLng(double.parse(widget.book.booklatitude),
          double.parse(widget.book.booklongitude)),
      zoom: 17,
    );
    print(_myLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(),
        Container(
          width: 300,
          height: 200,
          child: Image.network(
              'https://ahmedbawazir.com/sharing_books/images/${widget.book.booktitle}.jpg',
              fit: BoxFit.fill),
        ),
        SizedBox(
          height: 10,
        ),
        Text(widget.book.bookdesc.toString().toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Table(children: [
                TableRow(children: [
                  Text("Owner Name",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.nameowner,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Owner Email",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.bookowner,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Owner Phone",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.phoneowner,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Owner Inasis",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.inasisowner,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Book Durtion Lona",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.bookdurtionloan,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Year of Book",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.yearofbook,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Book Description",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.book.bookimage,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]),
                TableRow(children: [
                  Text("Book Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("")
                ]),
              ]),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 180,
                width: 340,
                child: GoogleMap(
                  // 2
                  initialCameraPosition: _myLocation,
                  // 3
                  mapType: MapType.hybrid,
                  // 4

                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  height: 40,
                  child: Text(
                    'RETURN BOOK',
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.blue,
                  textColor: Colors.white,
                  elevation: 5,
                  onPressed: _onAcceptBook,
                ),
                //MapSample(),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _onAcceptBook() {
    _showDialog();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Return The " + widget.book.bookdesc?.toUpperCase() + " Book",
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
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                acceptRequest();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> acceptRequest() async {
    String urlLoadBooks =
        "https://ahmedbawazir.com/sharing_books/php/returnbook.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Returning Book");
    pr.show();
    http.post(urlLoadBooks, body: {
      "bookid": widget.book.bookid,
      "email": widget.user.email,
      "phone": widget.user.phone,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.hide();
        _onLogin(widget.user.email, context);
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.hide();
      }
    }).catchError((err) {
      print(err);
      pr.hide();
    });
    return null;
  }

  void _onLogin(String email, BuildContext ctx) {
    String urlgetuser =
        "https://ahmedbawazir.com/sharing_books/php/get_user.php";

    http.post(urlgetuser, body: {
      "email": email,
    }).then((res) {
      print(res.statusCode);
      var string = res.body;
      List dres = string.split(",");
      print(dres);
      if (dres[0] == "success") {
        User user = new User(
          name: dres[1],
          email: dres[2],
          phone: dres[3],
          radius: dres[4],
          inasis: dres[5],
          //rating: dres[6]
        );
        Navigator.push(ctx,
            MaterialPageRoute(builder: (context) => MainScreen(user: user)));
      }
    }).catchError((err) {
      print(err);
    });
  }
}
