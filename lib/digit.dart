import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noise_meter/noise_meter.dart';

class Digit extends StatefulWidget {
  Digit({Key key}) : super(key: key);

  @override
  _DigitState createState() => _DigitState();
}

class _DigitState extends State<Digit> with SingleTickerProviderStateMixin {
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
              child: Text(
                "${_signaldB.toStringAsFixed(3)} дБ",
                style: TextStyle(
                    fontFamily: GoogleFonts.openSans().fontFamily,
                    fontSize: 120,
                    color: Color(0xffffca3a),
                    fontWeight: FontWeight.w100),
              ),
            ),
          ),
        ),
      ),
    );
  }

  final double maxSignaldB = 400;
  double _signaldB = 0;
}
