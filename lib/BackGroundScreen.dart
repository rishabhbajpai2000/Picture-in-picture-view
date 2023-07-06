import 'package:flutter/material.dart';

class BackgroundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text('Background Screen'),
        ),
        // there is a button at the center of the scaffold, on topping it, the page chnges to another page.
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // the page will change to floating screen on tapping the button
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ThirdScreen()),
              );
            },
            child: Text('Change Screen'),
          ),
        ));
  }
}

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    // this page will have yellow color as background
    return Scaffold(
      backgroundColor: Colors.yellow,
    );
  }
}
