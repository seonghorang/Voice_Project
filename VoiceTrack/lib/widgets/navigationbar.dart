import 'package:flutter/material.dart';
import 'package:voicetrack/screens/test/test.dart';
import 'package:voicetrack/main.dart';

class Navigationbar extends StatelessWidget {
  const Navigationbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(234, 234, 234, 92),
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.star, size: 40),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Test()),
                );
              },
            );
          }),
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.home, size: 40),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
            );
          }),
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.favorite, size: 40),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Test()),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
