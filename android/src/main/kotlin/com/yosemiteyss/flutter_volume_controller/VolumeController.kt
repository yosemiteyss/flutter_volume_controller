package com.yosemiteyss.flutter_volume_controller

import android.media.AudioManager
import android.os.Build

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

    fun getMute(audioStream: AudioStream): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioManager.isStreamMute(audioStream.streamType)
        } else {
            audioManager.getStreamVolume(audioStream.streamType) == 0
        }
    }

    @Suppress("DEPRECATION")
    fun setMute(isMuted: Boolean, showSystemUI: Boolean, audioStream: AudioStream) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioManager.adjustStreamVolume(
                audioStream.streamType,
                if (isMuted) AudioManager.ADJUST_MUTE else AudioManager.ADJUST_UNMUTE,
                if (showSystemUI) AudioManager.FLAG_SHOW_UI else 0
            )
        } else {
            audioManager.setStreamMute(audioStream.streamType, isMuted)
        }
    }

    fun toggleMute(showSystemUI: Boolean, audioStream: AudioStream) {
        val isMuted = getMute(audioStream)
        setMute(!isMuted, showSystemUI, audioStream)
    }
}


