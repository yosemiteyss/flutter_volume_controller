#ifndef AUDIO_ENDPOINT_CHANGE_CALLBACK_H_
#define AUDIO_ENDPOINT_CHANGE_CALLBACK_H_

#include <functional>
#include <mmdeviceapi.h>
#include <endpointvolume.h>

namespace flutter_volume_controller {
	typedef std::function<void (LPCWSTR deviceId)> DefaultDeviceChangedCallback;

	class AudioEndpointChangeCallback : public IMMNotificationClient {
	public:
		AudioEndpointChangeCallback(DefaultDeviceChangedCallback pCallback);

		STDMETHODIMP OnDefaultDeviceChanged(EDataFlow flow, ERole role, LPCWSTR pwstrDefaultDeviceId) override;

		STDMETHODIMP OnDeviceStateChanged(LPCWSTR pwstrDeviceId, DWORD dwNewState) override;

		STDMETHODIMP OnDeviceAdded(LPCWSTR pwstrDeviceId) override;

		STDMETHODIMP OnDeviceRemoved(LPCWSTR pwstrDeviceId) override;

		STDMETHODIMP OnPropertyValueChanged(LPCWSTR pwstrDeviceId, const PROPERTYKEY pKey) override;

		STDMETHODIMP QueryInterface(REFIID riid, void** ppv) override;

		STDMETHODIMP_(ULONG) AddRef() override;

		STDMETHODIMP_(ULONG) Release() override;

	private:
		LONG m_lRefCount = 1;
		DefaultDeviceChangedCallback m_pCallback;
	};
}

#endif