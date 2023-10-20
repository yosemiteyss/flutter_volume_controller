#ifndef AUDIO_ENDPOINT_VOLUME_CALLBACK_H_
#define AUDIO_ENDPOINT_VOLUME_CALLBACK_H_

#include <functional>
#include <endpointvolume.h>
#include <mmdeviceapi.h>
#include <wrl/client.h>

using namespace Microsoft::WRL;

namespace flutter_volume_controller {
	typedef std::function<void(float volume)> VolumeChangedCallback;

	class AudioEndpointVolumeCallback : public IAudioEndpointVolumeCallback {
	public:
		AudioEndpointVolumeCallback(VolumeChangedCallback pCallback);

		STDMETHODIMP OnNotify(PAUDIO_VOLUME_NOTIFICATION_DATA pNotify) override;

		STDMETHODIMP QueryInterface(REFIID riid, void** ppv) override;

		STDMETHODIMP_(ULONG) AddRef() override;

		STDMETHODIMP_(ULONG) Release() override;

		bool Register();

		bool Cancel();

	private:
		LONG m_lRefCount = 1;

		VolumeChangedCallback m_pCallback;

		ComPtr<IMMDeviceEnumerator> m_pEnumerator;

		ComPtr<IMMDevice> m_pDevice;

		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;
	};
}

#endif
