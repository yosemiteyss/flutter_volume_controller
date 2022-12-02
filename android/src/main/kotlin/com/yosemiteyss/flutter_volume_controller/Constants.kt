package com.yosemiteyss.flutter_volume_controller

object MethodName {
    const val GET_VOLUME = "getVolume"
    const val SET_VOLUME = "setVolume"
    const val RAISE_VOLUME = "raiseVolume"
    const val LOWER_VOLUME = "lowerVolume"
    const val SET_ANDROID_AUDIO_STREAM = "setAndroidAudioStream"
    const val GET_MUTE = "getMute"
    const val SET_MUTE = "setMute"
}

object MethodArg {
    const val VOLUME = "volume"
    const val STEP = "step"
    const val SHOW_SYSTEM_UI = "showSystemUI"
    const val AUDIO_STREAM = "audioStream"
    const val EMIT_ON_START = "emitOnStart"
    const val IS_MUTED = "isMuted"
}

object ErrorCode {
    const val DEFAULT = "1000"
}

object ErrorMessage {
    const val GET_VOLUME = "Failed to get volume"
    const val SET_VOLUME = "Failed to set volume"
    const val RAISE_VOLUME = "Failed to raise volume"
    const val LOWER_VOLUME = "Failed to lower volume"
    const val REGISTER_LISTENER = "Failed to register volume listener"
    const val GET_MUTE = "Failed to get mute"
    const val SET_MUTE = "Failed to set mute"
}