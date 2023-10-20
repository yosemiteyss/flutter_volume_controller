#ifndef FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_

#include "volume_controller.h"
#include "audio_endpoint_volume_callback.h"

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

using namespace flutter;

namespace flutter_volume_controller {

	class FlutterVolumeControllerPlugin : public Plugin {
	public:
		static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

		FlutterVolumeControllerPlugin();

		virtual ~FlutterVolumeControllerPlugin();

		// Disallow copy and assign.
		FlutterVolumeControllerPlugin(const FlutterVolumeControllerPlugin&) = delete;
		FlutterVolumeControllerPlugin& operator=(const FlutterVolumeControllerPlugin&) = delete;

	private:
		void HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result);

		void GetVolume(std::unique_ptr<MethodResult<EncodableValue>> result);

		void SetVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result);

		void RaiseVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result);

		void LowerVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result);

		void GetMute(std::unique_ptr<MethodResult<EncodableValue>> result);

		void SetMute(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result);

		void ToggleMute(std::unique_ptr<MethodResult<EncodableValue>> result);

		void GetDefaultOutputDevice(std::unique_ptr<MethodResult<EncodableValue>> result);

		void SetDefaultOutputDevice(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result);

		void GetOutputDeviceList(std::unique_ptr<MethodResult<EncodableValue>> result);

		VolumeController& volume_controller;
	};

	class VolumeChangeStreamHandler : public StreamHandler<EncodableValue> {
	public:
		VolumeChangeStreamHandler(VolumeController& volume_controller);

		virtual ~VolumeChangeStreamHandler();

	protected:
		std::unique_ptr<StreamHandlerError<EncodableValue>> OnListenInternal(const EncodableValue* arguments, std::unique_ptr<EventSink<EncodableValue>>&& events) override;

		std::unique_ptr<StreamHandlerError<EncodableValue>> OnCancelInternal(const EncodableValue* arguments) override;

		void OnVolumeChanged(float volume);

	private:
		VolumeController& volume_controller;

		std::unique_ptr<EventSink<EncodableValue>> sink;

		std::unique_ptr<AudioEndpointVolumeCallback> volume_callback;
	};
}  // namespace flutter_volume_controller

#endif  // FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_
