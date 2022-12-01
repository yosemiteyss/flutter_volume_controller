# Flutter Volume Controller

A Flutter plugin to control system volume and listen for volume changes on different platforms.

[![pub package](https://img.shields.io/pub/v/flutter_volume_controller.svg)](https://pub.dev/packages/flutter_volume_controller)


## Features

- Control system and media volumes.
- Listen for volume change events.

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Windows
- ✅ Linux

### Usage

#### Get current system volume
```dart
final volume = await FlutterVolumeController.getVolume();
```

#### Set the current system volume
```dart
await FlutterVolumeController.setVolume(0.5);
```

#### Increase system volume by a given step
```dart
await FlutterVolumeController.raiseVolume(0.2);
```

#### Decrease system volume by a given step
```dart
await FlutterVolumeController.lowerVolume(0.2);
```

#### Show system volume slider when changing volume (For Android and iOS)
```dart
FlutterVolumeController.showSystemUI = true;
```

#### Set the default audio stream type. (For Android)
```dart
await FlutterVolumeController.setAndroidAudioStream(stream: AudioStream.music);
```

#### Observe platform volume changes
- Use `emitOnStart` to control whether volume value should be emitted immediately after attaching the listener.

```dart
@override
void initState() {
  super.initState();
  // Ensure music stream in being controlled on Android.
  FlutterVolumeController.setAndroidAudioStream(stream: AudioStream.music);
  FlutterVolumeController.addListener(
    (volume) {
      debugPrint('Volume changed: $volume');
    },
    emitOnStart: true,
  );
}

@override
void dispose() {
  FlutterVolumeController.removeListener();
  super.dispose();
}
```

## Having Bugs?
- If you find any issues with this package, please free to report them on Github.