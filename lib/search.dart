import 'dart:convert';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'user.dart';

double perpage = 1;

class Searching {
  //For the mock data type we will use review (perhaps this could represent a restaurant);
  num stars;
  String name, imgURL;
  final User user;

  Searching(this.stars, this.name, this.imgURL, this.user);
}

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Searching();
}

class _Searching extends State<SearchPage> {
  List<Searching> suggestions = [];

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";

  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<Searching>>();

  AutoCompleteTextField<Searching> textField;

  Searching selected;

  _Searching() {
    textField = new AutoCompleteTextField<Searching>(
      decoration: new InputDecoration(
          hintText: "Search Books", suffixIcon: new Icon(Icons.search)),
      itemSubmitted: (item) => setState(() => selected = item),
      key: key,
      suggestions: suggestions,
      itemBuilder: (context, suggestion) => new Padding(
          child: new ListTile(
              title: new Text(suggestion.name),
              trailing: new Text("Stars: ${suggestion.stars}")),
          padding: EdgeInsets.all(8.0)),
      itemSorter: (a, b) => a.stars == b.stars ? 0 : a.stars > b.stars ? -1 : 1,
      itemFilter: (suggestion, input) =>
          suggestion.name.toLowerCase().startsWith(input.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.lightBlueAccent[400],
      appBar: new AppBar(
        title: new Text('Searching....'),
        elevation: 5.0, //shadow
        backgroundColor: Colors.lightBlue[600],
      ),
      body: new Column(children: [
        new Padding(
            child: new Container(child: textField),
            padding: EdgeInsets.all(16.0)),
        new Padding(
            padding: EdgeInsets.fromLTRB(0.0, 64.0, 0.0, 0.0),
            child: new Card(
                child: selected != null
                    ? new Column(children: [
                        new ListTile(
                            title: new Text(selected.name),
                            trailing: new Text("Rating: ${selected.stars}/5")),
                        new Container(
                            // child: new Image(
                            //     image: NetworkImage(
                            //                     "https://ahmedbawazir.com/sharing_books/images/${data[index]['bookimage']}.jpg")),
                            // width: 400.0,
                            height: 300.0)
                      ])
                    : new Icon(Icons.cancel))),
      ]),
    );
  }

  Future<String> makeRequest() async {
    String _onBookDetail =
        "https://ahmedbawazir.com/sharing_books/php/load_books.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading Books");
    pr.show();
    http.post(_onBookDetail, body: {
      //  "email": widget.user.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      // "radius": widget.user.radius ?? "10",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        suggestions = extractdata["books"];
        perpage = (suggestions.length / 10);
        print("data");
        print(suggestions);
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
}
