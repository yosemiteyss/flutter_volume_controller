enum AudioDeviceType {
  input(1),
  output(2);

  const AudioDeviceType(this.value);

  final int value;

  static AudioDeviceType fromValue(int value) {
    return AudioDeviceType.values
        .firstWhere((element) => element.value == value);
  }
}
