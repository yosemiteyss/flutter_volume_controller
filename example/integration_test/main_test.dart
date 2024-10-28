import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    runApp(const MaterialApp());
  });

  testWidgets('should get volume', (tester) async {
    final volume = await FlutterVolumeController.getVolume();
    expect(volume, isNotNull);
  });

  testWidgets('should set volume', (tester) async {
    const List<double> targets = [1.0, 0.0];

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      await _insertDelay();

      final actual = await FlutterVolumeController.getVolume();
      expect(actual, target);
    }
  });

  testWidgets('should raise volume', (tester) async {
    const before = 0.2;

    await FlutterVolumeController.setVolume(before);
    await _insertDelay();

    await FlutterVolumeController.raiseVolume(0.5);
    await _insertDelay();

    final actual = await FlutterVolumeController.getVolume();
    expect(actual, greaterThan(before));
  });

  testWidgets('should lower volume', (tester) async {
    const before = 0.8;

    await FlutterVolumeController.setVolume(before);
    await _insertDelay();

    await FlutterVolumeController.lowerVolume(0.5);
    await _insertDelay();

    final actual = await FlutterVolumeController.getVolume();
    expect(actual, lessThan(before));
  });

  testWidgets('should get mute', (tester) async {
    final isMuted = await FlutterVolumeController.getMute();
    expect(isMuted, isNotNull);
  });

  testWidgets('should set mute', (tester) async {
    const List<bool> targets = [true, false];

    for (final target in targets) {
      await FlutterVolumeController.setMute(target);
      await _insertDelay();

      final actual = await FlutterVolumeController.getMute();
      expect(actual, target);
    }
  });

  testWidgets('should toggle mute', (tester) async {
    const target = true;

    await FlutterVolumeController.setMute(!target);
    await _insertDelay();

    await FlutterVolumeController.toggleMute();
    await _insertDelay();

    final actual = await FlutterVolumeController.getMute();
    expect(actual, target);
  });

  if (Platform.isAndroid) {
    testWidgets('should set android audio stream', (tester) async {
      const target = AudioStream.music;

      await FlutterVolumeController.setAndroidAudioStream(stream: target);
      await _insertDelay();

      final actual = await FlutterVolumeController.getAndroidAudioStream();
      expect(actual, target);
    });
  }

  if (Platform.isIOS) {
    testWidgets('should set ios audio session category', (tester) async {
      const target = AudioSessionCategory.playback;

      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: target);
      await _insertDelay();

      final actual = await FlutterVolumeController.getIOSAudioSessionCategory();
      expect(actual, target);
    });
  }

  testWidgets('should receive volume event after adding listener',
      (tester) async {
    final List<double> targets = [0.0, 1.0, 0.0, 1.0, 0.0];
    final List<double> actual = [];

    await FlutterVolumeController.setVolume(targets[0]);
    await _insertDelay();

    FlutterVolumeController.addListener(actual.add);

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      await _insertDelay();
    }

    expect(actual, targets);

    FlutterVolumeController.removeListener();
  });

  testWidgets('should receive no new volume event after removing listener',
      (tester) async {
    final List<double> targets = [0.0, 1.0, 0.0];
    final List<double> actual = [];

    await FlutterVolumeController.setVolume(targets[0]);
    await _insertDelay();

    FlutterVolumeController.addListener(actual.add);

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      await _insertDelay();
    }

    expect(actual, targets);

    FlutterVolumeController.removeListener();

    await FlutterVolumeController.setVolume(1.0);
    await _insertDelay();

    expect(actual, targets);
  });

  if (Platform.isIOS) {
    testWidgets('should keep audio session category after get volume',
        (tester) async {
      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: AudioSessionCategory.playback);
      final before = await FlutterVolumeController.getIOSAudioSessionCategory();

      await FlutterVolumeController.getVolume();
      final after = await FlutterVolumeController.getIOSAudioSessionCategory();

      expect(after, before);
    });
  }

  if (Platform.isIOS) {
    testWidgets('should keep audio session category after get mute',
        (tester) async {
      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: AudioSessionCategory.playback);
      final before = await FlutterVolumeController.getIOSAudioSessionCategory();

      await FlutterVolumeController.getMute();
      final after = await FlutterVolumeController.getIOSAudioSessionCategory();

      expect(after, before);
    });
  }

  if (Platform.isIOS) {
    testWidgets('should keep audio session category after set mute',
        (tester) async {
      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: AudioSessionCategory.playback);
      final before = await FlutterVolumeController.getIOSAudioSessionCategory();

      await FlutterVolumeController.setMute(true);
      final after = await FlutterVolumeController.getIOSAudioSessionCategory();

      expect(after, before);
    });

    testWidgets(
        'should keep audio session category after returning from background',
        (tester) async {
      const before = AudioSessionCategory.playback;
      await FlutterVolumeController.setIOSAudioSessionCategory(
          category: before);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      final after = await FlutterVolumeController.getIOSAudioSessionCategory();
      expect(after, before);
    });
  }
}

Future<void> _insertDelay() async {
  await Future.delayed(const Duration(milliseconds: 100));
}
