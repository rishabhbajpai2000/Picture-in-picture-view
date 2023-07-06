import 'package:flutter/material.dart';
import 'package:for_testing/BackGroundScreen.dart';
import 'package:for_testing/FloatingScreen.dart';
import 'package:for_testing/raw_pip_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          // an object of RawPIPView is made, this is responsible for handling the minimising and maximising of the floating screen,
          // floating screen and background screen are passed as arguments to the RawPIPView
          child: RawPIPView(
            // startMinimized parameter is used to start the floating screen in minimized state.
            startMinimized: true,
            initialCorner: PIPViewCorner.bottomLeft,
            floatingWidth: 200,
            floatingHeight: 200,
            avoidKeyboard: true,
            topWidget: const FloatingScreen(),
            bottomWidget: BackgroundScreen(),
          ),
        ),
      ),
    );
  }
}
