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

  /// Stream for listening volume change events.
  static StreamSubscription<double>? _volumeListener;

  /// Control whether the system UI (volume bar) is visible when changing
  /// volume.
  /// This settings only works on Android and iOS.
  static bool showSystemUI = true;

  /// Get the current volume percent.
  /// Use [stream] to set the audio stream type on Android.
  static Future<double?> getVolume({
    AudioStream stream = AudioStream.music,
  }) async {
    return await methodChannel.invokeMethod<double>(MethodName.getVolume, {
      if (Platform.isAndroid) MethodArg.audioStream: stream.index,
    });
  }

  /// Set the [volume] percent from 0.0 to 1.0.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> setVolume(
    double volume, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.setVolume, {
      MethodArg.volume: volume,
      if (Platform.isAndroid || Platform.isIOS)
        MethodArg.showSystemUI: showSystemUI,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Increase the volume percent by a given [step] from 0.0 to 1.0.
  /// When [step] is set to null, it will uses the default system stepping value
  /// on Android. On iOS, macOS, Linux, if [step] is not defined, the default
  /// stepping value is set to 0.15.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> raiseVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.raiseVolume, {
      if (Platform.isAndroid || Platform.isIOS)
        MethodArg.showSystemUI: showSystemUI,
      if (step != null) MethodArg.step: step,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Reduce the volume percent by a given [step] from 0.0 to 1.0.
  /// When [step] is set to null, it will uses the default system stepping value
  /// on Android. On iOS, macOS, Linux, if [step] is not defined, the default
  /// stepping value is set to 0.15.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> lowerVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.lowerVolume, {
      if (Platform.isAndroid || Platform.isIOS)
        MethodArg.showSystemUI: showSystemUI,
      if (step != null) MethodArg.step: step,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Check if volume is muted.
  /// Use [stream] to set the audio stream type on Android.
  static Future<bool?> getMute({
    AudioStream stream = AudioStream.music,
  }) async {
    return await methodChannel.invokeMethod<bool>(MethodName.getMute, {
      if (Platform.isAndroid) MethodArg.audioStream: stream.index,
    });
  }

  /// Set volume to mute or unmute.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> setMute(
    bool isMuted, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.setMute, {
      MethodArg.isMuted: isMuted,
      if (Platform.isAndroid || Platform.isIOS)
        MethodArg.showSystemUI: showSystemUI,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Toggle the volume mute state.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> toggleMute({
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(MethodName.toggleMute, {
      if (Platform.isAndroid || Platform.isIOS)
        MethodArg.showSystemUI: showSystemUI,
      if (Platform.isAndroid) MethodArg.audioStream: stream.index
    });
  }

  /// Set the default audio stream on Android.
  /// Should calling this method before [addVolumeListener] to ensure the correct
  /// audio stream is being controlled.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> setAndroidAudioStream({
    AudioStream stream = AudioStream.music,
  }) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod(
        MethodName.setAndroidAudioStream,
        {MethodArg.audioStream: stream.index},
      );
    }
  }

  /// Listen for volume changes.
  /// Use [emitOnStart] to control whether volume value should be emitted
  /// immediately right after the listener is attached.
  /// Use [stream] to set the audio stream type on Android.
  static StreamSubscription<double> addListener(
    ValueChanged<double> onChanged, {
    AudioStream stream = AudioStream.music,
    bool emitOnStart = true,
  }) {
    if (_volumeListener != null) {
      removeListener();
    }

    final listener = eventChannel
        .receiveBroadcastStream({
          if (Platform.isAndroid) MethodArg.audioStream: stream.index,
          MethodArg.emitOnStart: emitOnStart,
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
