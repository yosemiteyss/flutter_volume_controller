import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AudioStream _audioStream = AudioStream.music;
  AudioSessionCategory _audioSessionCategory = AudioSessionCategory.ambient;
  double _currentVolume = 0.0;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Volume Controller Example'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            Center(
              child: ElevatedButton(
                child: const Text('Show or hide system ui'),
                onPressed: () {
                  FlutterVolumeController.showSystemUI =
                      !FlutterVolumeController.showSystemUI;
                  _showSnackBar(
                    'Show system ui: ${FlutterVolumeController.showSystemUI}',
                  );
                },
              ),
            ),
          if (Platform.isAndroid) ...[
            Center(
              child: ElevatedButton(
                child: const Text('Switch audio stream'),
                onPressed: () async {
                  final stream = await _pickAndroidAudioStream(context);
                  if (stream != null) {
                    setState(() {
                      _audioStream = stream;
                    });
                    await FlutterVolumeController.setAndroidAudioStream(
                      stream: stream,
                    );
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Get audio stream'),
                onPressed: () async {
                  final stream =
                      await FlutterVolumeController.getAndroidAudioStream();
                  _showSnackBar('Audio stream: $stream');
                },
              ),
            ),
          ],
          if (Platform.isIOS) ...[
            Center(
              child: ElevatedButton(
                child: const Text('Switch audio session category'),
                onPressed: () async {
                  final category = await _pickIOSAudioSessionCategory(context);
                  if (category != null) {
                    setState(() {
                      _audioSessionCategory = category;
                    });
                    await FlutterVolumeController.setIOSAudioSessionCategory(
                      category: category,
                    );
                  }
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                child: const Text('Get audio session category'),
                onPressed: () async {
                  final category = await FlutterVolumeController
                      .getIOSAudioSessionCategory();
                  _showSnackBar('Audio session category: $category');
                },
              ),
            ),
          ],
          Center(
            child: ElevatedButton(
              child: const Text('Get Volume'),
              onPressed: () async {
                final volume = await FlutterVolumeController.getVolume(
                  stream: _audioStream,
                );
                _showSnackBar('Current Volume: $volume');
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
              child: const Text('Get mute'),
              onPressed: () async {
                final isMuted = await FlutterVolumeController.getMute();
                _showSnackBar('Muted: $isMuted');
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
          Center(
            child: ElevatedButton(
              child: const Text('Toggle mute'),
              onPressed: () {
                FlutterVolumeController.toggleMute(stream: _audioStream);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Current Volume: $_currentVolume',
            textAlign: TextAlign.center,
          ),
          if (Platform.isAndroid)
            Text(
              'Audio Stream: $_audioStream',
              textAlign: TextAlign.center,
            ),
          if (Platform.isIOS)
            Text(
              'Audio Session Category: $_audioSessionCategory',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Future<AudioStream?> _pickAndroidAudioStream(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: AudioStream.values.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(AudioStream.values[index].name),
              onTap: () {
                Navigator.of(context).maybePop(AudioStream.values[index]);
              },
            );
          },
        );
      },
    );
  }

  Future<AudioSessionCategory?> _pickIOSAudioSessionCategory(
    BuildContext context,
  ) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: AudioSessionCategory.values.length,
          itemBuilder: (_, index) {
            return ListTile(
              title: Text(AudioSessionCategory.values[index].name),
              onTap: () {
                Navigator.of(context).maybePop(
                  AudioSessionCategory.values[index],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
