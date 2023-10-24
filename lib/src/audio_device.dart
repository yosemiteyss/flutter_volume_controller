import 'package:flutter_volume_controller/src/audio_device_type.dart';

class AudioDevice {
  const AudioDevice({
    required this.id,
    required this.name,
    required this.volumeControl,
    required this.type,
  });

  factory AudioDevice.fromJson(dynamic json) {
    return AudioDevice(
      id: json['id'] as String,
      name: json['name'] as String?,
      volumeControl: json['volumeControl'] as bool,
      type: AudioDeviceType.fromValue(json['type'] as int),
    );
  }

  /// The unique id of the device.
  final String id;

  /// The name of the device.
  final String? name;

  /// Whether the device supports volume control.
  final bool volumeControl;

  /// The type of the device.
  final AudioDeviceType type;

  @override
  String toString() {
    return 'Audio Device: id: $id, name: $name, volumeControl: $volumeControl';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'volumeControl': volumeControl,
    };
  }
}
