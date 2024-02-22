import 'package:flutter/material.dart';
import 'package:voicetrack/widgets/navigationbar.dart';
import 'package:voicetrack/widgets/filerange.dart';
import 'package:voicetrack/widgets/record.dart';

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
            child: Text(
              'VoiceTrack',
              style: TextStyle(
                color: Colors.purple[200],
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 330,
              child: FileRangeWidget(),
            ),
            SizedBox(
              child: RecordWidget(),
            ),
          ],
        ),
        bottomNavigationBar: Navigationbar(),
      ),
    );
  }
}
