#include "include/flutter_volume_controller/volume_controller.h"
#include "include/flutter_volume_controller/policy_config.h"

#include <atlstr.h>
#include <windows.h>
#include <functiondiscoverykeys_devpkey.h>

#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "uuid.lib")
#pragma comment(lib, "Winmm.lib")

namespace flutter_volume_controller {
	VolumeController::VolumeController() {}

	VolumeController& VolumeController::GetInstance() {
		static VolumeController instance;
		return instance;
	}

	bool VolumeController::Init() {
		HRESULT hr = E_FAIL;

		// Create enumerator.
		hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, IID_PPV_ARGS(&m_pEnumerator));
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	void VolumeController::Dispose() {
		//if (endpoint_volume) {
		//	DisposeNotification();
		//	endpoint_volume->Release();
		//}

		//CoUninitialize();
	}

	//void VolumeController::DisposeNotification() {
	//	if (volume_notification) {
	//		if (endpoint_volume) {
	//			endpoint_volume->UnregisterControlChangeNotify(volume_notification);
	//		}
	//		volume_notification->Release();
	//	}
	//}

	bool VolumeController::SetVolume(float volume) {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		if (!SetMute(false)) {
			return false;
		}

		float normalizedVolume = std::min<float>(std::max<float>(0, volume), 1);

		hr = m_pEndpointVolume->SetMasterVolumeLevelScalar(normalizedVolume, NULL);
		if (FAILED(hr)) {
			return false;
		}

		// COM cleanup is automatic with ComPtr

		return true;
	}

	bool VolumeController::SetMaxVolume() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		UINT currentStep, stepCount;
		hr = m_pEndpointVolume->GetVolumeStepInfo(&currentStep, &stepCount);
		if (FAILED(hr)) {
			return false;
		}

		if (!SetMute(false)) {
			return false;
		}

		for (UINT index = currentStep; index < stepCount; index++) {
			if (!RaiseVolume()) {
				return false;
			}
		}

