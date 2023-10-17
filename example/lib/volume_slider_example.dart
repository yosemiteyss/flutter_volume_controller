import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

void main() => runApp(const VolumeSliderExample());

class VolumeSliderExample extends StatelessWidget {
  const VolumeSliderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const VolumeSlider(),
    );
  }
}

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0;
  bool _showSystemSlider = true;

  @override
  void initState() {
    super.initState();
    FlutterVolumeController.addListener((volume) {
      setState(() {
        _volume = volume;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volume Slider'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slider(
            value: _volume,
            onChanged: (value) {
              setState(() {
                FlutterVolumeController.setVolume(value);
              });
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Volume: ${_volume.toString()}',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Show system slider'),
              Checkbox(
                value: _showSystemSlider,
                onChanged: (value) {
                  final checked = value ?? true;
                  FlutterVolumeController.updateShowSystemUI(checked);
                  setState(() {
                    _showSystemSlider = checked;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
