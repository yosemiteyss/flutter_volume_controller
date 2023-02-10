package com.yosemiteyss.flutter_volume_controller

import android.media.AudioManager

enum class AudioStream {
    VOICE_CALL,
    SYSTEM,
    RING,
    MUSIC,
    ALARM;

    val streamType: Int
        get() {
            return when (this) {
                VOICE_CALL -> AudioManager.STREAM_VOICE_CALL
                SYSTEM -> AudioManager.STREAM_SYSTEM
                RING -> AudioManager.STREAM_RING
                MUSIC -> AudioManager.STREAM_MUSIC
                ALARM -> AudioManager.STREAM_ALARM
            }
        }
}