import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sharing_book/Request.dart';
import 'package:sharing_book/mainScreen.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'user.dart';

File _image;
String pathAsset = 'assets/images/add.png';
String urlUpload =
    "https://ahmedbawazir.com/sharing_books/php/uploadreqbooks.php";
String urlgetuser = "https://ahmedbawazir.com/sharing_books/php/get_user.php";

TextEditingController _bookcontroller = TextEditingController();
final TextEditingController _specontroller = TextEditingController();
final TextEditingController _yearcontroller = TextEditingController();
final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
Position _currentPosition;
String _currentAddress = "Searching your current location...";

class RequstBook extends StatefulWidget {
  final User user;

  const RequstBook({Key key, this.user, REQU requ}) : super(key: key);

  @override
  _RequstBookbState createState() => _RequstBookbState();
}

class _RequstBookbState extends State<RequstBook> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          backgroundColor: Colors.lightBlueAccent[400],
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              'ADD REQUST BOOKS',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: CreateNewBook(widget.user),
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

class CreateNewBook extends StatefulWidget {
  final User user;
  CreateNewBook(this.user);

  @override
  _CreateNewBookState createState() => _CreateNewBookState();
}

class _CreateNewBookState extends State<CreateNewBook> {
  String defaultValue = 'Pickup';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 100,
        ),
        Container(
          width: 550,
          height: 400,
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              TextField(
                  controller: _bookcontroller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: ' Title',
                    labelStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                    // icon: Icon(Icons.title),
                  )),
              TextField(
                  controller: _specontroller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    labelStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  )),
              TextField(
                  controller: _yearcontroller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.previous,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Year of Book',
                    labelStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  )),
              SizedBox(
                height: 25,
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                minWidth: 300,
                height: 50,
                child: Text('REQUST BOOKS'),
                color: Colors.blue,
                textColor: Colors.white,
                elevation: 15,
                onPressed: _onAddbook,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onAddbook() {
    if (_bookcontroller.text.isEmpty) {
      Toast.show("Please enter book title", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (_specontroller.text.isEmpty) {
      Toast.show("Please enter book price", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Adding...");
    pr.show();
    // String base64Image = base64Encode(_image.readAsBytesSync());
    /* print(_currentPosition.latitude.toString() +
        "/" +
        _currentPosition.longitude.toString());
*/
    http.post(urlUpload, body: {
      // "encoded_string": base64Image,
      "email": widget.user.email,
      "phone": widget.user.phone,
      "inasis": widget.user.inasis,
      "name": widget.user.name,
      "reqtitle": _bookcontroller.text,
      "reqspecialty": _specontroller.text,
      "reqyearofbook": _yearcontroller.text,
    }).then((res) {
      print(urlUpload);

      ///  print("kjhkj");
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      if (res.body.contains("success")) {
        _image = null;
        _bookcontroller.text = '';
        _specontroller.text = '';
        _yearcontroller.text = '';
        pr.hide();
        // print(widget.user.email);
        _onLogin(widget.user.email, context);
      } else {
        pr.hide();
        Toast.show(res.body + ". Please reload", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
      // print("BBBBBBBBBBBBBB");
    }).catchError((err) {
      print(err);
      pr.hide();
    });
  }

  void _onLogin(String email, BuildContext ctx) {
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
          // rating: dres[6]
        );
        Navigator.push(ctx,
            MaterialPageRoute(builder: (context) => MainScreen(user: user)));
      }
    }).catchError((err) {
      print(err);
    });
  }
}
