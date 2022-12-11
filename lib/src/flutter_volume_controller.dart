import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/src/audio_stream.dart';
import 'package:flutter_volume_controller/src/constants.dart';

/// A Flutter plugin to control system volume and listen for volume changes on different platforms.
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

  /// Listener for volume change events.
  static StreamSubscription<double>? _volumeListener;

  /// Control system UI visibility.
  /// Set to `true` to display volume slider when changing volume.
  /// This settings only works on Android and iOS.
  static bool showSystemUI = true;

  /// Get the current volume level. From 0.0 to 1.0.
  /// Use [stream] to set the audio stream type on Android.
  static Future<double?> getVolume({
    AudioStream stream = AudioStream.music,
  }) async {
    final receivedValue = await methodChannel.invokeMethod<String>(
      MethodName.getVolume,
      {
        if (Platform.isAndroid) MethodArg.audioStream: stream.index,
      },
    );

    return receivedValue != null ? double.parse(receivedValue) : null;
  }

  /// Set the volume level. From 0.0 to 1.0.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> setVolume(
    double volume, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(
      MethodName.setVolume,
      {
        MethodArg.volume: volume,
        if (Platform.isAndroid || Platform.isIOS)
          MethodArg.showSystemUI: showSystemUI,
        if (Platform.isAndroid) MethodArg.audioStream: stream.index
      },
    );
  }

  /// Increase the volume level by [step]. From 0.0 to 1.0.
  /// On Android and Windows, when [step] is set to null, it will uses the
  /// default system stepping value.
  /// On iOS, macOS, Linux, if [step] is not defined, the default
  /// stepping value is set to 0.15.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> raiseVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(
      MethodName.raiseVolume,
      {
        if (Platform.isAndroid || Platform.isIOS)
          MethodArg.showSystemUI: showSystemUI,
        if (step != null) MethodArg.step: step,
        if (Platform.isAndroid) MethodArg.audioStream: stream.index
      },
    );
  }

  /// Decrease the volume level by [step]. From 0.0 to 1.0.
  /// On Android and Windows, when [step] is set to null, it will uses the
  /// default system stepping value.
  /// On iOS, macOS, Linux, if [step] is not defined, the default
  /// stepping value is set to 0.15.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> lowerVolume(
    double? step, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(
      MethodName.lowerVolume,
      {
        if (Platform.isAndroid || Platform.isIOS)
          MethodArg.showSystemUI: showSystemUI,
        if (step != null) MethodArg.step: step,
        if (Platform.isAndroid) MethodArg.audioStream: stream.index
      },
    );
  }

  /// Check if the volume is muted.
  /// On Android and iOS, we check if the current volume level is already
  /// dropped to zero.
  /// On macOS, Windows, Linux, we check if the mute switch is turned on.
  /// Use [stream] to set the audio stream type on Android.
  static Future<bool?> getMute({
    AudioStream stream = AudioStream.music,
  }) async {
    return await methodChannel.invokeMethod<bool>(
      MethodName.getMute,
      {
        if (Platform.isAndroid) MethodArg.audioStream: stream.index,
      },
    );
  }

  /// Mute or unmute the volume.
  /// On Android and iOS, we either set the volume to zero or revert to the previous level.
  /// On macOS, Windows, Linux, we control the mute switch. Volume will be restored
  /// once it's unmuted.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> setMute(
    bool isMuted, {
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(
      MethodName.setMute,
      {
        MethodArg.isMuted: isMuted,
        if (Platform.isAndroid || Platform.isIOS)
          MethodArg.showSystemUI: showSystemUI,
        if (Platform.isAndroid) MethodArg.audioStream: stream.index
      },
    );
  }

  /// Toggle between the volume mute and unmute state.
  /// Please refers to [setMute] for platform behaviors.
  /// Use [stream] to set the audio stream type on Android.
  static Future<void> toggleMute({
    AudioStream stream = AudioStream.music,
  }) async {
    await methodChannel.invokeMethod(
      MethodName.toggleMute,
      {
        if (Platform.isAndroid || Platform.isIOS)
          MethodArg.showSystemUI: showSystemUI,
        if (Platform.isAndroid) MethodArg.audioStream: stream.index
      },
    );
  }

  /// Set the default audio stream on Android.
  /// This method should be called to ensure that volume controls adjust the correct stream.
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
        .distinct()
        .map((volume) => double.parse(volume))
        .listen(onChanged);

    _volumeListener = listener;
    return listener;
  }

  /// Remove the volume listener.
  static void removeListener() {
    _volumeListener?.cancel();
    _volumeListener = null;
  }
}
