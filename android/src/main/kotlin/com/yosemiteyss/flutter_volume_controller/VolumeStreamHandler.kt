package com.yosemiteyss.flutter_volume_controller

import android.content.Context
import android.content.IntentFilter
import android.media.AudioManager
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.EventChannel

class VolumeStreamHandler(
    private val applicationContext: Context,
    private val onSetVolumeStream: (streamType: Int) -> Unit,
) : EventChannel.StreamHandler, DefaultLifecycleObserver {
    private var observedStream: AudioStream = AudioStream.MUSIC
    private var volumeBroadcastReceiver: VolumeBroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        try {
            val args = arguments as Map<*, *>
            val audioStream = AudioStream.values()[args[MethodArg.AUDIO_STREAM] as Int]
            val emitOnStart = args[MethodArg.EMIT_ON_START] as Boolean

            setActivityAudioStream(audioStream)

            volumeBroadcastReceiver = VolumeBroadcastReceiver(events, audioStream).also {
                applicationContext.registerReceiver(it, IntentFilter(VOLUME_CHANGED_ACTION))
            }

            if (emitOnStart) {
                val volume = applicationContext.audioManager.getVolume(audioStream)
                events?.success(volume.toString())
            }
        } catch (e: Exception) {
            events?.error(
                ErrorCode.REGISTER_VOLUME_LISTENER, ErrorMessage.REGISTER_VOLUME_LISTENER, e.message
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        volumeBroadcastReceiver?.let(applicationContext::unregisterReceiver)
        volumeBroadcastReceiver = null
        resetActivityAudioStream()
    }

    override fun onResume(owner: LifecycleOwner) {
        if (volumeBroadcastReceiver != null) {
            resumeActivityAudioStream()
        }
        super.onResume(owner)
    }

    fun setActivityAudioStream(audioStream: AudioStream) {
        onSetVolumeStream(audioStream.streamType)
        observedStream = audioStream
    }

    private fun resetActivityAudioStream() {
        onSetVolumeStream(AudioManager.USE_DEFAULT_STREAM_TYPE)
        observedStream = AudioStream.MUSIC
    }

    private fun resumeActivityAudioStream() {
        onSetVolumeStream(observedStream.streamType)
    }
}