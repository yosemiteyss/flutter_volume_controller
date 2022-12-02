enum FlutterVolumeControllerError {
  getVolume('1000'),
  setVolume('1001'),
  raiseVolume('1002'),
  lowerVolume('1003'),
  registerVolumeListener('1004'),
  getMute('1005'),
  setMute('1006'),
  toggleMute('1007'),
  setAndroidAudioStream('1008');

  const FlutterVolumeControllerError(this.code);

  final String code;
}