		return true;
	}

	bool VolumeController::SetMinVolume() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		UINT currentStep, stepCount;
		hr = m_pEndpointVolume->GetVolumeStepInfo(&currentStep, &stepCount);
		if (FAILED(hr)) {
			return false;
		}

		if (!SetMute(false)) {
			return false;
		}

		for (UINT index = currentStep; index > 0; index--) {
			if (!LowerVolume()) {
				return false;
			}
		}

		return true;
	}

	bool VolumeController::RaiseVolume(float step) {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		std::optional<float> currentVolume = GetVolume();
		if (!currentVolume.has_value()) {
			return false;
		}

		float volume = currentVolume.value();
		float normalizedVolume = (1 - volume) < step ? 1 : volume + step;

		hr = m_pEndpointVolume->SetMasterVolumeLevelScalar(normalizedVolume, NULL);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool VolumeController::LowerVolume(float step) {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		std::optional<float> currentVolume = GetVolume();
		if (!currentVolume.has_value()) {
			return false;
		}

		float volume = currentVolume.value();
		float normalizedVolume = volume < step ? 0 : volume - step;

		hr = m_pEndpointVolume->SetMasterVolumeLevelScalar(normalizedVolume, NULL);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool VolumeController::RaiseVolume() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		hr = m_pEndpointVolume->VolumeStepUp(NULL);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool VolumeController::LowerVolume() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		hr = m_pEndpointVolume->VolumeStepDown(NULL);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool VolumeController::SetMute(bool isMuted) {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		hr = m_pEndpointVolume->SetMute(isMuted, NULL);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}

	bool VolumeController::ToggleMute() {
		std::optional<bool> isMuted = GetMute();

		if (!isMuted.has_value()) {
			return false;
		}

		return SetMute(!isMuted.value());
	}

	std::optional<float> VolumeController::GetVolume() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		float currentVolume = 0.0f;

		hr = m_pEndpointVolume->GetMasterVolumeLevelScalar(&currentVolume);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		return currentVolume;
	}

	std::optional<bool> VolumeController::GetMute() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return false;
		}

		BOOL isMuted = false;

		hr = m_pEndpointVolume->GetMute(&isMuted);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		return isMuted;
	}

	std::optional<OutputDevice> VolumeController::GetDefaultOutputDevice() {
		ComPtr<IMMDevice> pDevice;
		ComPtr<IAudioEndpointVolume> m_pEndpointVolume;

		if (!InitializeAudio(pDevice, m_pEndpointVolume)) {
			return std::nullopt;
		}

		std::optional<OutputDevice> outputDevice = this->GetOutputDevice(pDevice);
		if (!outputDevice.has_value()) {
			return std::nullopt;
		}

		return outputDevice;
	}

	bool VolumeController::setDefaultOutputDevice(LPCWSTR pwstrDeviceId) {
		HRESULT hr = E_FAIL;
		hr = this->SetDefaultAudioPlaybackDevice(pwstrDeviceId);
		return SUCCEEDED(hr);
	}

	std::optional<std::vector<OutputDevice>> VolumeController::GetOutputDeviceList() {
		HRESULT hr = E_FAIL;
		ComPtr<IMMDeviceCollection> pCollection;

		hr = m_pEnumerator->EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE, &pCollection);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		// Get devices count.
		UINT count;
		hr = pCollection->GetCount(&count);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		// Put devices to list.
		std::vector<OutputDevice> devices;

		for (UINT i = 0; i < count; i++) {
			ComPtr<IMMDevice> pDevice;
			hr = pCollection->Item(i, &pDevice);
			if (SUCCEEDED(hr)) {
				std::optional<OutputDevice> outputDevice = GetOutputDevice(pDevice);
				if (outputDevice.has_value()) {
					devices.push_back(outputDevice.value());
				}
			}
		}

		return devices;
	}

	std::optional<OutputDevice> VolumeController::GetOutputDevice(ComPtr<IMMDevice>& pDevice) {
		std::optional<std::string> pwstrDeviceId = this->GetAudioDeviceID(pDevice);

		if (!pwstrDeviceId.has_value()) {
			return std::nullopt;
		}

		std::optional<std::string> pDeviceName = this->GetAudioDeviceName(pDevice);

		OutputDevice outputDevice = OutputDevice(pwstrDeviceId.value(), pDeviceName.value(), TRUE);
		return outputDevice;
	}

	std::optional<std::string> VolumeController::GetAudioDeviceID(ComPtr<IMMDevice>& pDevice) {
		HRESULT hr = E_FAIL;
		LPWSTR pwstrDeviceId;

		hr = pDevice->GetId(&pwstrDeviceId);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		std::string device_id_str = CW2A(pwstrDeviceId);

		CoTaskMemFree(pwstrDeviceId);

		return device_id_str;
	}

	std::optional<std::string> VolumeController::GetAudioDeviceName(ComPtr<IMMDevice>& pDevice) {
		HRESULT hr = E_FAIL;
		ComPtr<IPropertyStore> propertyStore;

		hr = pDevice->OpenPropertyStore(STGM_READ, &propertyStore);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		PROPVARIANT propFriendlyName;
		PropVariantInit(&propFriendlyName);

		hr = propertyStore->GetValue(PKEY_Device_FriendlyName, &propFriendlyName);
		if (FAILED(hr)) {
			return std::nullopt;
		}

		LPWSTR pDeviceName = propFriendlyName.pwszVal;
		std::string sDeviceName = CW2A(pDeviceName, CP_UTF8);

		PropVariantClear(&propFriendlyName);

		return sDeviceName;
	}

	HRESULT VolumeController::SetDefaultAudioPlaybackDevice(LPCWSTR pwstrDeviceId) {
		HRESULT hr = E_FAIL;
		ComPtr<IPolicyConfigVista> pPolicyConfig;
		ERole reserved = eConsole;

		hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, IID_PPV_ARGS(&pPolicyConfig));

		if (SUCCEEDED(hr)) {
			hr = pPolicyConfig->SetDefaultEndpoint(pwstrDeviceId, reserved);
		}

		return hr;
	}

	bool VolumeController::InitializeAudio(ComPtr<IMMDevice>& pDevice, ComPtr<IAudioEndpointVolume>& m_pEndpointVolume) {
		HRESULT hr = E_FAIL;

		hr = m_pEnumerator->GetDefaultAudioEndpoint(eRender, eConsole, &pDevice);
		if (FAILED(hr)) {
			return false;
		}

		hr = pDevice->Activate(__uuidof(IAudioEndpointVolume), CLSCTX_INPROC_SERVER, NULL, &m_pEndpointVolume);
		if (FAILED(hr)) {
			return false;
		}

		return true;
	}
}
