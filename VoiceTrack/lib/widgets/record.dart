import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
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
  List<String> keys = [];

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

    audioPlayer.play(AssetSource('sounds/ailoading.mp3'));

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://172.30.1.17:5000/record'));
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
    audioPlayer.stop();
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
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/image/cat2.png',
                  width: 280,
                  height: 320,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "AI가 돌아가고 이쓰요!",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold, // 볼드체
                      fontSize: 18, // 글자 크기
                    ),
                  ),
                ),
              ],
            )
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
