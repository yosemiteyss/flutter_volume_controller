import Cocoa
import FlutterMacOS

public class FlutterVolumeControllerPlugin: NSObject, FlutterPlugin {
    private static let volumeController: VolumeController = VolumeController()
    private static let volumeListener: VolumeListener = VolumeListener(volumeController: volumeController)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.yosemiteyss.flutter_volume_controller/method",
            binaryMessenger: registrar.messenger
        )
        let eventChannel = FlutterEventChannel(
            name: "com.yosemiteyss.flutter_volume_controller/event",
            binaryMessenger: registrar.messenger
        )
        
        let instance = FlutterVolumeControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        eventChannel.setStreamHandler(volumeListener)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodName.getVolume:
            do {
                result(try FlutterVolumeControllerPlugin.volumeController.getVolume())
            } catch {
                result(FlutterError(code: ErrorCode.getVolume, message: ErrorMessage.getVolume, details: error.localizedDescription))
            }
        case MethodName.setVolume:
            do {
                let args = call.arguments as! [String: Any]
                let volume = args[MethodArg.volume] as! Double
                
                try FlutterVolumeControllerPlugin.volumeController.setVolume(volume)
            } catch {
                result(FlutterError(code: ErrorCode.setVolume, message: ErrorMessage.setVolume, details: nil))
            }
        case MethodName.raiseVolume:
            do {
                let args = call.arguments as! [String: Any]
                let step = args[MethodArg.step] as? Double
                
                try FlutterVolumeControllerPlugin.volumeController.raiseVolume(step)
            } catch {
                result(FlutterError(code: ErrorCode.raiseVolume, message: ErrorMessage.raiseVolume, details: nil))
            }
        case MethodName.lowerVolume:
            do {
                let args = call.arguments as! [String: Any]
                let step = args[MethodArg.step] as? Double
                
                try FlutterVolumeControllerPlugin.volumeController.lowerVolume(step)
            } catch {
                result(FlutterError(code: ErrorCode.lowerVolume, message: ErrorMessage.lowerVolume, details: nil))
            }
        case MethodName.getMute:
            do {
                result(try FlutterVolumeControllerPlugin.volumeController.getMute())
            } catch {
                result(FlutterError(code: ErrorCode.getMute, message: ErrorMessage.getMute, details: nil))
            }
        case MethodName.setMute:
            do {
                let args = call.arguments as! [String: Any]
                let isMuted = args[MethodArg.isMuted] as! Bool
                
                try FlutterVolumeControllerPlugin.volumeController.setMute(isMuted)
            } catch {
                result(FlutterError(code: ErrorCode.setMute, message: ErrorMessage.setMute, details: nil))
            }
        case MethodName.toggleMute:
            do {
                try FlutterVolumeControllerPlugin.volumeController.toggleMute()
            } catch {
                result(FlutterError(code: ErrorCode.toggleMute, message: ErrorMessage.toggleMute, details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
