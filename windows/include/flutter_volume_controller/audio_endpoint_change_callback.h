#ifndef AUDIO_ENDPOINT_CHANGE_CALLBACK_H_
#define AUDIO_ENDPOINT_CHANGE_CALLBACK_H_

#include "volume_controller.h"

#include <functional>
#include <endpointvolume.h>
#include <mmdeviceapi.h>
#include <wrl/client.h>

using namespace Microsoft::WRL;

namespace flutter_volume_controller {
	typedef std::function<void (OutputDevice device)> DefaultDeviceChangedCallback;

	class AudioEndpointChangeCallback : public IMMNotificationClient {
	public:
		AudioEndpointChangeCallback(VolumeController& volumeController, DefaultDeviceChangedCallback pCallback);

		STDMETHODIMP OnDefaultDeviceChanged(EDataFlow flow, ERole role, LPCWSTR pwstrDefaultDeviceId) override;

		STDMETHODIMP OnDeviceStateChanged(LPCWSTR pwstrDeviceId, DWORD dwNewState) override;

		STDMETHODIMP OnDeviceAdded(LPCWSTR pwstrDeviceId) override;

		STDMETHODIMP OnDeviceRemoved(LPCWSTR pwstrDeviceId) override;

		STDMETHODIMP OnPropertyValueChanged(LPCWSTR pwstrDeviceId, const PROPERTYKEY pKey) override;

		STDMETHODIMP QueryInterface(REFIID riid, void** ppv) override;

		STDMETHODIMP_(ULONG) AddRef() override;

		STDMETHODIMP_(ULONG) Release() override;

		bool Register();

		bool Cancel();

	private:
		LONG m_lRefCount = 1;

		VolumeController& m_volumeController;

		DefaultDeviceChangedCallback m_pCallback;

		ComPtr<IMMDeviceEnumerator> m_pEnumerator;
	};
}

#endif