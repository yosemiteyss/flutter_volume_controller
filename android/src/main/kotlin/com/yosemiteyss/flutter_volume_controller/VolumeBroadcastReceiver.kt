package com.yosemiteyss.flutter_volume_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

class VolumeBroadcastReceiver(
    private val event: EventChannel.EventSink?,
    private val audioStream: AudioStream,
) : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val streamType = intent?.extras?.getInt(EXTRA_VOLUME_STREAM_TYPE)
        if (intent?.action == VOLUME_CHANGED_ACTION && streamType == audioStream.streamType) {
            val volume = context.audioManager.getVolume(audioStream)
            event?.success(volume.toString())
        }
    }
}
