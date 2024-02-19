import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:voicetrack/widgets/navigationbar.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class Record extends StatefulWidget {
  // const _Record({super.key});

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
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
        'POST', Uri.parse('http://127.0.0.1:5000/upload'));
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text('녹음 시작'),
                      onPressed: _isRecording ? null : _startRecording,
                    ),
                    Visibility(
                      visible: _isRecording,
                      child: ElevatedButton(
                        child: const Text('녹음 종료'),
                        onPressed: _isRecording ? _stopRecording : null,
                      ),
                    ),
                    Visibility(
                      visible: !_isRecording && _recordFilePath != null,
                      child: ElevatedButton(
                        child: const Text('녹음 재생'),
                        onPressed: _playRecording,
                      ),
                    ),
                    if (_key != null) Text('당신의 키 : $_key'),
                  ],
                ),
        ),
        bottomNavigationBar: Navigationbar(),
      ),
    );
  }
}
