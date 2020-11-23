#import "AtsignAuthenticationHelperPlugin.h"
#if __has_include(<atsign_authentication_helper/atsign_authentication_helper-Swift.h>)
#import <atsign_authentication_helper/atsign_authentication_helper-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "atsign_authentication_helper-Swift.h"
#endif

@implementation AtsignAuthenticationHelperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAtsignAuthenticationHelperPlugin registerWithRegistrar:registrar];
}
@end
