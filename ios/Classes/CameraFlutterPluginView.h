//
//  CameraFlutterPluginView.h
//  beauty_cam
//
//  Created by MaoJiu on 2023/1/30.
//
#import <Foundation/Foundation.h>
#include <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN
 
@interface CameraFlutterPluginView : NSObject<FlutterPlatformView>
/// 固定写法
- (id)initWithFrame:(CGRect)frame
             viewId:(int64_t)viewId
               args:(id)args
           messager:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
NS_ASSUME_NONNULL_END

