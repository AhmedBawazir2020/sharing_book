import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'login.dart';

String pathAsset = 'assets/images/profile.png';
String urlUpload =
    "https://ahmedbawazir.com/sharing_books/php/register_user.php";
File _image;
final picker = ImagePicker();
final TextEditingController _namecontroller = TextEditingController();
final TextEditingController _emcontroller = TextEditingController();
final TextEditingController _passcontroller = TextEditingController();
final TextEditingController _phcontroller = TextEditingController();
final TextEditingController _radiuscontroller = TextEditingController();
final TextEditingController _inasiscontroller = TextEditingController();

String _name, _email, _password, _phone, _radius, _inasis;

class Register extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
  const Register({Key key, File image}) : super(key: key);
}

class _RegisterUserState extends State<Register> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.lightBlue[600]));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.lightBlueAccent[400],
        appBar: AppBar(
          backgroundColor: Colors.lightBlue[600],
          title: Text('Registration'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: RegisterWidget(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    _image = null;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
    return Future.value(false);
  }
}

class RegisterWidget extends StatefulWidget {
  @override
  RegisterWidgetState createState() => RegisterWidgetState();
}

class RegisterWidgetState extends State<RegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
            onTap: _choose,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _image == null
                        ? AssetImage(pathAsset)
                        : FileImage(_image),
                    fit: BoxFit.fill,
                  )),
            )),
        Text('Click on image above to take profile picture'),
        TextField(
            controller: _emcontroller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
              icon: Icon(Icons.email),
            )),
        TextField(
            controller: _namecontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
              icon: Icon(Icons.person),
            )),
        TextField(
          controller: _passcontroller,
          decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
              icon: Icon(Icons.lock)),
          obscureText: true,
        ),
        TextField(
            controller: _phcontroller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(Icons.phone))),
        TextField(
            controller: _radiuscontroller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: 'Radius',
                labelStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                icon: Icon(Icons.blur_circular))),
        TextField(
            controller: _inasiscontroller,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                labelText: 'Inasis',
                labelStyle: TextStyle(
                  fontStyle: FontStyle.italic,
                  // color: Colors.block,
                ),
                icon: Icon(Icons.home))),
        SizedBox(
          height: 10,
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          minWidth: 260,
          height: 50,
          child: Text('Register'),
          color: Colors.blue,
          textColor: Colors.white,
          elevation: 15,
          onPressed: _onRegister,
        ),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
            onTap: _onBackPress,
            child: Text('Already Register',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16))),
      ],
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

  void _choose() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Chooes you tool"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new FlatButton(
                    child: Text("Camera"),
                    onPressed: _getimage,
                  ),
                  new FlatButton(
                    child: Text("Gallery"),
                    onPressed: _getimageg,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onRegister() {
    print('onRegister Button from RegisterUser()');
    print(_image.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Will send you an email to verify your account"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  new FlatButton(
                    child: Text(
                      "Okay",
                      style: TextStyle(color: Colors.black),
                    ),
                    color: Colors.blue,
                    onPressed: uploadData,
                  ),
                ],
              ),
            ),
          );
        });
    //uploadData();
  }

  void _onBackPress() {
    _image = null;
    print('onBackpress from RegisterUser');
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  void uploadData() {
    if (_image == null) {
      Toast.show("Please take profile pictuer ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    if (_passcontroller.text.length < 6) {
      Toast.show("Password too short ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }

    _name = _namecontroller.text;
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    _phone = _phcontroller.text;
    _radius = _radiuscontroller.text;
    _inasis = _inasiscontroller.text;

    if ((_isEmailValid(_email)) &&
        (_password.length > 5) &&
        (_image != null) &&
        (_phone.length > 5) &&
        (int.parse(_radius) < 30)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Registration in progress");
      pr.show();

      String base64Image = base64Encode(_image.readAsBytesSync());
      http.post(urlUpload, body: {
        "encoded_string": base64Image,
        "name": _name,
        "email": _email,
        "password": _password,
        "phone": _phone,
        "inasis": _inasis,
        "radius": _radius,
      }).then((res) {
        print(res.statusCode);
        if (res.body == "success") {
          Toast.show(res.body, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          _image = null;
          savepref(_email, _password);
          _namecontroller.text = '';
          _emcontroller.text = '';
          _phcontroller.text = '';
          _passcontroller.text = '';
          _inasiscontroller.text = '';

          pr.hide();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage()));
        }
      }).catchError((err) {
        print(err);
      });
    } else {
      Toast.show("Check your registration information", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void savepref(String email, String pass) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //true save pref
    await prefs.setString('email', email);
    await prefs.setString('pass', pass);
    print('Save pref $_email');
    print('Save pref $_password');
  }
}
