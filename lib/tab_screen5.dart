import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';
import 'registation.dart';
import 'user.dart';

String urlgetuser = "https://ahmedbawazir.com/sharing_books/php/get_user.php";
String urluploadImage =
    "https://ahmedbawazir.com/sharing_books/php/upload_imageprofile.php";
String urlupdate =
    "https://ahmedbawazir.com/sharing_books/php/update_profile.php";
File _image;
int number = 0;
final picker = ImagePicker();

class TabScreen5 extends StatefulWidget {
  //final String email;
  final User user;

  TabScreen5({this.user});
  static double sliderHeight = 330;
  @override
  _TabScreen5State createState() => _TabScreen5State();
}

class _TabScreen5State extends State<TabScreen5> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";

  @override
  void initState() {
    super.initState();

    /// refreshKey = GlobalKey<RefreshIndicatorState>();
    setState(() {
      refreshKey = GlobalKey<RefreshIndicatorState>();
      _getCurrentLocation();
    });
    //_getCurrentLocation();
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
          appBar: AppBar(),
          drawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: TabScreen5.sliderHeight,
                  child: DrawerHeader(
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: _takePicture,
                              child: Container(
                                  width: 150.0,
                                  height: 150.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: new NetworkImage(
                                              "https://ahmedbawazir.com/sharing_books/profile/${widget.user.email}.jpg?dummy=${(number)}'")))),
                            ),
                            SizedBox(height: 5),
                            Row(children: <Widget>[
                              Icon(
                                Icons.person,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  widget.user.name?.toUpperCase(),
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Icon(
                                Icons.email,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(
                                  widget.user.email,
                                  style: TextStyle(
                                    //fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ]),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.phone_android,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.user.phone ?? 'not registered',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.home,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Your Inasis " +
                                            widget.user.inasis?.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                          //    backgroundColor: Colors.black45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    "CHANGE NAME",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _changeName();
                    // ...
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text(
                    "CHANGE PASSWORD",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _changePassword(); // ...
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(
                    "CHANGE PHONE",
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.blue[20]),
                  ),
                  onTap: () {
                    _changePhone();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.room),
                  title: Text(
                    "CHANGE RADIUS",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _changeRadius(); // ...
                  },
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text(
                    "CHANGE INASIS",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _changeInasis();
                    // ...
                  },
                ),
                ListTile(
                  leading: Icon(Icons.input),
                  title: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _registerAccount();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.subdirectory_arrow_right),
                  title: Text(
                    "LOG IN",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _gotologinPage();
                    // ...
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.subdirectory_arrow_left,
                    color: Colors.red,
                  ),
                  title: Text(
                    "LOG OUT",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  onTap: () {
                    _gotologout();
                    // ...
                  },
                ),
              ],
            ),
          ),
          body: ListView.builder(
              //Step 6: Count the data
              itemCount: 5,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Stack(children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Text("Sharing Books",
                                    style: TextStyle(
                                        fontSize: 35,
                                        fontStyle: FontStyle.italic,
                                        //     backgroundColor: Colors.black45,////color of back ground the text
                                        color: Colors.lightBlue[100])),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                    width: 230.0,
                                    height: 230.0,
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.black),
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: new NetworkImage(
                                                "https://ahmedbawazir.com/sharing_books/profile/${widget.user.email}.jpg?dummy=${(number)}'")))),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                color: Colors.white70,
                                width: 350,
                                height: 180,
                                margin: EdgeInsets.all(20.0),
                                padding: EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ///////////

                                    Column(
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.person,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              widget.user.name?.toUpperCase(),
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.room,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              "Books Radius " +
                                                  widget.user.radius +
                                                  "KM",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              Icons.home,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Flexible(
                                              child: Text(
                                                "Your Inasis " +
                                                    widget.user.inasis
                                                        ?.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 17,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.my_location,
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Flexible(
                                            child: Text(
                                              _currentAddress,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ]),
                        SizedBox(
                          height: 0,
                        ),
                      ],
                    ),
                  );
                }
              }),
        ));
  }

  void _takePicture() async {
    /*  if (widget.user.name == "not register") {
      Toast.show("Not allowed please register", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } */
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Take new profile picture?",
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
              onPressed: () async {
                Navigator.of(context).pop();

                /////////////////////////////////////////////////

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text(
                        "Take  profile picture?",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            // usually buttons at the bottom of the dialog
                            new FlatButton(
                              child: new Text(
                                "Camera",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              onPressed: _getimage,
                            ),
                            new FlatButton(
                              child: new Text(
                                "Gallery",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              onPressed: _getimageg,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                ///////////////////

                String base64Image = base64Encode(_image.readAsBytesSync());
                http.post(urluploadImage, body: {
                  "encoded_string": base64Image,
                  "email": widget.user.email,
                }).then((res) {
                  print(res.body);
                  if (res.body == "success") {
                    setState(() {
                      number = new Random().nextInt(100);
                      print(number);
                    });
                  } else {}
                }).catchError((err) {
                  print(err + 'error');
                });
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
        //load data from database into list array 'data'
      });
    } catch (e) {
      print(e);
    }
  }

  void _changeRadius() {
    if (widget.user.name == "not register") {
      Toast.show("Not allowed please register", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    TextEditingController radiusController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Change new Radius (km)?",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
              keyboardType: TextInputType.number,
              controller: radiusController,
              decoration: InputDecoration(
                /////
                labelText: 'New radius',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(
                  Icons.map,
                  color: Colors.black,
                ),
              )),
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
                if (radiusController.text.length < 1) {
                  Toast.show("Please enter new radius ", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  return;
                }
                http.post(urlupdate, body: {
                  "email": widget.user.email,
                  "radius": radiusController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    setState(() {
                      widget.user.radius = dres[4];
                      Toast.show("Success ", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                      return;
                    });
                  } else {}
                }).catchError((err) {
                  print(err);
                });
                Toast.show("Failed ", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

  void _changeName() {
    TextEditingController nameController = TextEditingController();
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Change name for " + widget.user.name + "?",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              )),
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
                if (nameController.text.length < 2) {
                  Toast.show(
                      "Name should be more than 5 characters long", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  return;
                }
                http.post(urlupdate, body: {
                  "email": widget.user.email,
                  "name": nameController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    print('in success');
                    setState(() {
                      widget.user.name = dres[1];
                    });
                    Toast.show("Success", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    Navigator.of(context).pop();
                    return;
                  } else {}
                }).catchError((err) {
                  print(err);
                });
                // Toast.show("Failed", context,
                //     duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

  void _changePassword() {
    TextEditingController passController = TextEditingController();
    // flutter defined function
    print(widget.user.name);
    if (widget.user.name == "not register") {
      Toast.show("Not allowed please register", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Change Password for " + widget.user.name,
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
            controller: passController,
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
              icon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
            ),
            obscureText: true,
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
                if (passController.text.length < 5) {
                  Toast.show("Password too short", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  return;
                }
                http.post(urlupdate, body: {
                  "email": widget.user.email,
                  "password": passController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    print('in success');
                    setState(() {
                      widget.user.name = dres[6];
                      if (dres[0] == "success") {
                        Toast.show("Success", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        savepref(passController.text);
                        Navigator.of(context).pop();
                      }
                    });
                  } else {}
                }).catchError((err) {
                  print(err);
                });
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

  void _changePhone() {
    TextEditingController phoneController = TextEditingController();
    // flutter defined function
    /* print(widget.user.name);
    if (widget.user.name == "not register") {
      Toast.show("Not allowed please register", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } */

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Change phone for" + widget.user.name,
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
              keyboardType: TextInputType.phone,
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
              )),
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
                if (phoneController.text.length < 5) {
                  Toast.show("Please enter correct phone number", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  return;
                }
                http.post(urlupdate, body: {
                  "email": widget.user.email,
                  "phone": phoneController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    setState(() {
                      widget.user.phone = dres[3];
                      Toast.show("Success ", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      Navigator.of(context).pop();
                      return;
                    });
                  }
                }).catchError((err) {
                  print(err);
                });
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

  void _registerAccount() {
    TextEditingController phoneController = TextEditingController();
    // flutter defined function
    print(widget.user.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Register new account?",
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
                print(
                  phoneController.text,
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Register()));
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

  void _gotologinPage() {
    // flutter defined function
    print(widget.user.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Go to login page?" + widget.user.name,
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()));
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

  void _gotologout() async {
    // flutter defined function
    // if (widget.user.name == "not register") {
    //   Toast.show("You Must Have Account !!", context,
    //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //   return;
    // }
    print(widget.user.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Logout of account " + widget.user.name.toUpperCase(),
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
              onPressed: () async {
                Navigator.of(context).pop();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('email', '');
                await prefs.setString('pass', '');
                print("LOGOUT");
                Navigator.pop(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()));
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

  void _changeInasis() {
    TextEditingController inasisController = TextEditingController();
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Change inasis for " + widget.user.inasis + "?",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
              controller: inasisController,
              decoration: InputDecoration(
                labelText: 'Inasis',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
              )),
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
                print("inasis");
                if (inasisController.text.length <= 1) {
                  Toast.show(
                      "Name should be more than 5 characters long", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  return;
                }
                http.post(urlupdate, body: {
                  "email": widget.user.email,
                  "inasis": inasisController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    print('in success');
                    setState(() {
                      widget.user.inasis = dres[5];
                    });
                    Toast.show("Success", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    Navigator.of(context).pop();
                    return;
                  } else {}
                }).catchError((err) {
                  print(err);
                });
                Toast.show("Failed", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

  void savepref(String pass) async {
    print('Inside savepref');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pass', pass);
  }
}
