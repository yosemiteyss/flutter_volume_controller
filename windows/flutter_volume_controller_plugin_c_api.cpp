#include "include/flutter_volume_controller/flutter_volume_controller_plugin_c_api.h"
#include "include/flutter_volume_controller/flutter_volume_controller_plugin.h"

#include <flutter/plugin_registrar_windows.h>

void FlutterVolumeControllerPluginCApiRegisterWithRegistrar(
	FlutterDesktopPluginRegistrarRef registrar) {
	flutter_volume_controller::FlutterVolumeControllerPlugin::RegisterWithRegistrar(
		flutter::PluginRegistrarManager::GetInstance()
		->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
