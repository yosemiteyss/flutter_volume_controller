#include "include/flutter_volume_controller/audio_endpoint_volume_callback.h"
#include "include/flutter_volume_controller/constants.h"
#include "include/flutter_volume_controller/flutter_volume_controller_plugin.h"

#include <algorithm>

namespace flutter_volume_controller {

	const EncodableValue* GetArgValue(const EncodableMap& map, const char* key) {
		auto it = map.find(EncodableValue(key));
		if (it == map.end()) {
			return nullptr;
		}
		return &(it->second);
	}

	void FlutterVolumeControllerPlugin::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
		auto plugin = std::make_unique<FlutterVolumeControllerPlugin>();

		auto method_channel = std::make_unique<MethodChannel<EncodableValue>>(
			registrar->messenger(), "com.yosemiteyss.flutter_volume_controller/method",
			&StandardMethodCodec::GetInstance());

		auto event_channel = std::make_unique<EventChannel<EncodableValue>>(
			registrar->messenger(), "com.yosemiteyss.flutter_volume_controller/event",
			&StandardMethodCodec::GetInstance());

		auto output_device_channel = std::make_unique<EventChannel<EncodableValue>>(
			registrar->messenger(), "com.yosemiteyss.flutter_volume_controller/default-output-device",
			&StandardMethodCodec::GetInstance());

		method_channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		event_channel->SetStreamHandler(
			std::make_unique<VolumeChangeStreamHandler>(VolumeController::GetInstance()));

		output_device_channel->SetStreamHandler(
			std::make_unique<OutputDeviceStreamHandler>(VolumeController::GetInstance()));

