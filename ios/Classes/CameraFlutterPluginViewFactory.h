//
//  CameraFlutterPluginViewFactory.h
//  beauty_cam
//
//  Created by MaoJiu on 2023/1/30.
//
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface CameraFlutterPluginViewFactory : NSObject<FlutterPlatformViewFactory>

/// 重写一个构造方法 来接收 Flutter 相关蚕食
/// @param messenger Flutter类 包含回调方法等信息
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end
NS_ASSUME_NONNULL_END

