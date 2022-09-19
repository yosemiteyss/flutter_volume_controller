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
        val streamType = intent?.extras?.getInt("android.media.EXTRA_VOLUME_STREAM_TYPE")
        if (intent?.action == "android.media.VOLUME_CHANGED_ACTION" && streamType == audioStream.streamType) {
            event?.success(context.audioManager.getVolume(audioStream))
        }
    }
}
