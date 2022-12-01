#ifndef CONSTANTS_H_
#define CONSTANTS_H_

namespace flutter_volume_controller {
	namespace constants {
		constexpr char kMethodGetVolume[] = "getVolume";
		constexpr char kMethodSetVolume[] = "setVolume";
		constexpr char kMethodRaiseVolume[] = "raiseVolume";
		constexpr char kMethodLowerVolume[] = "lowerVolume";

		constexpr char kArgVolume[] = "volume";
		constexpr char kArgStep[] = "step";
		constexpr char kEmitOnStart[] = "emitOnStart";

		constexpr char kErrorCode[] = "1000";
		constexpr char kErrorGetVolume[] = "Failed to get volume";
		constexpr char kErrorSetVolume[] = "Failed to set volume";
		constexpr char kErrorRaiseVolume[] = "Failed to raise volume";
		constexpr char kErrorLowerVolume[] = "Failed to lower volume";
		constexpr char kErrorRegisterListener[] = "Failed to register volume listener";
	}
}

#endif
