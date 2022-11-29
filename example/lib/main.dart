import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  AudioStream _audioStream = AudioStream.music;
  double _currentVolume = 0.0;

  @override
  void initState() {
    super.initState();
    FlutterVolumeController.setAndroidAudioStream(stream: AudioStream.music);
    FlutterVolumeController.addListener((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Volume Controller Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (Platform.isAndroid || Platform.isIOS)
              Center(
                child: ElevatedButton(
                  child: const Text('Show or hide system ui'),
                  onPressed: () {
                    FlutterVolumeController.showSystemUI =
                        !FlutterVolumeController.showSystemUI;
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Show system ui: ${FlutterVolumeController.showSystemUI}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            if (Platform.isAndroid)
              Center(
                child: ElevatedButton(
                  child: const Text('Switch audio stream'),
                  onPressed: () {
                    _audioStream = AudioStream.values[_audioStream.index ^ 1];
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Audio stream: ${_audioStream.name}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            Center(
              child: ElevatedButton(
                child: const Text('Get Volume'),
                onPressed: () async {
                  final volume = await FlutterVolumeController.getVolume(
                    stream: _audioStream,
                  );
                  if (mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Current Volume: $volume (${_audioStream.name})',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Set Volume to 50%'),
                onPressed: () {
                  FlutterVolumeController.setVolume(
                    0.5,
                    stream: _audioStream,
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Raise Volume'),
                onPressed: () {
                  FlutterVolumeController.raiseVolume(
                    0.2,
                    stream: _audioStream,
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Lower Volume'),
                onPressed: () {
                  FlutterVolumeController.lowerVolume(
                    0.2,
                    stream: _audioStream,
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Set mute'),
                onPressed: () {
                  FlutterVolumeController.setMute(
                    true,
                    stream: _audioStream,
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Set unmute'),
                onPressed: () {
                  FlutterVolumeController.setMute(
                    false,
                    stream: _audioStream,
                  );
                },
              ),
            ),
            Text('Current Volume: $_currentVolume'),
          ],
        ),
      ),
    );
  }
}
