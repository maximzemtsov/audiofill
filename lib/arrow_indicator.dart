import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_store/flutter_cache_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noise_meter/noise_meter.dart';

class ArrowIndicator extends StatefulWidget {
  @override
  _ArrowIndicatorState createState() => _ArrowIndicatorState();
}

class _ArrowIndicatorState extends State<ArrowIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  bool _isRecording = false;
  StreamSubscription<NoiseReading> _noiseSubscription;
  NoiseMeter _noiseMeter = new NoiseMeter();
  Timer _timer = null;

  void seUpAudio() async {
    //print(" ====> Start timer!");
    final duration = Duration(seconds: 4);
    _timer = Timer(duration, repeatAudioSetting);
  }

  void repeatAudioSetting() {
    //print(" ====> Start trigger restart!");
    stop();
    _timer.cancel();
    sleep(Duration(milliseconds: 300));
    start();
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    //*print(noiseReading.toString());*/
    setState(() {
      _signaldB = noiseReading.maxDecibel - 30;
    });
    print("${noiseReading.maxDecibel} dB");
  }

  void start() async {
    //print(" ====> Start audio meter!");
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
      seUpAudio();
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    start();
  }

  @override
  void dispose() {
    stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: Scaffold(
        body: _arrowIndicator(context, _signaldB),
      ),
    );
  }

  final double maxSignaldB = 400;
  double _signaldB = 0;

  void _getSignal() => setState(() {
        _signaldB = Random().nextDouble() * maxSignaldB;
      });

  Widget _arrowIndicator(BuildContext ctx, double value) {
    double h1 = MediaQuery.of(ctx).size.height;
    double h13 = 1; //0.16784 * h1;
    double h12 = h1 - h13 - 1;
    return SizedBox(
      height: h1,
      width: MediaQuery.of(ctx).size.width,
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
            child: CustomPaint(
              painter: Indicator(value),
              child: Container(),
            ),
          ),
          Container(height: h13, color: Colors.black, child: null),
        ],
      ),
    );
  }
}

class Indicator extends CustomPainter {
  final double _value;

  Indicator(this._value);

  final double w1 = 1920;
  final double h1 = 853;
  double _dt;
  Offset _lt, _rb;

  double pd(double val) => val * _dt;

  Offset pd0(double dx, double dy) {
    Offset tmp = Offset(pd(dx) + _lt.dx, pd(dy) + _lt.dy);
    //print("dx = ${tmp.dx},  dy = ${tmp.dy}");
    return tmp;
  }

  Offset pdr0(double rdx, double rdy) {
    Offset tmp = pd0(w1 - rdx, h1 - rdy);
    return tmp;
  }

