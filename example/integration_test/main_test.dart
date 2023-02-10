import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    runApp(const _TestApp());
  });

  testWidgets('should get volume', (tester) async {
    final volume = await FlutterVolumeController.getVolume();
    expect(volume, isNotNull);
  });

  testWidgets('should set volume', (tester) async {
    const List<double> targets = [1.0, 0.0];

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      final actual = await FlutterVolumeController.getVolume();
      expect(actual, target);
    }
  });

  testWidgets('should raise volume', (tester) async {
    const before = 0.2;
    await FlutterVolumeController.setVolume(before);
    await FlutterVolumeController.raiseVolume(0.5);

    final actual = await FlutterVolumeController.getVolume();
    expect(actual, greaterThan(before));
  });

  testWidgets('should lower volume', (tester) async {
    const before = 0.8;
    await FlutterVolumeController.setVolume(before);
    await FlutterVolumeController.lowerVolume(0.5);

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
      final actual = await FlutterVolumeController.getMute();
      expect(actual, target);
    }
  });

  testWidgets('should toggle mute', (tester) async {
    const target = true;
    await FlutterVolumeController.setMute(!target);

    await FlutterVolumeController.toggleMute();
    final actual = await FlutterVolumeController.getMute();
    expect(actual, target);
  });

  /// TODO: add test for [FlutterVolumeController.setAndroidAudioStream].

  /// TODO: add test for [FlutterVolumeController.setIOSAudioSessionCategory].

  testWidgets('should receive volume event after adding listener',
      (tester) async {
    final List<double> targets = [0.0, 1.0, 0.0, 1.0, 0.0];
    final List<double> actual = [];

    FlutterVolumeController.addListener(actual.add, emitOnStart: false);

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    expect(actual, targets);
  });

  testWidgets('should receive no new volume event after removing listener',
      (tester) async {
    final List<double> targets = [0.0, 1.0, 0.0];
    final List<double> actual = [];

    FlutterVolumeController.addListener(actual.add, emitOnStart: false);

    for (final target in targets) {
      await FlutterVolumeController.setVolume(target);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    expect(actual, targets);

    FlutterVolumeController.removeListener();
    await FlutterVolumeController.setVolume(1.0);
    expect(actual, targets);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(),
    );
  }
}
