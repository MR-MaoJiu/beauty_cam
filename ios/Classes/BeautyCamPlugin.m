#import "BeautyCamPlugin.h"
#import "CameraFlutterPluginViewFactory.h"

@implementation BeautyCamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    
    // 这里是对原生部分的界面与Flutter的一个关联
    CameraFlutterPluginViewFactory *testViewFactory = [[CameraFlutterPluginViewFactory alloc] initWithMessenger:registrar.messenger];
    //这里填写的id 一定要和dart里面的viewType 这个参数传的id一致
    [registrar registerViewFactory:testViewFactory withId:@"beauty_cam"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
