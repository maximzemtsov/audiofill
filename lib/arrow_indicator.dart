import 'package:flutter/material.dart';

class ArrowIndicator extends StatefulWidget {
  @override
  _ArrowIndicatorState createState() => _ArrowIndicatorState();
}

class _ArrowIndicatorState extends State<ArrowIndicator>
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
    return Container();
  }
}
