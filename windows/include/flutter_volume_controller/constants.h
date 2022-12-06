#ifndef CONSTANTS_H_
#define CONSTANTS_H_

namespace flutter_volume_controller {
	namespace constants {
		constexpr char kMethodGetVolume[] = "getVolume";
		constexpr char kMethodSetVolume[] = "setVolume";
		constexpr char kMethodRaiseVolume[] = "raiseVolume";
		constexpr char kMethodLowerVolume[] = "lowerVolume";
		constexpr char kMethodGetMute[] = "getMute";
		constexpr char kMethodSetMute[] = "setMute";
		constexpr char kMethodToggleMute[] = "toggleMute";

		constexpr char kArgVolume[] = "volume";
		constexpr char kArgStep[] = "step";
		constexpr char kArgEmitOnStart[] = "emitOnStart";
		constexpr char kArgIsMuted[] = "isMuted";

		constexpr char kErrCodeGetVolume[] = "1000";
		constexpr char kErrCodeSetVolume[] = "1001";
		constexpr char kErrCodeRaiseVolume[] = "1002";
		constexpr char kErrCodeLowerVolume[] = "1003";
		constexpr char kErrCodeRegVolumeListener[] = "1004";
		constexpr char kErrCodeGetMute[] = "1005";
		constexpr char kErrCodeSetMute[] = "1006";
		constexpr char kErrCodeToggleMute[] = "1007";

		constexpr char kErrMsgGetVolume[] = "Failed to get volume";
		constexpr char kErrMsgSetVolume[] = "Failed to set volume";
		constexpr char kErrMsgRaiseVolume[] = "Failed to raise volume";
		constexpr char kErrMsgLowerVolume[] = "Failed to lower volume";
		constexpr char kErrMsgRegVolumeListener[] = "Failed to register volume listener";
		constexpr char kErrMsgGetMute[] = "Failed to get mute";
		constexpr char kErrMsgSetMute[] = "Failed to set mute";
		constexpr char kErrMsgToggleMute[] = "Failed to toggle mute";
	}
}

#endif
