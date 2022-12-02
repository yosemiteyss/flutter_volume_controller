#ifndef FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_

#include "volume_controller.h"

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

namespace flutter_volume_controller {

	class FlutterVolumeControllerPlugin : public flutter::Plugin {
	public:
		static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

		FlutterVolumeControllerPlugin();

		virtual ~FlutterVolumeControllerPlugin();

		// Disallow copy and assign.
		FlutterVolumeControllerPlugin(const FlutterVolumeControllerPlugin&) = delete;
		FlutterVolumeControllerPlugin& operator=(const FlutterVolumeControllerPlugin&) = delete;

	private:
		void HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void GetVolumeHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void SetVolumeHandler(
			const flutter::EncodableMap& arguments,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void RaiseVolumeHandler(
			const flutter::EncodableMap& arguments,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void LowerVolumeHandler(
			const flutter::EncodableMap& arguments,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void GetMuteHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void SetMuteHandler(
			const flutter::EncodableMap& arguments,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		void ToggleMuteHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

		VolumeController& volume_controller;
	};

	class VolumeNotificationStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
	public:
		VolumeNotificationStreamHandler(VolumeController& volume_controller);

		virtual ~VolumeNotificationStreamHandler();

	protected:
		std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
			const flutter::EncodableValue* arguments,
			std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override;

		std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
			const flutter::EncodableValue* arguments) override;

		void OnVolumeChanged(float volume);

	private:
		VolumeController& volume_controller;

		std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink;
	};

}  // namespace flutter_volume_controller

#endif  // FLUTTER_PLUGIN_FLUTTER_VOLUME_CONTROLLER_PLUGIN_H_
