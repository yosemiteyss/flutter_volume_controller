import { audio } from "@kit.AudioKit";
import { VolumePanelNode } from "./Extensions";

export class VolumeController {
  private audioManager: audio.AudioManager = audio.getAudioManager();
  private audioVolumeManager: audio.AudioVolumeManager = this.audioManager.getVolumeManager();
  private volumePanel?: VolumePanelNode;
  private streamUsage: audio.StreamUsage = audio.StreamUsage.STREAM_USAGE_MOVIE;
  private maxVolume: number = 15;
  private unMuteVolume: number = 0;
  private sysStep: number = 0.0625;

  constructor(volumePanel?: VolumePanelNode) {
    this.volumePanel = volumePanel;
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   * @returns - Volume from 0.0 to 1.0
   */
  getVolume(): number {
    const volume = this.audioVolumeManager.getVolumeByStream(this.streamUsage);
    return 1 / this.maxVolume * volume;
  }

  /**
   * @param volume - Volume from 0.0 to 1.0
   */
  setVolume(volume: number) {
    this.volumePanel?.changeVolume(volume * this.maxVolume);
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   */
  raiseVolume(step: number | null) {
    const stepVal = step ? step : this.sysStep;
    const currentVol = this.audioVolumeManager.getVolumeByStream(this.streamUsage);
    const targetVol = Math.min(this.maxVolume, currentVol + stepVal * this.maxVolume);
    this.volumePanel?.changeVolume(targetVol);
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   */
  lowerVolume(step: number | null) {
    const stepVal = step ? step : this.sysStep;
    const currentVol = this.audioVolumeManager.getVolumeByStream(this.streamUsage);
    const targetVol = Math.max(0, currentVol - stepVal * this.maxVolume);
    this.volumePanel?.changeVolume(targetVol);
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   */
  getMute(): boolean {
    return this.audioVolumeManager.isSystemMutedForStream(this.streamUsage);
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   */
  setMute(muted: boolean) {
    if (muted) {
      this.unMuteVolume = this.audioVolumeManager.getVolumeByStream(this.streamUsage);
      this.volumePanel?.changeVolume(0);
    } else {
      this.volumePanel?.changeVolume(this.unMuteVolume);
    }
  }

  /**
   * @throws { BusinessError } 6800101 - Parameter verification failed.
   */
  toggleMute() {
    const muted = this.getMute();
    this.setMute(!muted);
  }

  updateShowSystemUI(show: boolean) {
    this.volumePanel?.changeShowSystemUI(show);
  }
}