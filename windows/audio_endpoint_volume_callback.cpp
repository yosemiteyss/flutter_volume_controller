#include "include/flutter_volume_controller/audio_endpoint_volume_callback.h"

namespace flutter_volume_controller {
	AudioEndpointVolumeCallback::AudioEndpointVolumeCallback(VolumeChangedCallback pCallback)
		: m_lRefCount(1), m_pCallback(pCallback), m_pDevice(NULL), m_pEndpointVolume(NULL) {

	}

	STDMETHODIMP AudioEndpointVolumeCallback::OnNotify(PAUDIO_VOLUME_NOTIFICATION_DATA pNotify) {
		if (pNotify == NULL) {
			return E_INVALIDARG;
		}

		m_pCallback(pNotify->fMasterVolume);

		return S_OK;
	}

	STDMETHODIMP AudioEndpointVolumeCallback::QueryInterface(REFIID riid, void** ppv) {
		if (riid == IID_IUnknown || riid == __uuidof(IAudioEndpointVolumeCallback)) {
			*ppv = static_cast<IUnknown*>(this);
			AddRef();
			return S_OK;
		}
		return E_NOINTERFACE;
	}

	STDMETHODIMP_(ULONG) AudioEndpointVolumeCallback::AddRef() {
		return InterlockedIncrement(&m_lRefCount);
	}

	STDMETHODIMP_(ULONG) AudioEndpointVolumeCallback::Release() {
		ULONG lRefCount = InterlockedDecrement(&m_lRefCount);
		if (lRefCount == 0) {
			delete this;
		}
		return lRefCount;
	}

	bool AudioEndpointVolumeCallback::Register() {
		HRESULT hr = E_FAIL;

		hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, IID_PPV_ARGS(&m_pEnumerator));
		if (FAILED(hr)) {
			return false;
		}

		hr = m_pEnumerator->GetDefaultAudioEndpoint(eRender, eConsole, &m_pDevice);
		if (FAILED(hr)) {
			return false;
		}

		hr = m_pDevice->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_INPROC_SERVER, NULL, &m_pEndpointVolume);
		if (FAILED(hr)) {
			return false;
		}

		hr = m_pEndpointVolume->RegisterControlChangeNotify(this);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool AudioEndpointVolumeCallback::AudioEndpointVolumeCallback::Cancel() {
		HRESULT hr = E_FAIL;

		hr = m_pEndpointVolume->UnregisterControlChangeNotify(this);

		return SUCCEEDED(hr);
	}
}
