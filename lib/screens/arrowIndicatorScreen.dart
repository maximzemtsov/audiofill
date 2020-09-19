import 'package:audiofill/model/signalModel.dart';
import 'package:audiofill/widgets/Indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ArrowIndicatorScreen extends StatefulWidget {
  ArrowIndicatorScreen({Key key}) : super(key: key);

  @override
  _ArrowIndicatorScreenState createState() => _ArrowIndicatorScreenState();
}

class _ArrowIndicatorScreenState extends State<ArrowIndicatorScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  CurvedAnimation _curve;

  var _completeValue = Tween<double>(begin: 0, end: 400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _curve = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/main_background.png"),
              fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Color(0xAA11143A),
          /*Theme.of(context).primaryColor,*/
          body: Container(
            child: _arrowIndicator(context),
          ),
        ),
      ),
    );
  }

  final double maxSignaldB = 400;

  Widget _arrowIndicator(BuildContext context) {
    double h1 = MediaQuery.of(context).size.height;
    double h13 = 1; //0.16784 * h1;
    double h12 = h1 - h13 - 1;
    _controller.value = context.watch<SignalModel>().signaldB;
    return SizedBox(
      height: h1,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 1,
            child: null,
            decoration: BoxDecoration(color: Colors.black, boxShadow: [
              BoxShadow(
                color: Colors.red,
                offset: Offset(0, 20),
                blurRadius: 250,
                spreadRadius: 0,
              )
            ]),
          ),
          Container(
            height: h12,
            color: Colors.black,
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: Indicator(context: context),
                    child: Container(),
                  );
                }),
          ),
          Container(height: h13, color: Colors.black, child: null),
        ],
      ),
    );
  }
}
