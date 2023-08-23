#import "BeautyCamPlugin.h"
#import "CameraFlutterPluginViewFactory.h"
#import <cge/cge.h>


NSString* loadImageResource;
UIImage* loadImageCallback(const char* name, void* arg)
{
//    NSString* filename = [NSString stringWithUTF8String:name];
//    return [UIImage imageNamed:filename];

        NSString* fileName = [NSString stringWithUTF8String:name];
        if(loadImageResource==nil){
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            loadImageResource= [paths objectAtIndex:0];
        }
       NSString* imagePath = [loadImageResource stringByAppendingPathComponent:fileName];
       UIImage* image = [UIImage imageWithContentsOfFile:imagePath];
       return image;
    
}

void loadImageOKCallback(UIImage* img, void* arg)
{
    
}
@implementation BeautyCamPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    cgeSetLoadImageCallback(loadImageCallback, loadImageOKCallback, nil);
    // 这里是对原生部分的界面与Flutter的一个关联
    CameraFlutterPluginViewFactory *testViewFactory = [[CameraFlutterPluginViewFactory alloc] initWithMessenger:registrar.messenger];
    //这里填写的id 一定要和dart里面的viewType 这个参数传的id一致
    [registrar registerViewFactory:testViewFactory withId:@"beauty_cam"];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSLog(@"[handleMethodCall] ----  %@  call.arguments %@", call.method, call.arguments);
    
    result(FlutterMethodNotImplemented);
}

@end
