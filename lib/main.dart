import 'model/signalModel.dart';
import 'screens/arrowIndicatorScreen.dart';
import 'screens/digitIndicatorScreen.dart';
import 'screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignalModel()),
      ],
      child: Main(),
    ));

class Main extends StatelessWidget {
  const Main({Key key}) : super(key: key);

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
          '/arrow': routeArrowIndicatorScreen,
          '/digit': routeDigitIndicatorScreen,
        },
      ),
    );
  }

  /// Переход на стартовый экран
  Widget routeHomeScreen(BuildContext context) {
    return HomeScreen();
  }

  /// Переход на экран анимации уровня звукового окружения
  Widget routeArrowIndicatorScreen(BuildContext context) {
    //Наверное стоит тут включить Provider
    Provider.of<SignalModel>(context).start();
    return ArrowIndicatorScreen();
  }

  Widget routeDigitIndicatorScreen(BuildContext context) {
    //Наверное стоит тут включить Provider
    Provider.of<SignalModel>(context).start();
    return DigitIndicatorScreen();
  }
}