		registrar->AddPlugin(std::move(plugin));
	}

	FlutterVolumeControllerPlugin::FlutterVolumeControllerPlugin() : volume_controller(VolumeController::GetInstance()) {
		CoInitialize(NULL);
		volume_controller.Init();
	}

	FlutterVolumeControllerPlugin::~FlutterVolumeControllerPlugin() {
		CoUninitialize();
	}

	void FlutterVolumeControllerPlugin::HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result) {
		if (method_call.method_name().compare(constants::kMethodGetVolume) == 0) {
			GetVolume(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodSetVolume) == 0) {
			const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
			SetVolume(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodRaiseVolume) == 0) {
			const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
			RaiseVolume(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodLowerVolume) == 0) {
			const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
			LowerVolume(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodGetMute) == 0) {
			GetMute(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodSetMute) == 0) {
			const auto* arguments = std::get_if<EncodableMap>(method_call.arguments());
			SetMute(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodToggleMute) == 0) {
			ToggleMute(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kGetDefaultOutputDevice) == 0) {
			GetDefaultOutputDevice(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kGetOutputDeviceList) == 0) {
			GetOutputDeviceList(std::move(result));
		}
		else {
			result->NotImplemented();
		}
	}

	void FlutterVolumeControllerPlugin::GetVolume(std::unique_ptr<MethodResult<EncodableValue>> result) {
		auto current_volume = volume_controller.GetVolume();
		if (current_volume.has_value()) {
			result->Success(EncodableValue(std::to_string(current_volume.value())));
		}
		else {
			result->Error(constants::kErrCodeGetVolume, constants::kErrMsgGetVolume, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result) {
		const double* volume = std::get_if<double>(GetArgValue(arguments, constants::kArgVolume));

		if (!volume) {
			result->Error(constants::kErrCodeSetVolume, constants::kErrMsgSetVolume, nullptr);
			return;
		}

		if (!volume_controller.SetVolume((float)*volume)) {
			result->Error(constants::kErrCodeSetVolume, constants::kErrMsgSetVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::RaiseVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result) {
		const double* step = std::get_if<double>(GetArgValue(arguments, constants::kArgStep));

		if (!step) {
			if (!volume_controller.RaiseVolume()) {
				result->Error(constants::kErrCodeRaiseVolume, constants::kErrMsgRaiseVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.RaiseVolume((float)*step)) {
			result->Error(constants::kErrCodeRaiseVolume, constants::kErrMsgRaiseVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::LowerVolume(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result) {
		const double* step = std::get_if<double>(GetArgValue(arguments, constants::kArgStep));

		if (!step) {
			if (!volume_controller.LowerVolume()) {
				result->Error(constants::kErrCodeLowerVolume, constants::kErrMsgLowerVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.LowerVolume((float)*step)) {
			result->Error(constants::kErrCodeLowerVolume, constants::kErrMsgLowerVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::GetMute(std::unique_ptr<MethodResult<EncodableValue>> result) {
		auto is_muted = volume_controller.GetMute();

		if (is_muted.has_value()) {
			result->Success(EncodableValue(is_muted.value()));
		}
		else {
			result->Error(constants::kErrCodeGetMute, constants::kErrMsgGetMute, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetMute(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result) {
		const bool* is_muted = std::get_if<bool>(GetArgValue(arguments, constants::kArgIsMuted));

		if (!is_muted) {
			result->Error(constants::kErrCodeSetMute, constants::kErrMsgSetMute, nullptr);
			return;
		}

		if (!volume_controller.SetMute(*is_muted)) {
			result->Error(constants::kErrCodeSetMute, constants::kErrMsgSetMute, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::ToggleMute(std::unique_ptr<MethodResult<EncodableValue>> result) {
		if (!volume_controller.ToggleMute()) {
			result->Error(constants::kErrCodeToggleMute, constants::kErrMsgToggleMute, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::GetDefaultOutputDevice(std::unique_ptr<MethodResult<EncodableValue>> result) {
		auto output_device = volume_controller.GetDefaultOutputDevice();

		if (output_device.has_value()) {
			result->Success(EncodableValue(output_device->ToJson()));
		}
		else {
			result->Error(constants::kErrCodeGetDefaultOutputDevice, constants::kErrMsgGetDefaultOutputDevice, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetDefaultOutputDevice(const EncodableMap& arguments, std::unique_ptr<MethodResult<EncodableValue>> result) {
		// TODO: SetDefaultOutputDeviceHandler
	}

	void FlutterVolumeControllerPlugin::GetOutputDeviceList(std::unique_ptr<MethodResult<EncodableValue>> result) {
		std::optional<std::vector<OutputDevice>> devices = volume_controller.GetOutputDeviceList();

		if (devices.has_value()) {
			std::string devices_json = OutputDevice::ToJsonList(devices.value());
			result->Success(EncodableValue(devices_json));
		}
		else {
			result->Error(constants::kErrCodeGetOutputDeviceList, constants::kErrMsgGetOutputDeviceList, nullptr);
		}
	}

	VolumeChangeStreamHandler::VolumeChangeStreamHandler(VolumeController& volume_controller)
		: volume_controller(volume_controller), sink(nullptr) {

	}

	VolumeChangeStreamHandler::~VolumeChangeStreamHandler() {

	}

	std::unique_ptr<StreamHandlerError<EncodableValue>> VolumeChangeStreamHandler::OnListenInternal(const EncodableValue* arguments, std::unique_ptr<EventSink<EncodableValue>>&& events) {
		sink = std::move(events);

		auto cb_func = std::bind(&VolumeChangeStreamHandler::OnVolumeChanged, this, std::placeholders::_1);
        volume_cb = std::make_unique<AudioEndpointVolumeCallback>(cb_func);

		if (!volume_cb->Register()) {
			return std::make_unique<StreamHandlerError<EncodableValue>>(
				constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
		}

		const auto* args = std::get_if<EncodableMap>(arguments);
		const bool* emit_on_start = std::get_if<bool>(GetArgValue(*args, constants::kArgEmitOnStart));

		if (*emit_on_start) {
			auto current_volume = volume_controller.GetVolume();
			if (current_volume.has_value()) {
				sink->Success(EncodableValue(std::to_string(current_volume.value())));
			}
			else {
				return std::make_unique<StreamHandlerError<EncodableValue>>(
					constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
			}
		}

		return nullptr;
	}

	std::unique_ptr<StreamHandlerError<EncodableValue>> VolumeChangeStreamHandler::OnCancelInternal(const EncodableValue* arguments) {
		volume_cb->Cancel();
		sink.reset();
		return nullptr;
	}

	void VolumeChangeStreamHandler::OnVolumeChanged(float volume) {
		sink->Success(EncodableValue(std::to_string(volume)));
	}

	OutputDeviceStreamHandler::OutputDeviceStreamHandler(VolumeController& volume_controller) 
		: volume_controller(volume_controller), sink(nullptr), change_cb(nullptr) {

	}

	OutputDeviceStreamHandler::~OutputDeviceStreamHandler() {

	}

	std::unique_ptr<StreamHandlerError<EncodableValue>> OutputDeviceStreamHandler::OnListenInternal(const EncodableValue* arguments, std::unique_ptr<EventSink<EncodableValue>>&& events) {
		sink = std::move(events);

		auto cb_func = std::bind(&OutputDeviceStreamHandler::OnDefaultOutputDeviceChanged, this, std::placeholders::_1);
		change_cb = std::make_unique<AudioEndpointChangeCallback>(volume_controller, cb_func);

		if (!change_cb->Register()) {
			// TODO: update error
			return std::make_unique<StreamHandlerError<EncodableValue>>(
				constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
		}

		const auto* args = std::get_if<EncodableMap>(arguments);
		const bool* emit_on_start = std::get_if<bool>(GetArgValue(*args, constants::kArgEmitOnStart));

		if (*emit_on_start) {
			auto output_device = volume_controller.GetDefaultOutputDevice();
			if (output_device.has_value()) {
				sink->Success(EncodableValue(output_device.value().ToJson()));
			}
			else {
				// TODO: update error
				return std::make_unique<StreamHandlerError<EncodableValue>>(
					constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
			}
		}

		return nullptr;
	}

	std::unique_ptr<StreamHandlerError<EncodableValue>> OutputDeviceStreamHandler::OnCancelInternal(const EncodableValue* arguments) {
		change_cb->Cancel();
		sink.reset();
		return nullptr;
	}

	void OutputDeviceStreamHandler::OnDefaultOutputDeviceChanged(OutputDevice device) {
		sink->Success(EncodableValue(device.ToJson()));
	}
}  // namespace flutter_volume_controller
