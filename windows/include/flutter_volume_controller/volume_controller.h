#ifndef VOLUME_CONTROLLER_H_
#define VOLUME_CONTROLLER_H_

#include "volume_notification.h"

#include <endpointvolume.h>
#include <optional>

namespace flutter_volume_controller {
	class VolumeController {
	public:
		static VolumeController& GetInstance();

		bool RegisterController();

		bool RegisterNotification(VolumeCallback callback);

		void DisposeController();

		void DisposeNotification();

		bool SetVolume(double volume);

		bool SetMaxVolume();

		bool SetMinVolume();

		bool SetVolumeUp(double step);

		bool SetVolumeDown(double step);

		bool SetVolumeUpBySystemStep();

		bool SetVolumeDownBySystemStep();

		bool SetMute(bool is_mute);

		bool ToggleMute();

		std::optional<double> GetCurrentVolume();

		std::optional<bool> GetMute();

	private:
		VolumeController();

		VolumeController(const VolumeController&) = delete;

		VolumeController& operator=(const VolumeController&) = delete;

		IAudioEndpointVolume* endpoint_volume;

		VolumeNotification* volume_notification;
	};
}

#endif
