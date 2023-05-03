package com.yosemiteyss.flutter_volume_controller

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

abstract class FlutterVolumeControllerActivity : FlutterActivity(), EventChannel.StreamHandler {
    private lateinit var keyActionChannel: EventChannel

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        keyActionChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger, Channel.KEY_ACTION
        ).apply {
            setStreamHandler(this@FlutterVolumeControllerActivity)
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            eventSink?.success(true)
            return true
        }

        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            eventSink?.success(false)
            return true
        }

        return super.onKeyDown(keyCode, event)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}