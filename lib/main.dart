import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:lykluk_clone/views/dashboard_view.dart';
import 'package:wakelock/wakelock.dart';

import 'routes.dart';
import 'helpers/global_keys.dart';
import 'repositories/settings_repository.dart' as settingRepo;
import 'repositories/video_repository.dart' as videoRepo;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorKey: GlobalVariable.navState,
      initialRoute: '/dashboard',
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // fontFamily: 'ProductSans',
        primaryColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 0, foregroundColor: Colors.white),
        brightness: Brightness.light,
        accentColor: Color(0xff36C5D3),
        dividerColor: Color(0xff36C5D3).withOpacity(0.1),
        focusColor: Color(0xff36C5D3).withOpacity(1),
        hintColor: Color(0xff000000).withOpacity(0.2),
        textTheme: TextTheme(
          headline5:
              TextStyle(fontSize: 22.0, color: Color(0xff000000), height: 1.3),
          headline4: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Color(0xff000000),
              height: 1.3),
          headline3: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            color: Color(0xff000000),
          ),
          headline2: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Color(0xff000000),
          ),
          headline1: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.w300,
              color: Color(0xff000000),
              height: 1.4),
          subtitle1: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Color(0xff000000),
              height: 1.3),
          headline6: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w700,
              color: Color(0xff000000),
              height: 1.3),
          bodyText2: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: Color(0xff000000),
              height: 1.2),
          bodyText1: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: Color(0xff000000),
              height: 1.3),
          caption: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              color: Color(0xff000000).withOpacity(0.5),
              height: 1.2),
        ),
      ),
      
    );
  }
}
