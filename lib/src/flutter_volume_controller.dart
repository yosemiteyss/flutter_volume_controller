import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/src/audio_stream.dart';
import 'package:flutter_volume_controller/src/constants.dart';

class FlutterVolumeController {
  const FlutterVolumeController._();

  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'com.yosemiteyss.flutter_volume_controller/method',
  );

  @visibleForTesting
  static const EventChannel eventChannel = EventChannel(
    'com.yosemiteyss.flutter_volume_controller/event',
  );

  static StreamSubscription<double>? _volumeListener;

  /// Control whether the system UI (volume bar) is visible when changing
  /// volume.
  static bool showSystemUI = true;

  /// Get the current volume percent.
  /// Note: audio stream setting only works on Android.
  static Future<double?> getVolume({
    AudioStream stream = AudioStream.music,
  }) async {
    return await methodChannel.invokeMethod<double>(MethodName.getVolume, {
      if (Platform.isAndroid) MethodArg.audioStream: stream.index,
    });
  }

  /// Set the volume percent from 0.0 to 1.0.
  /// Note: audio stream setting only works on Android.
  static Future<void> setVolume(
    double volume, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArg.volume: volume,
      MethodArg.showSystemUI: showSystemUI,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Increase the volume percent by a given [step] from 0.0 to 1.0.
  /// When [step] is set to null, it will uses the default system stepping value
  /// on Android. On iOS, the default stepping value is set to 0.15.
  /// Note: audio stream setting only works on Android.
  static Future<void> raiseVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.raiseVolume, {
      MethodArg.showSystemUI: showSystemUI,
      if (step != null) MethodArg.step: step,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Reduce the volume percent by a given [step] from 0.0 to 1.0.
  /// When [step] is set to null, it will uses the default system stepping value
  /// on Android. On iOS, the default stepping value is set to 0.15.
  /// Note: audio stream setting only works on Android.
  static Future<void> lowerVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.lowerVolume, {
      MethodArg.showSystemUI: showSystemUI,
      if (step != null) MethodArg.step: step,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Listen for volume changes.
  static StreamSubscription<double> addListener(
    Function(double volume) onChanged, {
    AudioStream stream = AudioStream.music,
  }) {
    if (_volumeListener != null) {
      removeListener();
    }

    final listener = eventChannel
        .receiveBroadcastStream({
          if (Platform.isAndroid) MethodArg.audioStream: stream.index,
        })
        .map((volume) => volume as double)
        .listen(onChanged);

    _volumeListener = listener;
    return listener;
  }

  /// Remove the volume changes listener.
  static void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }
}
