package com.yosemiteyss.flutter_volume_controller

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

private const val EXTRA_VOLUME_STREAM_TYPE = "android.media.EXTRA_VOLUME_STREAM_TYPE"
private const val VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION"

class VolumeBroadcastReceiver(
    private val event: EventChannel.EventSink?,
    private val audioStream: AudioStream,
) : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        val streamType = intent?.extras?.getInt(EXTRA_VOLUME_STREAM_TYPE)
        if (intent?.action == VOLUME_CHANGED_ACTION && streamType == audioStream.streamType) {
            event?.success(context.audioManager.getVolume(audioStream))
        }
    }
}
