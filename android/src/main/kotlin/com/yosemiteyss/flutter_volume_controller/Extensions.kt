package com.yosemiteyss.flutter_volume_controller

import android.content.Context
import android.media.AudioManager

internal fun AudioManager.getVolume(audioStream: AudioStream): Double {
    val current = getStreamVolume(audioStream.streamType)
    val max = getStreamMaxVolume(audioStream.streamType)
    return current.toDouble() / max
}

internal val Context.audioManager: AudioManager
    get() = getSystemService(Context.AUDIO_SERVICE) as AudioManager