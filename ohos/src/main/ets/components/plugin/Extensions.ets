import { AVVolumePanel } from '@kit.AudioKit'
import { BuilderNode, NodeController, UIContext, window } from '@kit.ArkUI'
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

  constructor(ctx?: common.UIAbilityContext) {
    super();
    this.node = new BuilderNode(UIContext.resolveUIContext());
    this.node.build(wrapBuilder<[VolumeParams]>(VolumePanel), this.volumeParams);
    // window.getLastWindow(ctx).then((window) => {
    //   try {
    //     this.node = new BuilderNode(window.getUIContext());
    //     this.node.build(wrapBuilder<[VolumeParams]>(VolumePanel), this.volumeParams);
    //   } catch (e) {
    //     console.log(e)
    //   }
    // }).catch((err: BusinessError) => {
    //   console.error(`Failed to obtain the top window. Cause code: ${err.code}, message: ${err.message}`);
    // });
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    return this.node ? this.node.getFrameNode() : null;
  }

  /**
   * @param vol - AVVolumePanel receive volume from 0 to 15
   */
  changeVolume(vol: number) {
    if (this.node) {
      this.volumeParams.volume = vol;
      this.node.update(this.volumeParams);
    }
  }

  changeShowSystemUI(show: boolean) {
    if (this.node) {
      this.volumeParams.showSystemUI = show
      this.node.update(this.volumeParams);
    }
  }
}