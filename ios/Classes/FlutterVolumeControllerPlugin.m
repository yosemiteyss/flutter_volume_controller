#import "FlutterVolumeControllerPlugin.h"
#if __has_include(<flutter_volume_controller/flutter_volume_controller-Swift.h>)
#import <flutter_volume_controller/flutter_volume_controller-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_volume_controller-Swift.h"
#endif

@implementation FlutterVolumeControllerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVolumeControllerPlugin registerWithRegistrar:registrar];
}
@end
