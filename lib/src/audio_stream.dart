/// Enum class mapped to Android audio stream types.
enum AudioStream {
  /// Used to identify the volume of audio streams for accessibility prompts.
  accessibility,

  /// Used to identify the volume of audio streams for alarms.
  alarm,

  /// Used to identify the volume of audio streams for DTMF Tones.
  dtmf,

  /// Used to identify the volume of audio streams for music playback.
  music,

  /// Used to identify the volume of audio streams for notifications.
  notification,

  /// Used to identify the volume of audio streams for the phone ring.
  ring,

  /// Used to identify the volume of audio streams for system sounds.
  system,

  /// Used to identify the volume of audio streams for phone calls.
  voiceCall,
}
