package com.yosemiteyss.flutter_volume_controller

import android.app.Activity
import android.content.Context
import android.content.IntentFilter
import android.media.AudioManager
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

private const val METHOD_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/method"
private const val EVENT_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/event"

internal const val EXTRA_VOLUME_STREAM_TYPE = "android.media.EXTRA_VOLUME_STREAM_TYPE"
internal const val VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION"

class FlutterVolumeControllerPlugin : FlutterPlugin, ActivityAware, MethodCallHandler,
    EventChannel.StreamHandler, DefaultLifecycleObserver {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var volumeController: VolumeController
    private lateinit var context: Context

    private var activity: Activity? = null
    private var lifecycle: Lifecycle? = null
    private var volumeBroadcastReceiver: VolumeBroadcastReceiver? = null
    private var observedStream: AudioStream = AudioStream.MUSIC

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
                    val volume = volumeController.getVolume(AudioStream.values()[audioStream])
                    result.success(volume.toString())
                } catch (e: Exception) {
                    result.error(ErrorCode.GET_VOLUME, ErrorMessage.GET_VOLUME, e.message)
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
                    result.success(null)
                } catch (e: Exception) {
                    result.error(ErrorCode.SET_VOLUME, ErrorMessage.SET_VOLUME, e.message)
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
                    result.success(null)
                } catch (e: Exception) {
                    result.error(ErrorCode.RAISE_VOLUME, ErrorMessage.RAISE_VOLUME, e.message)
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
                    result.success(null)
                } catch (e: Exception) {
                    result.error(ErrorCode.LOWER_VOLUME, ErrorMessage.LOWER_VOLUME, e.message)
                }
            }
            MethodName.GET_MUTE -> {
                try {
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    result.success(
                        volumeController.getMute(AudioStream.values()[audioStream])
                    )
                } catch (e: Exception) {
                    result.error(ErrorCode.GET_MUTE, ErrorMessage.GET_MUTE, e.message)
                }
            }
            MethodName.SET_MUTE -> {
                try {
                    val isMuted = call.argument<Boolean>(MethodArg.IS_MUTED)!!
                    val showSystemUI = call.argument<Boolean>(MethodArg.SHOW_SYSTEM_UI)!!
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!

                    volumeController.setMute(
                        isMuted, showSystemUI, AudioStream.values()[audioStream]
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error(ErrorCode.SET_MUTE, ErrorMessage.SET_MUTE, e.message)
                }
            }
            MethodName.TOGGLE_MUTE -> {
                try {
                    val showSystemUI = call.argument<Boolean>(MethodArg.SHOW_SYSTEM_UI)!!
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!

                    volumeController.toggleMute(showSystemUI, AudioStream.values()[audioStream])
                    result.success(null)
                } catch (e: Exception) {
                    result.error(ErrorCode.TOGGLE_MUTE, ErrorMessage.TOGGLE_MUTE, e.message)
                }
            }
            MethodName.SET_ANDROID_AUDIO_STREAM -> {
                try {
                    val audioStream = call.argument<Int>(MethodArg.AUDIO_STREAM)!!
                    setActivityAudioStream(AudioStream.values()[audioStream])
                    result.success(null)
                } catch (e: Exception) {
                    result.error(
                        ErrorCode.SET_ANDROID_AUDIO_STREAM,
                        ErrorMessage.SET_ANDROID_AUDIO_STREAM,
                        e.message
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

            setActivityAudioStream(audioStream)

            volumeBroadcastReceiver = VolumeBroadcastReceiver(events, audioStream).also {
                context.registerReceiver(it, IntentFilter(VOLUME_CHANGED_ACTION))
            }

            if (emitOnStart) {
                val volume = context.audioManager.getVolume(audioStream)
                events?.success(volume.toString())
            }
        } catch (e: Exception) {
            events?.error(
                ErrorCode.REGISTER_VOLUME_LISTENER, ErrorMessage.REGISTER_VOLUME_LISTENER, e.message
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        volumeBroadcastReceiver?.let(context::unregisterReceiver)
        volumeBroadcastReceiver = null
        resetActivityAudioStream()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding).apply {
            addObserver(this@FlutterVolumeControllerPlugin)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onResume(owner: LifecycleOwner) {
        if (volumeBroadcastReceiver != null) {
            resumeActivityAudioStream()
        }
    }

    private fun setActivityAudioStream(audioStream: AudioStream) {
        activity?.volumeControlStream = audioStream.streamType
        observedStream = audioStream
    }

    private fun resumeActivityAudioStream() {
        activity?.volumeControlStream = observedStream.streamType
    }

    private fun resetActivityAudioStream() {
        activity?.volumeControlStream = AudioManager.USE_DEFAULT_STREAM_TYPE
        observedStream = AudioStream.MUSIC
    }
}
