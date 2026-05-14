export class MethodName {
  static GET_VOLUME = "getVolume"
  static SET_VOLUME = "setVolume"
  static RAISE_VOLUME = "raiseVolume"
  static LOWER_VOLUME = "lowerVolume"
  static SET_ANDROID_AUDIO_STREAM = "setAndroidAudioStream"
  static GET_ANDROID_AUDIO_STREAM = "getAndroidAudioStream"
  static GET_MUTE = "getMute"
  static SET_MUTE = "setMute"
  static TOGGLE_MUTE = "toggleMute"
  static UPDATE_SHOW_SYSTEM_UI = "updateShowSystemUI"
}

export class MethodArg {
  static VOLUME = "volume"
  static STEP = "step"
  static SHOW_SYSTEM_UI = "showSystemUI"
  static AUDIO_STREAM = "audioStream"
  static EMIT_ON_START = "emitOnStart"
  static IS_MUTED = "isMuted"
}

export class ErrorCode {
  static GET_VOLUME = "1000"
  static SET_VOLUME = "1001"
  static RAISE_VOLUME = "1002"
  static LOWER_VOLUME = "1003"
  static REGISTER_VOLUME_LISTENER = "1004"
  static GET_MUTE = "1005"
  static SET_MUTE = "1006"
  static TOGGLE_MUTE = "1007"
  static SET_ANDROID_AUDIO_STREAM = "1008"
  static GET_ANDROID_AUDIO_STREAM = "1010"
}

export class ErrorMessage {
  static GET_VOLUME = "Failed to get volume"
  static SET_VOLUME = "Failed to set volume"
  static RAISE_VOLUME = "Failed to raise volume"
  static LOWER_VOLUME = "Failed to lower volume"
  static REGISTER_VOLUME_LISTENER = "Failed to register volume listener"
  static GET_MUTE = "Failed to get mute"
  static SET_MUTE = "Failed to set mute"
  static TOGGLE_MUTE = "Failed to toggle mute"
  static SET_ANDROID_AUDIO_STREAM = "Failed to set audio stream"
  static GET_ANDROID_AUDIO_STREAM = "Failed to get audio stream"
}