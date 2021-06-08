import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'tab_screen1.dart';
import 'tab_screen2.dart';
import 'tab_screen3.dart';
import 'tab_screen4.dart';
import 'tab_screen5.dart';
import 'user.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> tabs;

  int currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    tabs = [
      TabScreen1(user: widget.user),
      TabScreen2(user: widget.user),
      TabScreen3(user: widget.user),
      TabScreen4(user: widget.user),
      TabScreen5(user: widget.user),
    ];
  }

  String $pagetitle = "Sharing Book";

  onTapped(int index) {
    setState(() {
      currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.blue));
    return Scaffold(
      body: tabs[currentTabIndex],
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.lightBlueAccent[100],
          selectedItemBackgroundColor: Colors.blue,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
          unselectedItemIconColor: Colors.black87,
          barHeight: 63,
          itemWidth: 60,
        ),
        selectedIndex: currentTabIndex,
        onSelectTab: (index) {
          setState(() {
            currentTabIndex = index;
          });
        },
        // onTap: onTapped,
        // currentIndex: currentTabIndex,
        // backgroundColor: Colors.white,
        // type: BottomNavigationBarType.fixed,
        items: [
          FFNavigationBarItem(
            iconData: Icons.library_books,
            label: "Menu",
          ),
          FFNavigationBarItem(
            iconData: Icons.list,
            label: "MyBooks",
          ),
          FFNavigationBarItem(
            iconData: Icons.book,
            label: "MyBorrows",
          ),
          FFNavigationBarItem(
            iconData: Icons.arrow_upward,
            label: "Requste",
          ),
          FFNavigationBarItem(
            iconData: Icons.person,
            label: "Profile",
          )
        ],
      ),
    );
  }
}
