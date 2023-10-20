#include "include/flutter_volume_controller/audio_endpoint_change_callback.h"

namespace flutter_volume_controller {
	AudioEndpointChangeCallback::AudioEndpointChangeCallback(DefaultDeviceChangedCallback pCallback)
		: m_lRefCount(1), m_pCallback(pCallback) {

	}

	STDMETHODIMP AudioEndpointChangeCallback::OnDefaultDeviceChanged(EDataFlow flow, ERole role, LPCWSTR pwstrDefaultDeviceId) {
		// Check if the change is caused by audio output.
		if (flow == eRender && role == eMultimedia) {
			HRESULT hr;
			IMMDeviceEnumerator* m_pEnumerator = NULL;
			IMMDevice* pDevice = NULL;

			// Get enumerator.
			hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), (void**)&m_pEnumerator);
			if (FAILED(hr)) {
				return S_FALSE;
			}

			// Get device.
			hr = m_pEnumerator->GetDevice(pwstrDefaultDeviceId, &pDevice);
			if (FAILED(hr)) {
				m_pEnumerator->Release();
				return S_FALSE;
			}

			// Get device id.
			LPWSTR deviceId = NULL;

			hr = pDevice->GetId(&deviceId);
			if (FAILED(hr)) {
				pDevice->Release();
				m_pEnumerator->Release();
				return S_FALSE;
			}

			if (m_pCallback == NULL) {
				return E_INVALIDARG;
			}

			m_pCallback(pwstrDefaultDeviceId);

			// Clean up.
			CoTaskMemFree(deviceId);
			pDevice->Release();
			m_pEnumerator->Release();
		}

		return S_OK;
	}

	STDMETHODIMP AudioEndpointChangeCallback::OnDeviceStateChanged(LPCWSTR pwstrDeviceId, DWORD dwNewState) {
		return S_OK;
	}

	STDMETHODIMP AudioEndpointChangeCallback::OnDeviceAdded(LPCWSTR pwstrDeviceId) {
		return S_OK;
	}

	STDMETHODIMP AudioEndpointChangeCallback::OnDeviceRemoved(LPCWSTR pwstrDeviceId) {
		return S_OK;
	}

	STDMETHODIMP AudioEndpointChangeCallback::OnPropertyValueChanged(LPCWSTR pwstrDeviceId, const PROPERTYKEY pKey) {
		return S_OK;
	}

	STDMETHODIMP AudioEndpointChangeCallback::QueryInterface(REFIID riid, void** ppv) {
		if (riid == IID_IUnknown || riid == __uuidof(IMMNotificationClient)) {
			*ppv = static_cast<IMMNotificationClient*>(this);
			AddRef();
			return S_OK;
		}
		return E_NOINTERFACE;
	}

	STDMETHODIMP_(ULONG) AudioEndpointChangeCallback::AddRef() {
		return InterlockedIncrement(&m_lRefCount);
	}

	STDMETHODIMP_(ULONG) AudioEndpointChangeCallback::Release() {
		ULONG lRefCount = InterlockedDecrement(&m_lRefCount);
		if (lRefCount == 0) {
			delete this;
		}
		return lRefCount;
	}
}
