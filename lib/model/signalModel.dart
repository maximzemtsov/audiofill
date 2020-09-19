import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/foundation.dart';

class SignalModel with ChangeNotifier {
  double _signal = 0;
  double get signaldB => _signal;

  //Организация канала
  static const CHANNEL_NAME =
      "8t61YpeA5stzji20ibgyRUSbt29LWH56ea0VZdk5lxoaUzGwoMKfiSdVyAaD";

  static const platform = const MethodChannel(CHANNEL_NAME);

  /// Проверка разрешений на доступ
  /// Verify that it was granted
  static Future<bool> checkPermission() async =>
      Permission.microphone.request().isGranted;

  /// Request the microphone permission
  static Future<void> requestPermission() async =>
      Permission.microphone.request();

  //bool _noiseSubscription = false;
  bool _is = false;
  double _outLevel = 0;
  int _countNormalize = 30;
  bool _normalize = false;

  void _setup() async {
    print("Запускаем цикл сборки");
    await _onData();
    if (_is) _setup();
  }

  Future<double> _getSignalLevel() async {
    try {
      final double val = await platform.invokeMethod('getSignalLevel');
      return (val == null) ? 0 : val;
    } on PlatformException catch (e) {
      print("Не могу получить значения '${e.message}'.");
      return 0;
    }
  }

  Future<void> _onData() async {
    _signal = await _getSignalLevel();
    if (_normalize) {
      _signal -= _outLevel;
      if (_signal < 0) _signal = 0.0;
    } else {
      if (_countNormalize == 0) {
        _outLevel = _outLevel / 30.0;
        _normalize = true;
        _signal = 0.0;
      } else {
        _outLevel += _signal;
        _countNormalize--;
        _signal = 0.0;
      }
    }
    if (_signal < 0) _signal = 0;
    notifyListeners();
  }

  void start() {
    try {
      if (!_is) {
        _is = true;
        _setup();
      }
    } catch (err) {
      print(err);
    }
  }

  void stop() {
    _is = false;
  }

  bool iswork() => _is;
}
