class OutputDevice {
  const OutputDevice({
    required this.id,
    required this.name,
    required this.volumeControl,
  });

  factory OutputDevice.fromJson(dynamic json) {
    return OutputDevice(
      id: json['id'] as String,
      name: json['name'] as String?,
      volumeControl: json['volumeControl'] as bool,
    );
  }

  final String id;
  final String? name;
  final bool volumeControl;

  @override
  String toString() {
    return 'Output Device: id: $id, name: $name, volumeControl: $volumeControl';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'volumeControl': volumeControl,
    };
  }
}
