import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:place_picker/place_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'mainScreen.dart';
import 'package:sharing_book/user.dart';

double perpage = 1;
List data;
File _image;
String pathAsset = 'assets/images/add.png';
String urlUpload = "https://ahmedbawazir.com/sharing_books/php/upload_book.php";
String urlgetuser = "https://ahmedbawazir.com/sharing_books/php/get_user.php";

TextEditingController _bookcontroller = TextEditingController();
final TextEditingController _desccontroller = TextEditingController();
final TextEditingController _borrecontroller = TextEditingController();
final TextEditingController _specontroller = TextEditingController();
final TextEditingController _yearcontroller = TextEditingController();
final TextEditingController _durtcontroller = TextEditingController();
final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
Position _currentPosition;
String _currentAddress = "Searching your current location...";

class NewBook extends StatefulWidget {
  final User user;
  const NewBook({Key key, this.user}) : super(key: key);

  @override
  _NewBookbState createState() => _NewBookbState();
}

class _NewBookbState extends State<NewBook> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          backgroundColor: Colors.lightBlueAccent[400],
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(
              'ADD BOOK',
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
  initUser() async {
    setState(() {});
  }

///////////new
  //////

  String defaultValue = 'Pickup';
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    ////
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: _choose,
            child: Container(
              width: 260,
              height: 180,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image:
                    _image == null ? AssetImage(pathAsset) : FileImage(_image),
                fit: BoxFit.fill,
              )),
            )),
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
            controller: _desccontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Description',
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
        TextField(
            controller: _durtcontroller,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.previous,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Durtion Loan',
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            )),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
            onTap: _loadmap,
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "Book Location",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            )),
        SizedBox(
          height: 0,
        ),
        Row(
          children: <Widget>[
            Icon(Icons.location_searching),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                _currentAddress,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10,
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minWidth: 300,
          height: 50,
          child: Text('Add Book'),
          color: Colors.blue,
          textColor: Colors.white,
          elevation: 15,
          onPressed: _onAddbook,
        ),
      ],
    );
  }

  void _choose() async {
    print("Ahdsdd");
    print(widget.user.email);
    //  _image =await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 400);
    setState(() {});
    // _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Take  profile picture?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Camera"),
                  onPressed: _getimage,
                ),
                new FlatButton(
                  child: new Text("Gallery"),
                  onPressed: _getimageg,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onAddbook() {
    if (_image == null) {
      Toast.show("Please enter book information ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    if (_bookcontroller.text.isEmpty) {
      Toast.show("Please enter book title", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    /* if (_borrecontroller.text.isEmpty) {
      Toast.show("Please enter book price", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }*/
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Adding...");
    pr.show();
    String base64Image = base64Encode(_image.readAsBytesSync());
    print(_currentPosition.latitude.toString() +
        "/" +
        _currentPosition.longitude.toString());

    http.post(urlUpload, body: {
      "encoded_string": base64Image,
      "email": widget.user.email,
      "phone": widget.user.phone,
      "inasis": widget.user.inasis,
      "name": widget.user.name,
      "booktitle": _bookcontroller.text,
      "bookdesc": _desccontroller.text,
      "bookborrow": _borrecontroller.text,
      "specialty": _specontroller.text,
      "yearofbook": _yearcontroller.text,
      "durtionloan": _durtcontroller.text,
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      //  "credit": widget.user.credit,
      // "rating": widget.user.inasis
    }).then((res) {
      print(urlUpload);

      ///  print("kjhkj");
      Toast.show(res.body, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      if (res.body.contains("success")) {
        _image = null;
        _bookcontroller.text = "";
        _borrecontroller.text = "";
        _desccontroller.text = "";
        _specontroller.text = "";
        _yearcontroller.text = "";
        _durtcontroller.text = "";
        pr.hide();
        print(widget.user.email);
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

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        // print(_getCurrentLocation);
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
      });
    } catch (e) {
      print(e);
    }
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

  void _loadmap() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAvIHhXiQ7TxWE2L7WY_qP2WpBDrR7TWHk")));

    // Handle the result in your way
    print("MAP SHOW:");
    print(result);
  }

  final picker = ImagePicker();
  Future _getimage() async {
    final image =
        await picker.getImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      _image = File(image.path);
      Navigator.of(context).pop();
    });
  }

  Future _getimageg() async {
    final image =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
    setState(() {
      _image = File(image.path);
      Navigator.of(context).pop();
    });
  }
}
