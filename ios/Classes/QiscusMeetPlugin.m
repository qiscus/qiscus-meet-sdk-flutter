#import "QiscusMeetPlugin.h"
#if __has_include(<qiscus_meet/qiscus_meet-Swift.h>)
#import <qiscus_meet/qiscus_meet-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "qiscus_meet-Swift.h"
#endif

@implementation QiscusMeetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQiscusMeetPlugin registerWithRegistrar:registrar];
}
@end
