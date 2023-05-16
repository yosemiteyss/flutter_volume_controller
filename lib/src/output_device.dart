import 'package:json_annotation/json_annotation.dart';

part 'output_device.g.dart';

@JsonSerializable()
class OutputDevice {
  const OutputDevice({required this.id, required this.name});

  factory OutputDevice.fromJson(Map<String, dynamic> json) =>
      _$OutputDeviceFromJson(json);

  final String id;
  final String? name;

  Map<String, dynamic> toJson() => _$OutputDeviceToJson(this);

  @override
  String toString() {
    return '[OutputDevice] id: $id, name: $name';
  }
}
