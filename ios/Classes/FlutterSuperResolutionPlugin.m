#import "FlutterSuperResolutionPlugin.h"
#if __has_include(<flutter_super_resolution/flutter_super_resolution-Swift.h>)
#import <flutter_super_resolution/flutter_super_resolution-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_super_resolution-Swift.h"
#endif

@implementation FlutterSuperResolutionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSuperResolutionPlugin registerWithRegistrar:registrar];
}
@end
