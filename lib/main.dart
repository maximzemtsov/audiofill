import 'package:audiofill/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select):
            const Intent(ActivateAction.key)
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.mina().fontFamily,
        ),
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
