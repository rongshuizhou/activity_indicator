#import "ActivityIndicatorPlugin.h"
#import "FlutterActivityIndicator.h"

@implementation ActivityIndicatorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [registrar registerViewFactory:[[FlutterActivityIndicatorFactory alloc] initWithMessenger:registrar.messenger] withId:@"plugins/activity_indicator"];
    
}




@end
