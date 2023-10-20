#ifndef VOLUME_CONTROLLER_H_
#define VOLUME_CONTROLLER_H_

#include "output_device.h"

#include <endpointvolume.h>
#include <optional>
#include <mmdeviceapi.h>
#include <string>
#include <wrl/client.h>

using namespace Microsoft::WRL;

namespace flutter_volume_controller {
	class VolumeController {
	public:
		static VolumeController& GetInstance();

		bool Init();

		void Dispose();

		bool SetVolume(float volume);

		bool SetMaxVolume();

		bool SetMinVolume();

		bool RaiseVolume(float step);

		bool LowerVolume(float step);

		bool RaiseVolume();

		bool LowerVolume();

		bool SetMute(bool isMuted);

		bool ToggleMute();

		std::optional<float> GetVolume();

		std::optional<bool> GetMute();

		std::optional<OutputDevice> GetDefaultOutputDevice();

		bool setDefaultOutputDevice(LPCWSTR pwstrDeviceId);

		std::optional<std::vector<OutputDevice>> GetOutputDeviceList();

		std::optional<OutputDevice> GetOutputDevice(ComPtr<IMMDevice>& pDevice);

	private:
		VolumeController();

		VolumeController(const VolumeController&) = delete;

		VolumeController& operator=(const VolumeController&) = delete;

		std::optional<std::string> GetAudioDeviceID(ComPtr<IMMDevice>& pDevice);

		std::optional<std::string> GetAudioDeviceName(ComPtr<IMMDevice>& pDevice);

		HRESULT SetDefaultAudioPlaybackDevice(LPCWSTR pwstrDeviceId);

		bool InitializeAudio(ComPtr<IMMDevice>& pDevice, ComPtr<IAudioEndpointVolume>& m_pEndpointVolume);

		ComPtr<IMMDeviceEnumerator> m_pEnumerator;
	};
}

#endif
