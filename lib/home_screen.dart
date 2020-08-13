import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'arrow_indicator.dart';
import 'digit.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentScaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/main_background.png"),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        key: currentScaffold,
        backgroundColor: Color(0xAA11143A),
        /*Theme.of(context).primaryColor,*/
        appBar: AppBar(
          backgroundColor: Color(0xAA11143A),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Text(
              "Визуализация музыкального окружения",
              style: TextStyle(
                  fontFamily: GoogleFonts.openSans().fontFamily,
                  fontSize: 28,
                  color: Color(0xffffca3a),
                  fontWeight: FontWeight.w100),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: IconButton(
                onPressed: () {
                  print("Инфо: Открыть окно настроек проекта");
                  currentScaffold.currentState.openDrawer();
                },
                focusColor: Colors.transparent,
                icon: Icon(
                  Icons.settings,
                  size: 32,
                  color: Color(0xffffca3a),
                ),
              ),
            )
          ],
        ),
        body: Container(child: corouselView()),
      ),
    );
  }

  Widget settings() {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        color: Color(0xff11143A),
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back,
                        size: 48, color: Color(0xffffca3a)),
                  ),
                  Text('Настройки приложения',
                      style: TextStyle(
                          fontFamily: GoogleFonts.openSans().fontFamily,
                          fontSize: 28,
                          color: Color(0xffffca3a),
                          fontWeight: FontWeight.w600)),
                ],
              ),
              decoration: BoxDecoration(
                color: Color(0xFF11143A),
              ),
            ),
            ListTile(
              title: Text('Канал захвата звука',
                  style: TextStyle(
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontSize: 28,
                      color: Color(0xffffca3a),
                      fontWeight: FontWeight.w100)),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Устройство захвата звука',
                  style: TextStyle(
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontSize: 28,
                      color: Color(0xffffca3a),
                      fontWeight: FontWeight.w100)),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget corouselView() {
    final List<String> imgList = [
      'assets/images/cover_0.png',
      'assets/images/cover_1.png',
      'assets/images/cover_2.png',
      'assets/images/cover_3.png',
      'assets/images/cover_4.png',
      'assets/images/cover_5.png',
    ];

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(15),
      shrinkWrap: true,
      children: [
        Cover(
            item: [imgList[0], "Цифровой индикатор"],
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Digit()));
            }),
        Cover(
            item: [imgList[1], "Стрелочный индикатор"],
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ArrowIndicator()));
            }),
        /*       Cover(
            item: [imgList[2], imgList[0]],
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Digit()));
            }),
        Cover(
            item: [imgList[3], imgList[0]],
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Digit()));
            }),
        Cover(
            item: [imgList[4], imgList[0]],
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Digit()));
            }),
        Cover(
            item: [imgList[5], imgList[0]],
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Digit()));
            }),*/
      ],
    );
  }
}

class Cover extends StatefulWidget {
  const Cover({
    Key key,
    @required this.item,
    @required this.onTap,
    this.onFocus,
  }) : super(key: key);

  final List<String> item;
  final Function onTap;
  final Function onFocus;

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  FocusNode _node;
  AnimationController _controller;
  Animation<double> _animation;
  int _focusAlpha = 100;

  Widget image;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
        lowerBound: 0.9,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_node.hasFocus) {
      _controller.forward();
      if (widget.onFocus != null) {
        widget.onFocus();
      }
    } else {
      _controller.reverse();
    }
  }

  void _onTap() {
    _node.requestFocus();
    if (widget.onTap != null) {
      widget.onTap();
    }
  }

  // void _openDetails() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.item)));
  // }

  // bool _onKey(FocusNode node, RawKeyEvent event) {
  //   if(event is RawKeyDownEvent) {
  //     if(event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       _onTap();
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );

    // return Focus(
    //     focusNode: _node,
    //     onKey: _onKey,
    //     child: Builder(
    //       builder: (context) {
    //         return buildCover(context);
    //       }
    //     ),
    // );
  }

  Widget buildCover(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _onTap,
        child: Column(
          children: <Widget>[
            Container(
              child: Image.asset(
                widget.item[0],
                fit: BoxFit.fitHeight,
                height: 400,
              ),
              /*buildPosterImage(context),*/
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(_focusAlpha),
                  blurRadius: 15,
                  offset: Offset(10, 15),
                )
              ]),
            ),
            SizedBox(height: 5),
            Align(
              child: Text(
                widget.item[1],
                maxLines: 1,
                style: TextStyle(color: Colors.white),
              ),
              alignment: Alignment.topLeft,
            ),
          ],
        ),
      ),
    );
  }
}
