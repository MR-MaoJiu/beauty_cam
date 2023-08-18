//
//  CameraFlutterPluginViewFactory.m
//  beauty_cam
//
//  Created by MaoJiu on 2023/1/30.
//
#import "CameraFlutterPluginViewFactory.h"
#import "CameraFlutterPluginView.h"
@interface CameraFlutterPluginViewFactory ()
 
@property(nonatomic)NSObject<FlutterBinaryMessenger>* messenger;
 
@end
 
@implementation CameraFlutterPluginViewFactory
 
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.messenger = messenger;
    }
    return self;
}
 
#pragma mark -- 实现FlutterPlatformViewFactory 的代理方法
- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}
 
/// FlutterPlatformViewFactory 代理方法 返回过去一个类来布局 原生视图
/// @param frame frame
/// @param viewId view的id
/// @param args 初始化的参数
- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args{
    
    CameraFlutterPluginView *cameraFlutterPluginView = [[CameraFlutterPluginView alloc] initWithFrame:frame viewId:viewId args:args messager:self.messenger];
    return cameraFlutterPluginView;
    
}

@end
