import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.select):
              const Intent(ActivateAction.key)
        },
        child: MaterialApp(
          title: "Test Audio",
          home: HomePage(),
        ),
      );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _record = false;
  String _value = "text value 1";
  static const platform = const MethodChannel('audiofill/audiorecord');

  Future<void> _getAudioSignal() async {
    String val;
    try {
      final String result = await platform.invokeMethod('getAudioSignal');
      val = result;
      print(val);
    } on PlatformException catch (e) {
      val = "Infinity";
      print(e.message);
    }

    setState(() {
      _value = val;
    });
  }

  void pressButton() {
    if (!_record) {
      _getAudioSignal();
    }
    setState(() {
      _record = !_record;
    });
    print("Button is pressed. State is $_record");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: pressButton,
          child: Icon((_record) ? Icons.record_voice_over : Icons.mic_off),
          backgroundColor:
              (_record) ? Colors.red : Theme.of(context).accentColor,
        ),
        body: Center(child: Text(_value)),
      );
}
