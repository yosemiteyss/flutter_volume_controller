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
  OutputDevice? _outputDevice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isIOS) {
        await _loadIOSAudioSessionCategory();
      }
      if (Platform.isAndroid) {
        await _loadAndroidAudioStream();
      }
    });
    FlutterVolumeController.addListener((volume) {
      setState(() {
        _currentVolume = volume;
      });
    });

    FlutterVolumeController.addDefaultOutputDeviceListener((device) {
      setState(() {
        _outputDevice = device;
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
                  FlutterVolumeController.updateShowSystemUI(
                      !FlutterVolumeController.showSystemUI);
                  _showSnackBar(
                    'Show system ui: ${FlutterVolumeController.showSystemUI}',
                  );
                },
              ),
            _ActionItem(
              title: 'Show or hide system ui',
              onPressed: () {
                FlutterVolumeController.showSystemUI =
                    !FlutterVolumeController.showSystemUI;
                _showSnackBar(
                  'Show system ui: ${FlutterVolumeController.showSystemUI}',
                );
              },
            ),
          if (Platform.isAndroid) ...[
            _ActionItem(
              title: 'Switch audio stream',
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
            _ActionItem(
              title: 'Get audio stream',
              onPressed: () async {
                final stream =
                    await FlutterVolumeController.getAndroidAudioStream();
                _showSnackBar('Audio stream: $stream');
              },
            ),
          ],
          if (Platform.isIOS) ...[
            _ActionItem(
              title: 'Switch audio session category',
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
            _ActionItem(
              title: 'Get audio session category',
              onPressed: () async {
                final category =
                    await FlutterVolumeController.getIOSAudioSessionCategory();
                _showSnackBar('Audio session category: $category');
              },
            ),
          ],
          _ActionItem(
            title: 'Get Volume',
            onPressed: () async {
              final volume = await FlutterVolumeController.getVolume(
                stream: _audioStream,
              );
              _showSnackBar('Current Volume: $volume');
            },
          ),
          _ActionItem(
            title: 'Set Volume to 50%',
            onPressed: () {
              FlutterVolumeController.setVolume(
                0.5,
                stream: _audioStream,
              );
            },
          ),
          _ActionItem(
            title: 'Raise Volume',
            onPressed: () {
              FlutterVolumeController.raiseVolume(
                0.2,
                stream: _audioStream,
              );
            },
          ),
          _ActionItem(
            title: 'Lower Volume',
            onPressed: () {
              FlutterVolumeController.lowerVolume(
                0.2,
                stream: _audioStream,
              );
            },
          ),
          _ActionItem(
            title: 'Get mute',
            onPressed: () async {
              final isMuted = await FlutterVolumeController.getMute();
              _showSnackBar('Muted: $isMuted');
            },
          ),
          _ActionItem(
            title: 'Set mute',
            onPressed: () {
              FlutterVolumeController.setMute(
                true,
                stream: _audioStream,
              );
            },
          ),
          _ActionItem(
            title: 'Set unmute',
            onPressed: () {
              FlutterVolumeController.setMute(
                false,
                stream: _audioStream,
              );
            },
          ),
          _ActionItem(
            title: 'Toggle mute',
            onPressed: () {
              FlutterVolumeController.toggleMute(stream: _audioStream);
            },
          ),
          if (Platform.isMacOS) ...[
            _ActionItem(
              title: 'Get default audio device',
              onPressed: () async {
                final device =
                    await FlutterVolumeController.getDefaultOutputDevice();
                _showSnackBar('Default device: $device');
              },
            ),
            _ActionItem(
              title: 'Get output device list',
              onPressed: () async {
                final deviceList =
                    await FlutterVolumeController.getOutputDeviceList();
                _showSnackBar('Device list: $deviceList');
              },
            ),
          ],
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
          if (Platform.isMacOS)
            Text(
              '$_outputDevice',
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

  Future<void> _loadIOSAudioSessionCategory() async {
    final category = await FlutterVolumeController.getIOSAudioSessionCategory();
    if (category != null) {
      setState(() {
        _audioSessionCategory = category;
      });
    }
  }

  Future<void> _loadAndroidAudioStream() async {
    final audioStream = await FlutterVolumeController.getAndroidAudioStream();
    if (audioStream != null) {
      setState(() {
        _audioStream = _audioStream;
      });
    }
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(title),
        ),
      ),
    );
  }
}
