import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharing_book/registation.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';

import 'mainScreen.dart';
//import 'registationS.dart';
import 'user.dart';

String urlupdate =
    "https://ahmedbawazir.com/sharing_books/php/password/enter_email.php";

String urlLogin = "https://ahmedbawazir.com/sharing_books/php/login_user.php";
final TextEditingController _emcontroller = TextEditingController();
String _email = "";
final TextEditingController _passcontroller = TextEditingController();
String _password = "";
bool _isChecked = false;
final TextEditingController passController = TextEditingController();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.red,
        accentColor: Colors.red,
        backgroundColor: Colors.red,
        hintColor: Colors.white,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    loadpref();
    print('Init: $_email');
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
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Image.asset(
                    'assets/images/logo10.png',
                    scale: 1.6,
                  ),
                  TextField(
                      controller: _emcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                          icon: Icon(Icons.email))),
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
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    minWidth: 250,
                    height: 50,
                    child: Text('LOGIN'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    elevation: 15,
                    onPressed: _onLogin,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool value) {
                          _onChange(value);
                        },
                        checkColor: Colors.black,
                      ),
                      Text('Remember Me',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black))
                    ],
                  ),
                  GestureDetector(
                      onTap: _onRegister,
                      child: Text('Register New Account',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16))),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: _onForgot,
                      child: Text('Forgot Password',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 16))),
                ],
              ),
            ),
          ),
        ));
  }

  void _onLogin() {
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    if (_isEmailValid(_email) && (_password.length > 4)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Login in");
      pr.show();
      http.post(urlLogin, body: {
        "email": _email,
        "password": _password,
      }).then((res) {
        print(res.statusCode);
        var string = res.body;
        List dres = string.split(",");
        print(dres);
        Toast.show(dres[0], context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        if (dres[0] == "success") {
          pr.hide();
          print("Radius:");
          print(dres);
          User user = new User(
            name: dres[1],
            email: dres[2],
            phone: dres[3],
            radius: dres[4],
            inasis: dres[5],
          );
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)));
        } else {
          pr.hide();
        }
      }).catchError((err) {
        pr.hide();
        print(err);
      });
    } else {}
  }

  void _onRegister() {
    print('onRegister');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Register()));
  }

  void _onForgot() {
    TextEditingController passController = TextEditingController();
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Reset Password  ",
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          content: new TextField(
            controller: passController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                fontStyle: FontStyle.italic,
              ),
              icon: Icon(Icons.email),
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
                //   _resetEmail();
                print("We send reset Email");
                http.post(urlupdate, body: {
                  "email": passController.text,
                }).then((res) {
                  var string = res.body;
                  List dres = string.split(",");
                  if (dres[0] == "success") {
                    print('in success');
                    setState(() {
                      if (dres[0] == "success") {
                        Toast.show("success", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                        saveprefPassword(passController.text);
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
                print("cancel");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onChange(bool value) {
    setState(() {
      _isChecked = value;
      savepref(value);
    });
  }

  void loadpref() async {
    print('Inside loadpref()');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = (prefs.getString('email'));
    _password = (prefs.getString('pass'));
    print(_email);
    print(_password);
    if (_email.length > 1) {
      _emcontroller.text = _email;
      _passcontroller.text = _password;
      setState(() {
        _isChecked = true;
      });
    } else {
      print('No pref');
      setState(() {
        _isChecked = false;
      });
    }
  }

  void savepref(bool value) async {
    print('Inside savepref');
    _email = _emcontroller.text;
    _password = _passcontroller.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //true save pref
      if (_isEmailValid(_email) && (_password.length > 5)) {
        await prefs.setString('email', _email);
        await prefs.setString('pass', _password);
        print('Save pref $_email');
        print('Save pref $_password');
        Toast.show("Preferences have been saved", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        print('No email');
        setState(() {
          _isChecked = false;
        });
        Toast.show("Check your credentials", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        _emcontroller.text = '';
        _passcontroller.text = '';
        _isChecked = false;
      });
      print('Remove pref');
      Toast.show("Preferences have been removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressAppBar() async {
    SystemNavigator.pop();
    print('Backpress');
    return Future.value(false);
  }

  void saveprefPassword(String password) async {
    print('Inside savepref');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
