import {
  AbilityAware,
  AbilityPluginBinding,
  EventChannel,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { VolumePanelNode } from './Extensions';
import { ErrorCode, ErrorMessage, MethodArg, MethodName } from './Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { VolumeController } from './VolumeController';
import { VolumeStreamHandler } from './VolumeStreamHandler';

const METHOD_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/method"
const EVENT_CHANNEL_NAME = "com.yosemiteyss.flutter_volume_controller/event"

/** FlutterVolumeControllerPlugin **/
export default class FlutterVolumeControllerPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private methodChannel?: MethodChannel;
  private eventChannel?: EventChannel;
  private context?: common.UIAbilityContext;
  private volumePanel?: VolumePanelNode;
  private volumeController?: VolumeController;
  private volumeStreamHandler: VolumeStreamHandler = new VolumeStreamHandler();

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
    this.volumePanel = new VolumePanelNode(this.context);
    this.volumeController = new VolumeController(this.volumePanel);
  }

  onDetachedFromAbility(): void {
    this.volumePanel?.dispose();
    this.volumePanel = undefined;
    this.volumeController = undefined;
    this.context = undefined;
  }

  getUniqueClassName(): string {
    return "FlutterVolumeControllerPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), METHOD_CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this)
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), EVENT_CHANNEL_NAME);
    this.eventChannel.setStreamHandler(this.volumeStreamHandler);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodChannel?.setMethodCallHandler(null);
    this.eventChannel?.setStreamHandler(null);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case MethodName.GET_VOLUME:
        try {
          const volume = this.volumeController?.getVolume();
          result.success(volume?.toString());
        } catch (e) {
          result.error(ErrorCode.GET_VOLUME, ErrorMessage.GET_VOLUME, (e as BusinessError).message)
        }
        break;
      case MethodName.SET_VOLUME:
        try {
          const volume = Number(call.argument(MethodArg.VOLUME));
          this.volumeController?.setVolume(volume);
        } catch (e) {
          result.error(ErrorCode.SET_VOLUME, ErrorMessage.SET_VOLUME, (e as BusinessError).message)
        }
        result.success(null);
        break;
      case MethodName.RAISE_VOLUME:
        try {
          const step: number | null = call.argument(MethodArg.STEP);
          this.volumeController?.raiseVolume(step);
        } catch (e) {
          result.error(ErrorCode.RAISE_VOLUME, ErrorMessage.RAISE_VOLUME, (e as BusinessError).message)
        }
        result.success(null);
        break;
      case MethodName.LOWER_VOLUME:
        try {
          const step: number | null = call.argument(MethodArg.STEP);
          this.volumeController?.lowerVolume(step);
        } catch (e) {
          result.error(ErrorCode.LOWER_VOLUME, ErrorMessage.LOWER_VOLUME, (e as BusinessError).message)
        }
        result.success(null);
        break;
      case MethodName.GET_MUTE:
        try {
          result.success(this.volumeController?.getMute());
        } catch (e) {
          result.error(ErrorCode.GET_MUTE, ErrorMessage.GET_MUTE, (e as BusinessError).message)
        }
        break;
      case MethodName.SET_MUTE:
        try {
          const muted = Boolean(call.argument(MethodArg.IS_MUTED));
          this.volumeController?.setMute(muted);
        } catch (e) {
          result.error(ErrorCode.SET_MUTE, ErrorMessage.SET_MUTE, (e as BusinessError).message)
        }
        result.success(null);
        break;
      case MethodName.TOGGLE_MUTE:
        try {
          this.volumeController?.toggleMute();
        } catch (e) {
          result.error(ErrorCode.TOGGLE_MUTE, ErrorMessage.TOGGLE_MUTE, (e as BusinessError).message)
        }
        result.success(null);
        break;
      case MethodName.UPDATE_SHOW_SYSTEM_UI:
        try {
          const show = Boolean(call.argument(MethodArg.SHOW_SYSTEM_UI));
          this.volumeController?.updateShowSystemUI(show);
        } catch (e) {
          result.error(ErrorCode.TOGGLE_MUTE, ErrorMessage.TOGGLE_MUTE, (e as BusinessError).message)
        }
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}