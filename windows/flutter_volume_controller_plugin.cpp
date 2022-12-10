#include "include/flutter_volume_controller/flutter_volume_controller_plugin.h"
#include "include/flutter_volume_controller/constants.h"

namespace flutter_volume_controller {

	const flutter::EncodableValue* GetArgValue(const flutter::EncodableMap& map, const char* key) {
		auto it = map.find(flutter::EncodableValue(key));
		if (it == map.end()) {
			return nullptr;
		}
		return &(it->second);
	}

	void FlutterVolumeControllerPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarWindows* registrar) {
		auto plugin = std::make_unique<FlutterVolumeControllerPlugin>();

		auto method_channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
			registrar->messenger(), "com.yosemiteyss.flutter_volume_controller/method",
			&flutter::StandardMethodCodec::GetInstance());

		auto event_channel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
			registrar->messenger(), "com.yosemiteyss.flutter_volume_controller/event",
			&flutter::StandardMethodCodec::GetInstance());

		method_channel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto& call, auto result) {
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		event_channel->SetStreamHandler(
			std::make_unique<VolumeNotificationStreamHandler>(VolumeController::GetInstance()));

		registrar->AddPlugin(std::move(plugin));
	}

	FlutterVolumeControllerPlugin::FlutterVolumeControllerPlugin() : volume_controller(VolumeController::GetInstance()) {
		volume_controller.RegisterController();
	}

	FlutterVolumeControllerPlugin::~FlutterVolumeControllerPlugin() {
		volume_controller.DisposeController();
	}

	void FlutterVolumeControllerPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

		if (method_call.method_name().compare(constants::kMethodGetVolume) == 0) {
			GetVolumeHandler(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodSetVolume) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
			SetVolumeHandler(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodRaiseVolume) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
			RaiseVolumeHandler(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodLowerVolume) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
			LowerVolumeHandler(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodGetMute) == 0) {
			GetMuteHandler(std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodSetMute) == 0) {
			const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
			SetMuteHandler(*arguments, std::move(result));
		}
		else if (method_call.method_name().compare(constants::kMethodToggleMute) == 0) {
			ToggleMuteHandler(std::move(result));
		}
		else {
			result->NotImplemented();
		}
	}

	void FlutterVolumeControllerPlugin::GetVolumeHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		auto current_volume = volume_controller.GetCurrentVolume();
		if (current_volume.has_value()) {
			result->Success(flutter::EncodableValue(std::to_string(current_volume.value())));
		}
		else {
			result->Error(constants::kErrCodeGetVolume, constants::kErrMsgGetVolume, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetVolumeHandler(
		const flutter::EncodableMap& arguments,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		const double* volume = std::get_if<double>(GetArgValue(arguments, constants::kArgVolume));

		if (!volume) {
			result->Error(constants::kErrCodeSetVolume, constants::kErrMsgSetVolume, nullptr);
			return;
		}

		if (!volume_controller.SetVolume((float) *volume)) {
			result->Error(constants::kErrCodeSetVolume, constants::kErrMsgSetVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::RaiseVolumeHandler(
		const flutter::EncodableMap& arguments,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		const double* step = std::get_if<double>(GetArgValue(arguments, constants::kArgStep));

		if (!step) {
			if (!volume_controller.SetVolumeUpBySystemStep()) {
				result->Error(constants::kErrCodeRaiseVolume, constants::kErrMsgRaiseVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.SetVolumeUp((float) *step)) {
			result->Error(constants::kErrCodeRaiseVolume, constants::kErrMsgRaiseVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::LowerVolumeHandler(
		const flutter::EncodableMap& arguments,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		const double* step = std::get_if<double>(GetArgValue(arguments, constants::kArgStep));

		if (!step) {
			if (!volume_controller.SetVolumeDownBySystemStep()) {
				result->Error(constants::kErrCodeLowerVolume, constants::kErrMsgLowerVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.SetVolumeDown((float) *step)) {
			result->Error(constants::kErrCodeLowerVolume, constants::kErrMsgLowerVolume, nullptr);
			return;
		}

		result->Success();
	}

	void FlutterVolumeControllerPlugin::GetMuteHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		auto is_muted = volume_controller.GetMute();

		if (is_muted.has_value()) {
			result->Success(flutter::EncodableValue(is_muted.value()));
		}
		else {
			result->Error(constants::kErrCodeGetMute, constants::kErrMsgGetMute, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetMuteHandler(
		const flutter::EncodableMap& arguments,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
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

	void FlutterVolumeControllerPlugin::ToggleMuteHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		if (!volume_controller.ToggleMute()) {
			result->Error(constants::kErrCodeToggleMute, constants::kErrMsgToggleMute, nullptr);
			return;
		}

		result->Success();
	}

	VolumeNotificationStreamHandler::VolumeNotificationStreamHandler(
		VolumeController& volume_controller) : volume_controller(volume_controller), sink(nullptr) {}

	VolumeNotificationStreamHandler::~VolumeNotificationStreamHandler() {}

	std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeNotificationStreamHandler::OnListenInternal(
		const flutter::EncodableValue* arguments,
		std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
		sink = std::move(events);
		
		auto callback = std::bind(&VolumeNotificationStreamHandler::OnVolumeChanged, this, std::placeholders::_1);

		if (!volume_controller.RegisterNotification(callback)) {
			return std::make_unique<flutter::StreamHandlerError<flutter::EncodableValue>>(
				constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
		}

		const auto* args = std::get_if<flutter::EncodableMap>(arguments);
		const bool* emit_on_start = std::get_if<bool>(GetArgValue(*args, constants::kArgEmitOnStart));

		if (*emit_on_start) {
			auto current_volume = volume_controller.GetCurrentVolume();
			if (current_volume.has_value()) {
				sink->Success(flutter::EncodableValue(std::to_string(current_volume.value())));
			}
			else {
				return std::make_unique<flutter::StreamHandlerError<flutter::EncodableValue>>(
					constants::kErrCodeRegVolumeListener, constants::kErrMsgRegVolumeListener, nullptr);
			}
		}

		return nullptr;
	}

	std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> VolumeNotificationStreamHandler::OnCancelInternal(
		const flutter::EncodableValue* arguments) {
		volume_controller.DisposeNotification();
		sink.reset();
		return nullptr;
	}

	void VolumeNotificationStreamHandler::OnVolumeChanged(float volume) {
		sink->Success(flutter::EncodableValue(std::to_string(volume)));
	}
}  // namespace flutter_volume_controller
