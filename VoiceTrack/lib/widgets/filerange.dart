import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

AudioPlayer audioPlayer = AudioPlayer();

class FileRangeWidget extends StatefulWidget {
  FileRangeWidget({Key? key}) : super(key: key);
  @override
  FileRangeWidgetState createState() => FileRangeWidgetState();
}

class FileRangeWidgetState extends State<FileRangeWidget> {
  String? key;
  String? fileName;
  String? fileUrl;
  bool _isLoading = false;
  List<File> _selectedFiles = [];
  List<String> fileNames = [];
  List<String> keys = [];

  void uploadAllFiles() async {
    setState(() {
      _isLoading = true;
    });

    audioPlayer.play(AssetSource('sounds/ailoading.mp3'));

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://172.30.1.17:5000/upload'));

    for (var file in _selectedFiles) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print('Upload successful');
      response.stream.transform(utf8.decoder).join().then((value) {
        print(value);
        Map<String, dynamic> responseJson = jsonDecode(value);
        responseJson.entries.forEach((entry) {
          setState(() {
            fileNames.add(entry.key);
            keys.add(entry.value);
            // Map<String, dynamic> result = jsonDecode(value);
            // setState(() {
            //   key = result['key']; // 서버 응답에서 키값 추출
            //   fileName = file.path.split('/').last; // 파일 이름 추출
          });
        });
      });
    } else {
      print('Upload failed');
    }
    setState(() {
      _isLoading = false; // 파일 업로드 완료 후에 로딩 상태를 false로 설정
      _selectedFiles.clear();
    });
    audioPlayer.stop();
    fileNames.clear();
    keys.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text("AI가 돌아가고 이쓰요!"),
                ),
              ],
            )
          : ListView(
              children: [
                Align(
                  child: ElevatedButton(
                    child: Text('파일 선택'),
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                      );
                      if (result != null) {
                        setState(() {
                          // 화면을 갱신합니다.
                          List<File> files =
                              result.paths.map((path) => File(path!)).toList();
                          // 새롭게 선택한 파일들을 리스트에 추가합니다.
                          _selectedFiles.addAll(files);
                        });
                      } else {
                        print('파일 선택 취소');
                      }
                    },
                  ),
                ),
                ..._selectedFiles
                    .map((file) => Text(
                          '선택된 파일: ${path.basename(file.path)}', // 파일 이름 앞에 '선택된 파일: ' 텍스트를 추가합니다.
                          style: TextStyle(
                              fontWeight:
                                  FontWeight.bold), // 선택된 파일 이름에 볼드체를 적용합니다.
                        ))
                    .toList(),
                Align(
                  child: ElevatedButton(
                    // '파일 업로드' 버튼을 누르면 선택한 모든 파일을 업로드합니다.
                    onPressed: uploadAllFiles,
                    child: Text('파일 업로드'),
                  ),
                ),
                ...List.generate(fileNames.length, (index) {
                  return Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '파일명: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold, // 볼드체
                                fontSize: 18, // 글자 크기
                              ),
                            ),
                            TextSpan(
                              text: '${fileNames[index]}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '키: ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold, // 볼드체
                                fontSize: 18, // 글자 크기
                              ),
                            ),
                            TextSpan(
                              text: '${keys[index]}',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
    );
  }
}
