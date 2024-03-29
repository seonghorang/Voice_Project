import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:voicetrack/widgets/navigationbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FileRange extends StatefulWidget {
  FileRange({Key? key}) : super(key: key);
  @override
  FileRangeState createState() => FileRangeState();
}

class FileRangeState extends State<FileRange> {
  String? key;
  String? fileName;

  void uploadFile(File file) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Upload successful');
      response.stream.transform(utf8.decoder).join().then((value) {
        Map<String, dynamic> result = jsonDecode(value);
        setState(() {
          key = result['key']; // 서버 응답에서 키값 추출
          fileName = file.path.split('/').last; // 파일 이름 추출
        });
      });
    } else {
      print('Upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                child: Text('파일 선택'),
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    File file = File(result.files.single.path!);
                    uploadFile(file);
                  } else {
                    print('파일 선택 취소');
                  }
                },
              ),
              if (key != null && fileName != null)
                Text(' 파일명 : $fileName \n 키 : $key '), // 키값이 있으면 화면에 표시
            ],
          ),
        ),
        bottomNavigationBar: Navigationbar(),
      ),
    );
  }
}
