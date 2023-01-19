/// Android audio stream type.
///
/// [AudioStream.voiceCall] -> AudioManager.STREAM_VOICE_CALL
/// [AudioStream.system] -> AudioManager.AudioManager.STREAM_SYSTEM
/// [AudioStream.ring] -> AudioManager.STREAM_RING
/// [AudioStream.music] -> AudioManager.STREAM_MUSIC
/// [AudioStream.alarm] -> AudioManager.STREAM_ALARM
enum AudioStream {
  voiceCall,
  system,
  ring,
  music,
  alarm,
}
