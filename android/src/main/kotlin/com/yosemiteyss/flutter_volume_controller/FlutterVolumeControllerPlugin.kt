package com.yosemiteyss.flutter_volume_controller

import android.content.Context
import android.content.IntentFilter
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val METHOD_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/method"
private const val EVENT_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/event"

class FlutterVolumeControllerPlugin : FlutterPlugin, ActivityAware, MethodCallHandler,
    EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var volumeController: VolumeController
    private lateinit var context: Context

    private var activityPluginBinding: ActivityPluginBinding? = null
    private var volumeBroadcastReceiver: VolumeBroadcastReceiver? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(
            flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME
        ).apply {
            setMethodCallHandler(this@FlutterVolumeControllerPlugin)
        }

        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger, EVENT_CHANNEL_NAME
        ).apply {
            setStreamHandler(this@FlutterVolumeControllerPlugin)
        }

        volumeController = VolumeController(context.audioManager)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodName.GET_VOLUME -> {
                try {
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    result.success(
                        volumeController.getVolume(AudioStream.values()[audioStream])
                    )
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.DEFAULT, ErrorMessage.GET_VOLUME, e.message
                    )
                }
            }
            MethodName.SET_VOLUME -> {
                try {
                    val volume = call.argument<Double>(MethodArg.VOLUME)!!
                    val showSystemUI = call.argument<Boolean>(MethodArg.SHOW_SYSTEM_UI)!!
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    volumeController.setVolume(
                        volume, showSystemUI, AudioStream.values()[audioStream]
                    )
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.DEFAULT, ErrorMessage.SET_VOLUME, e.message
                    )
                }
            }
            MethodName.RAISE_VOLUME -> {
                try {
                    val step = call.argument<Double>(MethodArg.STEP)
                    val showSystemUI = call.argument<Boolean>(MethodArg.SHOW_SYSTEM_UI)!!
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    volumeController.raiseVolume(
                        step, showSystemUI, AudioStream.values()[audioStream]
                    )
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.DEFAULT, ErrorMessage.RAISE_VOLUME, e.message
                    )
                }
            }
            MethodName.LOWER_VOLUME -> {
                try {
                    val step = call.argument<Double>(MethodArg.STEP)
                    val showSystemUI = call.argument<Boolean>(MethodArg.SHOW_SYSTEM_UI)!!
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    volumeController.lowerVolume(
                        step, showSystemUI, AudioStream.values()[audioStream]
                    )
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.DEFAULT, ErrorMessage.LOWER_VOLUME, e.message
                    )
                }
            }
            MethodName.SET_ANDROID_AUDIO_STREAM -> {
                try {
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    activityPluginBinding?.activity?.volumeControlStream =
                        AudioStream.values()[audioStream].streamType
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.DEFAULT, ErrorMessage.LOWER_VOLUME, e.message
                    )
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        try {
            val args = arguments as Map<*, *>
            val audioStream = AudioStream.values()[args[MethodArg.AUDIO_STREAM] as Int]
            val emitOnStart = args[MethodArg.EMIT_ON_START] as Boolean

            volumeBroadcastReceiver = VolumeBroadcastReceiver(events, audioStream).also {
                context.registerReceiver(
                    it, IntentFilter("android.media.VOLUME_CHANGED_ACTION")
                )
            }

            if (emitOnStart) {
                events?.success(context.audioManager.getVolume(audioStream))
            }
        } catch (e: Exception) {
            events?.error(ErrorCode.DEFAULT, ErrorMessage.REGISTER_LISTENER, e.message)
        }
    }

    override fun onCancel(arguments: Any?) {
        volumeBroadcastReceiver?.let(context::unregisterReceiver)
        volumeBroadcastReceiver = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding = null
    }
}
