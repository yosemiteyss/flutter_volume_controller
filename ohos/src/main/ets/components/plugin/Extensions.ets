import { AVVolumePanel } from '@kit.AudioKit'
import { BuilderNode, NodeController, UIContext } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit';

interface VolumeConfig {
  volume?: number;
  showSystemUI?: boolean;
}

class VolumeParams {
  volume: number;
  showSystemUI: boolean;

  constructor(config: VolumeConfig = {}) {
    this.volume = config.volume ?? 0;
    this.showSystemUI = config.showSystemUI ?? true;
  }
}

@Builder
function VolumePanel(param: VolumeParams) {
  AVVolumePanel({
    volumeLevel: param.volume,
    volumeParameter: param.showSystemUI
      ? undefined
      : {
        position: {
          x: -100,
          y: -100
        }
      }
  })
}

export class VolumePanelNode extends NodeController {
  private node: BuilderNode<[VolumeParams]> | null = null;
  private volumeParams = new VolumeParams();
  private context?: common.UIAbilityContext;
  private initializing: boolean = false;
  private disposed: boolean = false;
  private retryTimer?: number;

  constructor(ctx?: common.UIAbilityContext) {
    super();
    this.context = ctx;
    this.ensureInitialized();
  }

  dispose(): void {
    this.disposed = true;
    if (this.retryTimer !== undefined) {
      clearTimeout(this.retryTimer);
      this.retryTimer = undefined;
    }
  }

  ensureInitialized(): void {
    if (this.disposed || this.node || this.initializing) {
      return;
    }

    const windowStage = this.context?.windowStage;
    if (!windowStage) {
      this.scheduleRetry();
      return;
    }

    this.initializing = true;
    windowStage.getMainWindow().then((mainWindow) => {
      this.initializing = false;
      if (this.disposed || this.node) {
        return;
      }
      try {
        this.node = new BuilderNode(mainWindow.getUIContext());
        this.node.build(wrapBuilder<[VolumeParams]>(VolumePanel), this.volumeParams);
      } catch (_) {
        this.node = null;
        this.scheduleRetry();
      }
    }).catch(() => {
      this.initializing = false;
      this.scheduleRetry();
    });
  }

  private scheduleRetry(): void {
    if (this.disposed || this.node || this.retryTimer !== undefined) {
      return;
    }
    this.retryTimer = setTimeout(() => {
      this.retryTimer = undefined;
      this.ensureInitialized();
    }, 50);
  }

  makeNode(_: UIContext): FrameNode | null {
    return this.node ? this.node.getFrameNode() : null;
  }

  /**
   * @param vol - AVVolumePanel receive volume from 0 to 15
   */
  changeVolume(vol: number) {
    this.volumeParams.volume = Math.round(vol);
    if (this.node) {
      this.node.update(this.volumeParams);
      return;
    }
    this.ensureInitialized();
  }

  changeShowSystemUI(show: boolean) {
    this.volumeParams.showSystemUI = show;
    if (this.node) {
      this.node.update(this.volumeParams);
      return;
    }
    this.ensureInitialized();
  }
}