  void drawText(Canvas context, String name, double x, double y,
      double angleRotationInDegree, TextStyle style) {
    context.save();
    context.translate(x, y);
    double angleRotationInRadians = pi * angleRotationInDegree / 180;
    context.rotate(angleRotationInRadians);
    TextSpan span = new TextSpan(style: style, text: name);
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(context, new Offset(0.0, 0.0));
    context.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    double dx = size.width / w1;
    double dy = size.height / h1;
    //print("dpx = $dx,  dpy = $dy");
    //print("size = ${size.toString()}");
    if (dx == dy) {
      _dt = dx;
      _lt = Offset(0, 0);
      _rb = Offset(size.width, size.height);
    } else if (dx < dy) {
      _dt = dx;
      double oy = (size.height - h1 * _dt) / 2;
      _lt = Offset(0, oy);
      _rb = Offset(size.width, size.height - oy);
    } else {
      _dt = dy;
      double ox = (size.width - w1 * _dt) / 2;
      _lt = Offset(ox, 0);
      _rb = Offset(size.width - ox, size.height);
    }

    Paint bpaint = Paint()..color = Color(0xff000000);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), bpaint);
    //bpaint.color = Colors.white;
    //canvas.drawRect(Rect.fromLTRB(_lt.dx, _lt.dy, _rb.dx, _rb.dy), bpaint);

    var paint = Paint()
      ..color = Color(0xFFFF0000)
      ..strokeWidth = pd(10);

    /// Основные деления индикатора
    canvas.drawLine(pd0(314, 297), pdr0(1471, 276.0 + 143), paint);
    //print(
    //    "===> ${pd(314)}, ${pd(297)}, ${pd(w1 - 1471)}, ${pd(h1 - 276 - 143)}");
    canvas.drawLine(pd0(400, 263), pdr0(1422, 294.0 + 143), paint);
    canvas.drawLine(pd0(540, 222), pdr0(1307, 326.0 + 143), paint);
    canvas.drawLine(pd0(622, 201), pdr0(1241, 343.0 + 143), paint);
    canvas.drawLine(pd0(805, 171), pdr0(1081, 368.0 + 143), paint);
    canvas.drawLine(pd0(893, 163), pdr0(1009, 371.0 + 143), paint);
    canvas.drawLine(pd0(w1 - 861, 166), pd0(1037, h1 - 371.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 783, 171), pd0(1101, h1 - 365.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 625, 199), pd0(1229, h1 - 344.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 531, 220), pd0(1309, h1 - 325.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 445, 245), pd0(1373, h1 - 310.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 379, 265), pd0(1421, h1 - 296.0 - 143), paint);
    canvas.drawLine(pd0(w1 - 320, 288), pd0(1467, h1 - 284.0 - 143), paint);

    ///Дополнительные деления индикатора
    paint.strokeWidth = pd(5);
    canvas.drawLine(pd0(488, 312), pdr0(1383, 309 + 143.0), paint);
    canvas.drawLine(pd0(526, 301), pdr0(1345, 318 + 143.0), paint);
    canvas.drawLine(pd0(551, 293), pdr0(1324, 325 + 143.0), paint);
    canvas.drawLine(pd0(590, 283), pdr0(1285, 333 + 143.0), paint);
    canvas.drawLine(pd0(604, 280), pdr0(1274, 337 + 143.0), paint);
    canvas.drawLine(pd0(617, 277), pdr0(1264, 340 + 143.0), paint);
    canvas.drawLine(pd0(632, 273), pdr0(1253, 343 + 143.0), paint);
    canvas.drawLine(pd0(728, 256), pdr0(1157, 355 + 143.0), paint);
    canvas.drawLine(pd0(766, 250), pdr0(1130, 365 + 143.0), paint);
    canvas.drawLine(pd0(798, 245), pdr0(1102, 368 + 143.0), paint);
    canvas.drawLine(pd0(843, 244), pdr0(1060, 371 + 143.0), paint);
    canvas.drawLine(pd0(861, 242), pdr0(1046, 373 + 143.0), paint);
    canvas.drawLine(pd0(874, 242), pdr0(1035, 373 + 143.0), paint);
    canvas.drawLine(pd0(890, 242), pdr0(1023, 373 + 143.0), paint);
    canvas.drawLine(pd0(964, 239), pdr0(954, 370.0 + 143), paint);
    canvas.drawLine(pd0(914, 239), pdr0(997, 373.0 + 143), paint);

    canvas.drawLine(pd0(w1 - 889, 242), pd0(1021, h1 - 371 - 143), paint);
    canvas.drawLine(pd0(w1 - 850, 242), pd0(1055, h1 - 370 - 143), paint);
    canvas.drawLine(pd0(w1 - 834, 241), pd0(01067, h1 - 368 - 143), paint);
    canvas.drawLine(pd0(w1 - 822, 245), pd0(1078, h1 - 368 - 143), paint);
    canvas.drawLine(pd0(w1 - 810, 245), pd0(1086, h1 - 366 - 143), paint);

    canvas.drawLine(pd0(w1 - 744, 250), pd0(1151, h1 - 357 - 143), paint);
    canvas.drawLine(pd0(w1 - 705, 260), pd0(1184, h1 - 353 - 143), paint);
    canvas.drawLine(pd0(w1 - 670, 264), pd0(1215, h1 - 348 - 143), paint);
    canvas.drawLine(pd0(w1 - 628, 274), pd0(1250, h1 - 339 - 143), paint);
    canvas.drawLine(pd0(w1 - 611, 278), pd0(1266, h1 - 339 - 143), paint);
    canvas.drawLine(pd0(w1 - 593, 281), pd0(1279, h1 - 334 - 143), paint);
    canvas.drawLine(pd0(w1 - 579, 285), pd0(1292, h1 - 331 - 143), paint);
    canvas.drawLine(pd0(w1 - 522, 300), pd0(1341, h1 - 318 - 143), paint);

    ///Надписи на индикаторе
    ///

    TextStyle stDigit = GoogleFonts.mina(
        color: Color(0xffff0000),
        fontSize: pd(50),
        fontWeight: FontWeight.w400);
    drawText(canvas, "0", _lt.dx + pd(250), _lt.dy + pd(250), -37.01, stDigit);
    drawText(
        canvas, "0,01", _lt.dx + pd(321), _lt.dy + pd(212), -27.96, stDigit);
    drawText(
        canvas, "0,1", _lt.dx + pd(560), _lt.dy + pd(124), -14.42, stDigit);
    drawText(canvas, "0,5", _lt.dx + pd(755), _lt.dy + pd(85), -4.6, stDigit);
    drawText(canvas, "1", _lt.dx + pd(880), _lt.dy + pd(75), -2.79, stDigit);
    drawText(canvas, "5", _lt.dx + pd(1060), _lt.dy + pd(80), 8, stDigit);
    drawText(canvas, "10", _lt.dx + pd(1130), _lt.dy + pd(90), 12.18, stDigit);
    drawText(canvas, "50", _lt.dx + pd(1275), _lt.dy + pd(110), 10.71, stDigit);
    drawText(
        canvas, "100", _lt.dx + pd(1380), _lt.dy + pd(120), 18.012, stDigit);
    drawText(
        canvas, "400", _lt.dx + pd(1580), _lt.dy + pd(180), 28.02, stDigit);

    ///Надпись dB

    ///Надпись POWER
    TextStyle stText = GoogleFonts.mina(
        color: Color(0xffff0000),
        fontSize: pd(50),
        fontWeight: FontWeight.w400);
    drawText(canvas, "dB", _lt.dx + pd(937), _lt.dy + pd(399), 0, stText);

    TextStyle stTextName = GoogleFonts.mina(
        color: Color(0xffEAB7B7),
        fontSize: pd(50),
        fontWeight: FontWeight.w600);
    drawText(
        canvas, "POWER", _lt.dx + pd(879), _lt.dy + pd(551), 0, stTextName);

    ///Стрелочка индикатора

    double _x0 = w1 / 2;
    double _y0 = h1 + 60;
    double _radius = 750.0;

    double _delta = 0.0; //(_value * 100) % 100.0;
    if (_value <= 1)
      _delta = _value * 42;
    else if (_value <= 5)
      _delta = 42 + (_value / 5) * 13; //55
    else if (_value <= 10)
      _delta = 55 + ((_value - 5) / 5) * (61 - 55); //61;
    else if (_value <= 50)
      _delta = 61 + ((_value - 10) / 40) * (73 - 61); //73;
    else if (_value <= 100)
      _delta = 73 + ((_value - 50) / 50) * (80 - 73); //80;
    else if (_value <= 200)
      _delta = 80 + ((_value - 100) / 100) * (86 - 80); //86;
    else if (_value <= 300)
      _delta = 86 + ((_value - 200) / 100) * (90 - 86); //90;
    else if (_value <= 400)
      _delta = 90 + ((_value - 300) / 100) * (94 - 90); //94;
    else
      _delta = 100;

    print("${_value} db => delta = $_delta");

    //double alfa0 = (135.0 - _delta) * pi / 180.0;

    double alfa0 = (43.0 + _delta) * pi / 180.0;

    double _x1 = _x0 + _radius * cos(pi - alfa0);
    double _y1 = _y0 - _radius * sin(pi - alfa0);

    double _x2 = _x0 + (60 + 143) * cos(pi - alfa0) / sin(pi - alfa0);
    double _y2 = _y0 - 243;
    var offset_1 = pd0(_x1, _y1);
    var offset_2 = pd0(_x2, _y2);
    canvas.drawLine(offset_1, offset_2, paint);
    _x2 = _x0 + (_radius - 30) * cos(pi - alfa0);
    _y2 = _y0 - (_radius - 30) * sin(pi - alfa0);
    offset_2 = pd0(_x2, _y2);
    paint.color = Colors.white;
    canvas.drawLine(offset_1, offset_2, paint);
    //Path path = Path();
    //path.moveTo(offset_1.dx, offset_1.dy);
    //path.lineTo(offset_2.dx, offset_2.dy);
    //path.lineTo(_x1, _y1);
    //path.close();
    //canvas.drawShadow(path, Color(0xffff0000), -6, true);
    //canvas.drawPath(path, paint);

    ///Нижний прямоугольник
    var rpaint = Paint()..color = Color(0xFF000000);
    canvas.drawRect(
        Rect.fromLTRB(_lt.dx, _rb.dy - 100, _rb.dx, _rb.dy), rpaint);
  }

  @override
  bool shouldRepaint(Indicator oldDelegate) => false;
}
