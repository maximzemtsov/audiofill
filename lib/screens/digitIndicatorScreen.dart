import 'package:audiofill/model/signalModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class DigitIndicatorScreen extends StatefulWidget {
  DigitIndicatorScreen({Key key}) : super(key: key);

  @override
  _DigitIndicatorScreenState createState() => _DigitIndicatorScreenState();
}

class _DigitIndicatorScreenState extends State<DigitIndicatorScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
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
            child: Center(
              child: LiquidLinearProgressIndicator(
                value: context.watch<SignalModel>().signaldB /
                    100.0, // Defaults to 0.5.
                valueColor: AlwaysStoppedAnimation(Colors
                    .yellowAccent), // Defaults to the current Theme's accentColor.
                backgroundColor: Colors
                    .transparent, // Defaults to the current Theme's backgroundColor.
                borderColor: Colors.transparent,
                borderWidth: 1.0,
                borderRadius: 12.0,
                direction: Axis
                    .vertical, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
                center: Text(
                  context.watch<SignalModel>().signaldB.round().toString(),
                  style: TextStyle(
                    fontSize: 48.0,
                    color: Colors.yellowAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
