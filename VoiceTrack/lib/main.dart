import 'package:flutter/material.dart';
import 'package:voicetrack/screens/record/combi.dart';
import 'package:voicetrack/widgets/navigationbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: TextButton(
          child: Text('VoiceTrack',
              style: TextStyle(
                color: Colors.purple[200],
                fontSize: 24,
                fontWeight: FontWeight.w800,
              )),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
        // elevation: 10.0,
      ),
      body: Center(
        child: Column(children: [
          Builder(builder: (BuildContext context) {
            return ElevatedButton(
              child: const Text('combi'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Combi(),
                  ),
                );
              },
            );
          }),
        ]),
      ),
      bottomNavigationBar: Navigationbar(),
    ));
  }
}
