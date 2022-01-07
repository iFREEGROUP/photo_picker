#import "PhotoPickerPlugin.h"
#if __has_include(<photo_picker/photo_picker-Swift.h>)
#import <photo_picker/photo_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "photo_picker-Swift.h"
#endif

@implementation PhotoPickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPhotoPickerPlugin registerWithRegistrar:registrar];
}
@end
