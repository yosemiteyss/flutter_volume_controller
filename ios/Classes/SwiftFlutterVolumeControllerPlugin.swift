import Flutter
import UIKit
import AVFoundation

public class SwiftFlutterVolumeControllerPlugin: NSObject, FlutterPlugin {
    private let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private static let volumeController: VolumeController = VolumeController()
    private static let volumeListener: VolumeListener = VolumeListener()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.yosemiteyss.flutter_volume_controller/method",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "com.yosemiteyss.flutter_volume_controller/event",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = SwiftFlutterVolumeControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        eventChannel.setStreamHandler(volumeListener)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodName.getVolume:
            do {
                result(try SwiftFlutterVolumeControllerPlugin.volumeController.getVolume())
            } catch {
                result(FlutterError(code: ErrorCode.getVolume, message: ErrorMessage.getVolume, details: error.localizedDescription))
            }
        case MethodName.setVolume:
            let args = call.arguments as! [String: Any]
            let volume = args[MethodArg.volume] as! Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            SwiftFlutterVolumeControllerPlugin.volumeController.setVolume(volume, showSystemUI: showSystemUI)
        case MethodName.raiseVolume:
            let args = call.arguments as! [String: Any]
            let step = args[MethodArg.step] as? Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            SwiftFlutterVolumeControllerPlugin.volumeController.raiseVolume(step, showSystemUI: showSystemUI)
        case MethodName.lowerVolume:
            let args = call.arguments as! [String: Any]
            let step = args[MethodArg.step] as? Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            SwiftFlutterVolumeControllerPlugin.volumeController.lowerVolume(step, showSystemUI: showSystemUI)
        case MethodName.getMute:
            do {
                result(try SwiftFlutterVolumeControllerPlugin.volumeController.getMute())
            } catch {
                result(FlutterError(code: ErrorCode.getMute, message: ErrorMessage.getMute, details: error.localizedDescription))
            }
        case MethodName.setMute:
            let args = call.arguments as! [String: Any]
            let isMuted = args[MethodArg.isMuted] as! Bool
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.setMute(isMuted, showSystemUI: showSystemUI)
            } catch {
                result(FlutterError(code: ErrorCode.setMute, message: ErrorMessage.setMute, details: error.localizedDescription))
            }
        case MethodName.toggleMute:
            let args = call.arguments as! [String: Any]
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.toggleMute(showSystemUI: showSystemUI)
            } catch {
                result(FlutterError(code: ErrorCode.toggleMute, message: ErrorMessage.toggleMute, details: error.localizedDescription))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftFlutterVolumeControllerPlugin : FlutterApplicationLifeCycleDelegate {
    public func applicationWillEnterForeground(_ application: UIApplication) {
        if SwiftFlutterVolumeControllerPlugin.volumeListener.isListening {
            do {
                try audioSession.setActive(true)
            } catch {
                print("Error reactivating audio session")
            }
        }
    }
}
