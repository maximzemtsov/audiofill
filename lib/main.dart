import 'package:audiofill/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': routeHomeScreen,
        },
      ),
    );
  }

  /// Переход на стартовый экран
  Widget routeHomeScreen(BuildContext context) {
    return HomeScreen();
  }

  /// Переход на экран анимации уровня звукового окружения
  Widget routeIndicate(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details Animation"),
      ),
      body: Text("Text animation))"),
    );
  }
}
