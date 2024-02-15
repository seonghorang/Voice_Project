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
  bool _isRecording = false;
  String? _recordFilePath;
  String? _key;
  bool _isLoading = false;

  void _startRecording() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      await _recorder!.openAudioSession();
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDirectory.path;
      _recordFilePath = '$appDocPath/record.aac';
      await _recorder!.startRecorder(
        toFile: _recordFilePath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      print('Microphone permission not granted');
      //여기에 필요한 알림 또는 동작을 추가합니다.
    }
  }

  void _stopRecording() async {
    await _recorder!.stopRecorder();
    await _recorder!.closeAudioSession();
    _recorder = null;

    setState(() {
      _isRecording = false;
    });

    if (_recordFilePath != null) {
      uploadFile(File(_recordFilePath!));
    }
  }

  void uploadFile(File file) async {
    setState(() {
      _isLoading = true;
    });
    var request =
        http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/upload'));
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
                    if (_key != null) Text('당신의 키 : $_key'),
                  ],
                ),
        ),
        bottomNavigationBar: Navigationbar(),
      ),
    );
  }
}
