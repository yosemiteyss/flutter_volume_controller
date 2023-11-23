package com.yosemiteyss.flutter_volume_controller

import android.media.AudioManager

enum class AudioStream {
    ACCESSIBILITY,
    ALARM,
    DTMF,
    MUSIC,
    NOTIFICATION,
    RING,
    SYSTEM,
    VOICE_CALL;

    val streamType: Int
        get() {
            return when (this) {
                ACCESSIBILITY -> AudioManager.STREAM_ACCESSIBILITY
                ALARM -> AudioManager.STREAM_ALARM
                DTMF -> AudioManager.STREAM_DTMF
                MUSIC -> AudioManager.STREAM_MUSIC
                NOTIFICATION -> AudioManager.STREAM_NOTIFICATION
                RING -> AudioManager.STREAM_RING
                SYSTEM -> AudioManager.STREAM_SYSTEM
                VOICE_CALL -> AudioManager.STREAM_VOICE_CALL
            }
        }
}