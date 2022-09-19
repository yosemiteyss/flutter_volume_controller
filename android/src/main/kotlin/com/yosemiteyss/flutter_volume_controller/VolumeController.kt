package com.yosemiteyss.flutter_volume_controller

import android.media.AudioManager

class VolumeController(private val audioManager: AudioManager) {
    fun getVolume(audioStream: AudioStream): Double {
        return audioManager.getVolume(audioStream)
    }

    fun setVolume(volume: Double, showSystemUI: Boolean, audioStream: AudioStream) {
        val max = audioManager.getStreamMaxVolume(audioStream.streamType)
        audioManager.setStreamVolume(
            audioStream.streamType,
            (max * volume).toInt(),
            if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0
        )
    }

    fun raiseVolume(step: Double?, showSystemUI: Boolean, audioStream: AudioStream) {
        if (step == null) {
            audioManager.adjustStreamVolume(
                audioStream.streamType,
                AudioManager.ADJUST_RAISE,
                if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0
            )
        } else {
            val target = getVolume(audioStream) + step
            setVolume(target, showSystemUI, audioStream)
        }
    }

    fun lowerVolume(step: Double?, showSystemUI: Boolean, audioStream: AudioStream) {
        if (step == null) {
            audioManager.adjustStreamVolume(
                audioStream.streamType,
                AudioManager.ADJUST_LOWER,
                if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0
            )
        } else {
            val target = getVolume(audioStream) - step
            setVolume(target, showSystemUI, audioStream)
        }
    }
}


