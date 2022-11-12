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
		else {
			result->NotImplemented();
		}
	}

	void FlutterVolumeControllerPlugin::GetVolumeHandler(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		auto current_volume = volume_controller.GetCurrentVolume();
		if (current_volume.has_value()) {
			result->Success(flutter::EncodableValue(current_volume.value()));
		}
		else {
			result->Error(constants::kErrorCode, constants::kErrorGetVolume, nullptr);
		}
	}

	void FlutterVolumeControllerPlugin::SetVolumeHandler(
		const flutter::EncodableMap& arguments,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
		const double* volume = std::get_if<double>(GetArgValue(arguments, constants::kArgVolume));

		if (!volume) {
			result->Error(constants::kErrorCode, constants::kErrorSetVolume, nullptr);
			return;
		}

		if (!volume_controller.SetVolume(static_cast<float>(*volume))) {
			result->Error(constants::kErrorCode, constants::kErrorSetVolume, nullptr);
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
				result->Error(constants::kErrorCode, constants::kErrorRaiseVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.SetVolumeUp(static_cast<float>(*step))) {
			result->Error(constants::kErrorCode, constants::kErrorRaiseVolume, nullptr);
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
				result->Error(constants::kErrorCode, constants::kErrorLowerVolume, nullptr);
				return;
			}
		}
		else if (!volume_controller.SetVolumeDown(static_cast<float>(*step))) {
			result->Error(constants::kErrorCode, constants::kErrorLowerVolume, nullptr);
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
				constants::kErrorCode, constants::kErrorRegisterListener, nullptr);
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
		sink->Success(flutter::EncodableValue(volume));
	}
}  // namespace flutter_volume_controller
