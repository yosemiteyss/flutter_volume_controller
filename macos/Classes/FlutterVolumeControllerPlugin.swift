import Cocoa
import FlutterMacOS

public class FlutterVolumeControllerPlugin: NSObject, FlutterPlugin {
    private static let volumeController: VolumeController = VolumeController()
    private static let volumeListener: VolumeListener = VolumeListener(volumeController: volumeController)
    private static let defaultOutputDeviceListener: DefaultOutputDeviceListener = DefaultOutputDeviceListener()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.yosemiteyss.flutter_volume_controller/method",
            binaryMessenger: registrar.messenger
        )
        let eventChannel = FlutterEventChannel(
            name: "com.yosemiteyss.flutter_volume_controller/event",
            binaryMessenger: registrar.messenger
        )
        let defaultOutputDeviceChannel = FlutterEventChannel(
            name: "com.yosemiteyss.flutter_volume_controller/default-output-device",
            binaryMessenger: registrar.messenger
        )
        
        let instance = FlutterVolumeControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
        eventChannel.setStreamHandler(volumeListener)
        defaultOutputDeviceChannel.setStreamHandler(defaultOutputDeviceListener)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case MethodName.getVolume:
            do {
                let volume = try FlutterVolumeControllerPlugin.volumeController.getVolume()
                result(String(volume))
            } catch {
                result(FlutterError(code: ErrorCode.getVolume, message: ErrorMessage.getVolume, details: error.localizedDescription))
            }
        case MethodName.setVolume:
            do {
                let args = call.arguments as! [String: Any]
                let volume = args[MethodArg.volume] as! Double
                
                try FlutterVolumeControllerPlugin.volumeController.setVolume(Float(volume))
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setVolume, message: ErrorMessage.setVolume, details: error.localizedDescription))
            }
        case MethodName.raiseVolume:
            do {
                let args = call.arguments as! [String: Any]
                
                if let step = args[MethodArg.step] as? Double {
                    try FlutterVolumeControllerPlugin.volumeController.raiseVolume(Float(step))
                } else {
                    try FlutterVolumeControllerPlugin.volumeController.raiseVolume(nil)
                }
                
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.raiseVolume, message: ErrorMessage.raiseVolume, details: error.localizedDescription))
            }
        case MethodName.lowerVolume:
            do {
                let args = call.arguments as! [String: Any]
                
                if let step = args[MethodArg.step] as? Double {
                    try FlutterVolumeControllerPlugin.volumeController.lowerVolume(Float(step))
                } else {
                    try FlutterVolumeControllerPlugin.volumeController.lowerVolume(nil)
                }
                
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.lowerVolume, message: ErrorMessage.lowerVolume, details: error.localizedDescription))
            }
        case MethodName.getMute:
            do {
                result(try FlutterVolumeControllerPlugin.volumeController.getMute())
            } catch {
                result(FlutterError(code: ErrorCode.getMute, message: ErrorMessage.getMute, details: error.localizedDescription))
            }
        case MethodName.setMute:
            do {
                let args = call.arguments as! [String: Any]
                let isMuted = args[MethodArg.isMuted] as! Bool
                
                try FlutterVolumeControllerPlugin.volumeController.setMute(isMuted)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setMute, message: ErrorMessage.setMute, details: error.localizedDescription))
            }
        case MethodName.toggleMute:
            do {
                try FlutterVolumeControllerPlugin.volumeController.toggleMute()
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.toggleMute, message: ErrorMessage.toggleMute, details: error.localizedDescription))
            }
        case MethodName.getDefaultOutputDevice:
            do {
                let device = try FlutterVolumeControllerPlugin.volumeController.getDefaultOutputDevice()
                let json = device.toJSONString()
                result(json)
            } catch {
                result(FlutterError(code: ErrorCode.getDefaultOutputDevice, message: ErrorMessage.getDefaultOutputDevice, details: error.localizedDescription))
            }
        case MethodName.setDefaultOutputDevice:
            do {
                let args = call.arguments as! [String: Any]
                let deviceId = args[MethodArg.deviceId] as! String
                try FlutterVolumeControllerPlugin.volumeController.setDefaultOutputDevice(deviceId)
                result(nil)
            } catch {
                result(FlutterError(code: ErrorCode.setDefaultOutputDevice, message: ErrorMessage.setDefaultOutputDevice, details: error.localizedDescription))
            }
        case MethodName.getOutputDeviceList:
            do {
                let deviceList = try FlutterVolumeControllerPlugin.volumeController.getOutputDeviceList()
                let jsonList = deviceList.map { device in device.toJSONString() }
                result(jsonList)
            } catch {
                result(FlutterError(code: ErrorCode.getOutputDeviceList, message: ErrorMessage.getOutputDeviceList, details: error.localizedDescription))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
