# flutter_volume_controller

A Flutter plugin to control system volume.

## Features
Notes that some of the features may not be available to all supported platforms.

### Volume Controls

- `FlutterVolumeController.getVolume()`: Get the current volume
- `FlutterVolumeController.setVolume()`: Set the current volume
- `FlutterVolumeController.raiseVolume()`: Increase the current volume
- `FlutterVolumeController.lowerVolume()`: Decrease the current volume
- `FlutterVolumeController.showSystemUI`: Control system UI when volume changes
- `FlutterVolumeController.setAndroidAudioStream()`: Set the default audio stream on Android

### Observe Volume

- `FlutterVolumeController.addListener()`: Observe volume changes

```dart
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

@override
void initState() {
  super.initState();
  // Ensure music stream in being controlled on Android.
  FlutterVolumeController.setAndroidAudioStream(stream: AudioStream.music);
  FlutterVolumeController.addListener((volume) {
    debugPrint('Volume changed: $volume');
  });
}

@override
void dispose() {
  FlutterVolumeController.removeListener();
  super.dispose();
}
```
