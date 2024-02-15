import 'package:flutter/material.dart';
import 'package:voicetrack/screens/test/test.dart';
import 'package:voicetrack/screens/filerange/filerange.dart';
import 'package:voicetrack/screens/record/record.dart';
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
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Builder(builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('test'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Test(),
                    ),
                  );
                },
              );
            }),
            Builder(builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('파일측정'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileRange(),
                    ),
                  );
                },
              );
            }),
            Builder(builder: (BuildContext context) {
              return ElevatedButton(
                child: const Text('녹음측정'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Record()),
                  );
                },
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Navigationbar(),
    ));
  }
}
