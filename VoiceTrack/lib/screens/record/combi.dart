import 'package:permission_handler/permission_handler.dart';
import 'package:voicetrack/widgets/navigationbar.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

AudioPlayer audioPlayer = AudioPlayer();

class RecordWidget extends StatefulWidget {
  RecordWidget({Key? key}) : super(key: key);
  @override
  RecordWidgetState createState() => RecordWidgetState();
}

class RecordWidgetState extends State<RecordWidget> {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer? _player = FlutterSoundPlayer();
  bool _isRecording = false;
  String? _recordFilePath;
  String? _key;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    initPlayer();
  }

  void initPlayer() async {
    await _player!.openAudioSession();
  }

  void _startRecording() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder!.openAudioSession();
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDirectory.path;
      _recordFilePath = '$appDocPath/record.wav';
      await _recorder!.startRecorder(
        toFile: _recordFilePath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
      print('녹음 시작');
    } else {
      print('Microphone permission not granted');
      //여기에 필요한 알림 또는 동작을 추가합니다.
    }
  }

  void _stopRecording() async {
    await _recorder!.stopRecorder();
    await _recorder!.closeAudioSession();
    _recorder = FlutterSoundRecorder();

    if (_recordFilePath != null) {
      File file = File(_recordFilePath!);
      if (await file.exists()) {
        print('File exists, size: ${await file.length()} bytes');
      } else {
        print('File does not exist');
      }
    }

    setState(() {
      _isRecording = false;
    });

    if (_recordFilePath != null) {
      uploadFile(File(_recordFilePath!));
    }
    print('녹음 종료');
  }

  void uploadFile(File file) async {
    setState(() {
      _isLoading = true;
    });
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://172.30.1.17:5000/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      print('Upload successful');
      response.stream.transform(utf8.decoder).join().then((value) {
        Map<String, dynamic> result = jsonDecode(value);
        setState(() {
          _key = result['key']; // 서버 응답에서 키값 추출
        });
      });
    } else {
      print('Upload failed');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _playRecording() async {
    if (_recordFilePath != null) {
      await _player!.startPlayer(fromURI: _recordFilePath);
    } else {
      print('No recording to play');
    }
    print('녹음 재생');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  child: const Text('녹음 시작'),
                ),
                Visibility(
                  visible: _isRecording,
                  child: ElevatedButton(
                    onPressed: _isRecording ? _stopRecording : null,
                    child: const Text('녹음 종료'),
                  ),
                ),
                Visibility(
                  visible: !_isRecording && _recordFilePath != null,
                  child: ElevatedButton(
                    onPressed: _playRecording,
                    child: const Icon(Icons.play_arrow),
                  ),
                ),
                if (_key != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '당신의 키: ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              TextSpan(
                                text: '$_key',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
    );
  }
}

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

class Combi extends StatelessWidget {
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
                    fontWeight: FontWeight.w800)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Combi()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 200,
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
