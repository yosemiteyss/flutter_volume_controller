import { EventSink, StreamHandler } from "@ohos/flutter_ohos";
import { audio } from "@kit.AudioKit";
import { ErrorCode, ErrorMessage, MethodArg } from "./Constants";


export class VolumeStreamHandler implements StreamHandler {
  private audioManager: audio.AudioManager = audio.getAudioManager();
  private audioVolumeManager: audio.AudioVolumeManager = this.audioManager.getVolumeManager();
  private streamUsage: audio.StreamUsage = audio.StreamUsage.STREAM_USAGE_MOVIE;
  private maxVolume: number = 15;

  onListen(args: Object, events: EventSink): void {
    try {
      const argsMap = args as Map<string, Object>;
      const emitOnStart = argsMap.get(MethodArg.EMIT_ON_START) as boolean;

      this.audioVolumeManager.on('streamVolumeChange', audio.StreamUsage.STREAM_USAGE_MOVIE, (event) => {
        events.success((1 / this.maxVolume * event.volume).toString());
      });

      if (emitOnStart) {
        const volume = this.audioVolumeManager.getVolumeByStream(this.streamUsage);
        events.success((1 / this.maxVolume * volume).toString());
      }
    } catch (e) {
      events.error(ErrorCode.REGISTER_VOLUME_LISTENER, ErrorMessage.REGISTER_VOLUME_LISTENER, (e as BusinessError).message);
    }
  }

  onCancel(args: Object): void {
    this.audioVolumeManager.off('streamVolumeChange');
  }
}