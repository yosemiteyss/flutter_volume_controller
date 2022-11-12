#ifndef VOLUME_NOTIFICATION_H_
#define VOLUME_NOTIFICATION_H_

#include <endpointvolume.h>
#include <functional>

// Reference from: https://learn.microsoft.com/en-us/windows/win32/coreaudio/endpoint-volume-controls
namespace flutter_volume_controller {
	typedef std::function<void(float)> VolumeCallback;

	class VolumeNotification : public IAudioEndpointVolumeCallback {
	public:
		VolumeNotification(VolumeCallback pCallback);

		STDMETHODIMP_(ULONG) AddRef();

		STDMETHODIMP_(ULONG) Release();

		STDMETHODIMP QueryInterface(REFIID riid, void** ppvObject) override;

		STDMETHODIMP OnNotify(PAUDIO_VOLUME_NOTIFICATION_DATA pNotify) override;

	private:
		volatile LONG lRef;

		VolumeCallback pCallback;
	};
}

#endif
