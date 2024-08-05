import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:post_house_rent_app/Widget/AccountManager.dart';
import 'package:post_house_rent_app/Widget/Search.dart';
import 'package:post_house_rent_app/Widget/ShowPost.dart';
import 'package:post_house_rent_app/Widget/TestLayToaDo.dart';
import 'package:post_house_rent_app/Widget/map_page.dart';
import 'package:post_house_rent_app/Widget/user_title.dart';
import 'package:post_house_rent_app/Widget/ListFavourite.dart';
import '../CheckInternet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  static final List<Widget> _widgetOptions = <Widget>[
    ShowPostWidget(),
    SearchWidget(),
    TestPageWidget(),
    AccountWidget(),
    MapPageWidget(),
  ];

  Future<void> _refresh() async {
    // Simulate refreshing data
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // Update state to refresh the screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidgetWrapper(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: IndexedStack(
            index: _currentIndex,
            children: _widgetOptions,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[800],
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                size: 35,
                Icons.home,
                color: _currentIndex == 0 ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                size: 35,
                Icons.search,
                color: _currentIndex == 1 ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(
                size: 35,
                Icons.favorite,
                color: _currentIndex == 2 ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
                // Action when the favorite button is pressed
              },
            ),
            IconButton(
              icon: Icon(
                size: 35,
                Icons.account_circle,
                color: _currentIndex == 3 ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            IconButton(
              icon: Icon(
                size: 35,
                Icons.map,
                color: _currentIndex == 4 ? Colors.blue : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ShowPostWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowPost(); // Your search screen content here
  }
}

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Search(); // Your search screen content here
  }
}

class AccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AccountManager(); // Your account screen content here
  }
}

class MapPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MapPage();
  }
}

class TestPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FavoritePost();
  }
}
