import AVFoundation
import Flutter
import UIKit

public class SwiftFlutterVolumeControllerPlugin: NSObject, FlutterPlugin {
    private static let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private static let volumeController: VolumeController = .init(audioSession: audioSession)
    private static let volumeListener: VolumeListener = .init(audioSession: audioSession, volumeController: volumeController)
    
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
                let volume = try SwiftFlutterVolumeControllerPlugin.volumeController.getVolume()
                result(String(volume))
            } catch {
                result(FlutterError(code: ErrorCode.getVolume, message: ErrorMessage.getVolume, details: error.localizedDescription))
            }
        case MethodName.setVolume:
            let args = call.arguments as! [String: Any]
            let volume = args[MethodArg.volume] as! Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.setVolume(volume, showSystemUI: showSystemUI)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setVolume, message: ErrorMessage.setVolume, details: error.localizedDescription))
            }
        case MethodName.raiseVolume:
            let args = call.arguments as! [String: Any]
            let step = args[MethodArg.step] as? Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.raiseVolume(step, showSystemUI: showSystemUI)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.raiseVolume, message: ErrorMessage.raiseVolume, details: error.localizedDescription))
            }
        case MethodName.lowerVolume:
            let args = call.arguments as! [String: Any]
            let step = args[MethodArg.step] as? Double
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.lowerVolume(step, showSystemUI: showSystemUI)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.lowerVolume, message: ErrorMessage.lowerVolume, details: error.localizedDescription))
            }
            
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
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setMute, message: ErrorMessage.setMute, details: error.localizedDescription))
            }
        case MethodName.toggleMute:
            let args = call.arguments as! [String: Any]
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.toggleMute(showSystemUI: showSystemUI)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.toggleMute, message: ErrorMessage.toggleMute, details: error.localizedDescription))
            }
        case MethodName.setIOSAudioSessionCategory:
            let args = call.arguments as! [String: Any]
            let index = args[MethodArg.audioSessionCategory] as! Int
            let category = AudioSessionCategory.allCases[index]
            
            do {
                try SwiftFlutterVolumeControllerPlugin.volumeController.setAudioSessionCategory(category)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setIOSAudioSessionCategory, message: ErrorMessage.setIOSAudioSessionCategory, details: error.localizedDescription))
            }
        case MethodName.getIOSAudioSessionCategory:
            do {
                let category = try SwiftFlutterVolumeControllerPlugin.volumeController.getAudioSessionCategory()
                result(category?.ordinal)
            } catch {
                result(FlutterError(code: ErrorCode.getIOSAudioSessionCategory, message: ErrorMessage.getIOSAudioSessionCategory, details: error.localizedDescription))
            }
        case MethodName.updateShowSystemUI:
            let args = call.arguments as! [String: Any]
            let showSystemUI = args[MethodArg.showSystemUI] as! Bool
            SwiftFlutterVolumeControllerPlugin.volumeController.setShowSystemUI(showSystemUI)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension SwiftFlutterVolumeControllerPlugin: FlutterApplicationLifeCycleDelegate {
    public func applicationWillEnterForeground(_ application: UIApplication) {
        let isListening = SwiftFlutterVolumeControllerPlugin.volumeListener.isListening
        if isListening {
            try? SwiftFlutterVolumeControllerPlugin.volumeController.resumeAudioSession()
        }
    }
}
