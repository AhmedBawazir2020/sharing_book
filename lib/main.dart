import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sharing_book/login.dart';
//import 'loginS.dart';

void main() => runApp(Splash());

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.lightBlueAccent[400]));
    return MaterialApp(
      theme: new ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.blue,
        accentColor: Colors.white,
        hintColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlueAccent[400],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/logo10.png',
                scale: 1.8,
              ),
              SizedBox(
                height: 50,
              ),
              new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => new _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            //print('Sucess Login');
            // loadpref(this.context);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          }
        });
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      child: CircularProgressIndicator(),
    ));
  }
}
