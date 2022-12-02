#ifndef LINUX_CONSTANTS_H_
#define LINUX_CONSTANTS_H_

constexpr char METHOD_GET_VOLUME[] = "getVolume";
constexpr char METHOD_SET_VOLUME[] = "setVolume";
constexpr char METHOD_RAISE_VOLUME[] = "raiseVolume";
constexpr char METHOD_LOWER_VOLUME[] = "lowerVolume";
constexpr char METHOD_GET_MUTE[] = "getMute";
constexpr char METHOD_SET_MUTE[] = "setMute";

constexpr char ARG_VOLUME[] = "volume";
constexpr char ARG_STEP[] = "step";
constexpr char ARG_EMIT_ON_START[] = "emitOnStart";
constexpr char ARG_IS_MUTED[] = "isMuted";

constexpr char ERROR_CODE_DEFAULT[] = "1000";

constexpr char ERROR_MSG_GET_VOLUME[] = "Failed to get volume";
constexpr char ERROR_MSG_SET_VOLUME[] = "Failed to set volume";
constexpr char ERROR_MSG_RAISE_VOLUME[] = "Failed to raise volume";
constexpr char ERROR_MSG_LOWER_VOLUME[] = "Failed to lower volume";
constexpr char ERROR_MSG_REGISTER_LISTENER[] = "Failed to register volume listener";
constexpr char ERROR_MSG_GET_MUTE[] = "Failed to get mute";
constexpr char ERROR_MSG_SET_MUTE[] = "Failed to set mute";

#endif //LINUX_CONSTANTS_H_
