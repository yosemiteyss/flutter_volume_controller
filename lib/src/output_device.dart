import 'package:json_annotation/json_annotation.dart';

part 'output_device.g.dart';

@JsonSerializable()
class OutputDevice {
  const OutputDevice({
    required this.id,
    required this.name,
    required this.volumeControl,
  });

  factory OutputDevice.fromJson(Map<String, dynamic> json) =>
      _$OutputDeviceFromJson(json);

  final String id;
  final String? name;
  final bool volumeControl;

  Map<String, dynamic> toJson() => _$OutputDeviceToJson(this);

  @override
  String toString() {
    return 'Output Device: id: $id, name: $name, volumeControl: $volumeControl';
  }
}
