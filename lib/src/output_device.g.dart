// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutputDevice _$OutputDeviceFromJson(Map<String, dynamic> json) => OutputDevice(
      id: json['id'] as String,
      name: json['name'] as String?,
      volumeControl: json['volumeControl'] as bool,
    );

Map<String, dynamic> _$OutputDeviceToJson(OutputDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'volumeControl': instance.volumeControl,
    };
