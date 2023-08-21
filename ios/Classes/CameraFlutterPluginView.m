//
//  CameraFlutterPluginView.m
//  beauty_cam
//
//  Created by MaoJiu on 2023/1/30.
//
#import "CameraFlutterPluginView.h"
#import "BeautyCamPlugin.m"
#import <cge/cge.h>
#import <Photos/Photos.h>
#import <cge/cgeUtilFunctions.h>

#define SHOW_FULLSCREEN 0
#define RECORD_WIDTH 480
#define RECORD_HEIGHT 640

#define _MYAVCaptureSessionPreset(w, h) AVCaptureSessionPreset ## w ## x ## h
#define MYAVCaptureSessionPreset(w, h) _MYAVCaptureSessionPreset(w, h)
@interface CameraFlutterPluginView ()
/** channel*/
@property (nonatomic, strong)  FlutterMethodChannel  *channel;

@property CGECameraViewHandler* myCameraViewHandler;
@property (nonatomic) GLKView* glkView;
@property (nonatomic, strong) NSString *pathToMovie; // 视频储存路径
@property (nonatomic, strong) NSString *pathToPic; // 图片储存路径



// 是否开始美颜
@property (nonatomic, assign) BOOL isOpenBeauty;
// 选择的滤镜
@property  NSString * selectFilter;
//美颜配置
@property  NSString * beautyConfig;
//美颜+选择的滤镜配置
@property  char* filterConfig;
// 是否修改过视频储存路径
@property (nonatomic, assign) BOOL isSetMoviePath;
// 是否修改过图片储存路径
@property (nonatomic, assign) BOOL isSetPicPath;

@end
 
@implementation CameraFlutterPluginView
{
    CGRect _frame;
    int64_t _viewId;
    id _args;
    
    id _imagefilter;
}

- (id)initWithFrame:(CGRect)frame
             viewId:(int64_t)viewId
               args:(id)args
           messager:(NSObject<FlutterBinaryMessenger>*)messenger
{
    if (self = [super init])
    {
        _frame = frame;
        _viewId = viewId;
        _args = args;
        
        ///建立通信通道 用来 监听Flutter 的调用和 调用Fluttter 方法 这里的名称要和Flutter 端保持一致
        _channel = [FlutterMethodChannel methodChannelWithName:@"beauty_cam" binaryMessenger:messenger];
        
        __weak __typeof__(self) weakSelf = self;
        
        [_channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
    }
    return self;
}
 
- (UIView *)view{
    
    self.glkView = [[GLKView alloc] initWithFrame:_frame];
    self.glkView.backgroundColor = [UIColor blackColor];
    
    __weak __typeof__(self) weakSelf = self;

    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {//允许访问
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        [weakSelf initCamera];
                    });
                }else{ //不允许访问
                    [weakSelf showCameraAlert];
                }
            });
        }];
    }else if(videoStatus == AVAuthorizationStatusAuthorized){
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf initCamera];
        });
    }else {
        [self showCameraAlert];
    }
    
    return self.glkView;
    
}


- (void)initCamera {
    self.isOpenBeauty = YES;
    self.isSetMoviePath = NO;
    self.isSetPicPath = NO;
    self.beautyConfig=@"@beautify face 0.5 480 640";
    self.selectFilter=@"";
    self.pathToMovie = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamMovie%ld.mp4", (long)[[NSDate date] timeIntervalSince1970]]];
    self.pathToPic = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamPic%ld.png", (long)[[NSDate date] timeIntervalSince1970]]];
    
    _myCameraViewHandler = [[CGECameraViewHandler alloc] initWithGLKView:_glkView];
    
    if([_myCameraViewHandler setupCamera: MYAVCaptureSessionPreset(RECORD_HEIGHT, RECORD_WIDTH) cameraPosition:AVCaptureDevicePositionFront isFrontCameraMirrored:YES authorizationFailed:^{
        NSLog(@"Not allowed to open camera and microphone, please choose allow in the 'settings' page!!!");
    }])
    {
        [[_myCameraViewHandler cameraDevice] startCameraCapture];
    }
    else
    {
        [self showCameraAlert];

    }
    [_myCameraViewHandler fitViewSizeKeepRatio:YES];

    //Set to the max resolution for taking photos.
    [[_myCameraViewHandler cameraRecorder] setPictureHighResolution:YES];

   
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.glkView addGestureRecognizer:pinch];
    [self.glkView addGestureRecognizer:tap];
   
    // 默认开启美颜
    [self enableBeauty:@"1"];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Start camera capturing, 里面封装的是AVFoundation的session的startRunning
        [weakSelf.myCameraViewHandler.cameraDevice startCameraCapture];
    });
    
}

#pragma mark - Flutter 交互监听
-(void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    
    NSLog(@"[call method] ----  %@  call.arguments %@", call.method, call.arguments);
    
    NSDictionary *argumentsDic = call.arguments;
    //监听Fluter
    if ([[call method] isEqualToString:@"enableBeauty"]) { // 开启/关闭美颜
        [self enableBeauty:[argumentsDic objectForKey:@"isEnableBeauty"]];
    }else if ([[call method] isEqualToString:@"switchCamera"]) { // 切换摄像头
        [self switchCamera];
    }else if ([[call method] isEqualToString:@"takePicture"]) { // 拍照
        [self takePictureWithResult:result];
    }else if ([[call method] isEqualToString:@"takeVideo"]) { // 开始录制
        [self takeVideo:result];
    }else if ([[call method] isEqualToString:@"stopVideo"]) { // 结束录制
        [self endVideoWithResult:result];
    }else if ([[call method] isEqualToString:@"setOuPutFilePath"]) { // 设置储存路径
        [self setOuputMP4File:[argumentsDic objectForKey:@"path"]];
        [self setOuputPicFile:[argumentsDic objectForKey:@"path"]];
    }else if([[call method] isEqualToString:@"setLoadImageResource"]){//设置图片纹理加载路径（默认存放在Caches目录）
        loadImageResource=[argumentsDic objectForKey:@"path"];
    }
    
    else if ([[call method] isEqualToString:@"addFilter"]) { // 切换滤镜
        [self setFilterType:[argumentsDic objectForKey:@"filter"]];
    }else if ([[call method] isEqualToString:@"setBeautyLevel"]) { // 切换美颜等级
        [self setBeautyLevel:[NSString stringWithFormat:@"%@", [argumentsDic objectForKey:@"level"]]];
    }
    
}
// 调用Flutter (暂时没用)
- (void)flutterMethod{
    [self.channel invokeMethod:@"clickAciton" arguments:@"我是参数"];
}


// 相机权限弹出框
- (void)showCameraAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请开启照相机权限" message:@"打开后可拍摄照片和视频" preferredStyle:UIAlertControllerStyleAlert];
    NSString *cancel = @"取消";
    NSString *confirm = @"去开启";
    [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:^(BOOL success) {
                }];
            }
        });
        
    }]];
    alertController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    FlutterAppDelegate *appDelegate = (FlutterAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}



// 切换摄像头
- (void)switchCamera {
    [_myCameraViewHandler switchCamera :YES]; //Pass YES to mirror the front camera.
    CMVideoDimensions dim = [[[_myCameraViewHandler cameraDevice] inputCamera] activeFormat].highResolutionStillImageDimensions;
    NSLog(@"Max Photo Resolution: %d, %d\n", dim.width, dim.height);
}

// 开启/关闭美颜
- (void)enableBeauty:(NSString *)isEnableBeauty {
    
    if(isEnableBeauty.integerValue == 1) { // 开启
      
        self.beautyConfig=@"@beautify face 0.5 480 640";
       
    }else { // 关闭
        self.beautyConfig=@"";
    }
    [self setFinalFilter];
}


// 修改美颜等级
- (void)setBeautyLevel:(NSString *)level {
    float levelFloat = level.floatValue;
    float currentIntensity = levelFloat * 2.0f - 1.0f; //[-1, 1]
    [_myCameraViewHandler setFilterIntensity: currentIntensity];
    NSLog(@"setBeautyLevel----------------- %f", currentIntensity);
    self.beautyConfig = [NSString stringWithFormat:@"@beautify face %f 480 640", currentIntensity];
    [self setFinalFilter];
    
}

// 切换滤镜
- (void)setFilterType:(NSString *)typeStr {
    self.selectFilter = typeStr;
    [self setFinalFilter];

}



- (void)setFinalFilter{
    self.filterConfig=(char *)[[NSString stringWithFormat:@"%@%@", self.beautyConfig, self.selectFilter] UTF8String];
    NSLog(@"滤镜切换=========filterConfig:%s==beautyConfig:%@==selectFilter:%@==",self.filterConfig,self.beautyConfig,self.selectFilter);
    [_myCameraViewHandler setFilterWithConfig:self.filterConfig];
}


// 设置视频储存路径
- (void)setOuputMP4File:(NSString *)path {
    self.pathToMovie = path;
    self.isSetMoviePath = YES;
}

// 设置图片储存路径
- (void)setOuputPicFile:(NSString *)path {
    self.pathToPic = path;
    self.isSetPicPath = YES;
}


// 拍照
- (void)takePictureWithResult:(FlutterResult)result {
    self.pathToPic = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamPic%ld.png", (long)[[NSDate date] timeIntervalSince1970]]];
        
    [_myCameraViewHandler takeShot:^(UIImage* image){
        [CameraFlutterPluginView saveImage:image toPath:self.pathToPic flutterResult:result];
    }];
    
}


// 开始拍摄
- (void)takeVideo :(FlutterResult)result{
    NSLog(@"开始拍摄");
    if([_myCameraViewHandler isRecording])
    {
        void (^finishBlock)(void) = ^{
            NSLog(@"End recording...\n");
            [CGESharedGLContext mainASyncProcessingQueue:^{
            }];
            
            [CameraFlutterPluginView saveVideo:[NSURL URLWithString:self.pathToMovie] flutterResult:result];
            
        };
        
        [_myCameraViewHandler endRecording:finishBlock ];
    }
    else
    {
        unlink([self.pathToMovie UTF8String]);
        [_myCameraViewHandler startRecording:[NSURL URLWithString:self.pathToMovie]   size:CGSizeMake(RECORD_WIDTH, RECORD_HEIGHT)];
    }
    
}

// 结束拍摄
- (void)endVideoWithResult:(FlutterResult)result {
    if([_myCameraViewHandler isRecording])
    {
        void (^finishBlock)(void) = ^{
            NSLog(@"End recording...\n");
            
            [CGESharedGLContext mainASyncProcessingQueue:^{
            }];
            
            [CameraFlutterPluginView saveVideo:[NSURL URLWithString:self.pathToMovie] flutterResult:result];
        
            
        };
        [_myCameraViewHandler endRecording:finishBlock];
    }
    else
    {
        unlink([self.pathToMovie UTF8String]);
        
        CGRect rts[] = {
            CGRectMake(0.25, 0.25, 0.5, 0.5), //Record a quarter of the camera view in the center.
            CGRectMake(0.5, 0.0, 0.5, 1.0), //Record the right (half) side of the camera view.
            CGRectMake(0.0, 0.0, 1.0, 0.5), //Record the up (half) side of the camera view.
        };
        
        CGRect rt = rts[rand() % sizeof(rts) / sizeof(*rts)];
        
        CGSize videoSize = CGSizeMake(RECORD_WIDTH * rt.size.width, RECORD_HEIGHT * rt.size.height);
        
        NSLog(@"Crop area: %g, %g, %g, %g, record resolution: %g, %g", rt.origin.x, rt.origin.y, rt.size.width, rt.size.height, videoSize.width, videoSize.height);
        
        [_myCameraViewHandler startRecording:[NSURL URLWithString:self.pathToMovie] size:videoSize cropArea:rt];
    }
    
}

+ (void)saveVideo:(NSURL*)videoURL flutterResult:(FlutterResult)result
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
               [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
           } completionHandler:^(BOOL success, NSError * _Nullable error) {
               if (error) {
                   NSLog(@"savePhotoLibraryVideo %@", error);
                   result(nil);
               } else {
                   NSLog(@"savePhotoLibraryVideo success");
                   result([videoURL absoluteString]);
               }
           }];
}



+ (void)saveImage:(UIImage *)image toPath:(NSString *)path flutterResult:(FlutterResult)result{
    [CGEProcessingContext mainSyncProcessingQueue:^{
        if (image != nil) {
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            
            NSError *error = nil;
            [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
            
            if (error) {
                result(nil);
            } else {
                result(path);
                
            }
        }
    }];
}

#pragma mark -
// 缩放/放大
- (void)pinch:(UIPinchGestureRecognizer *)pinch {
    
    
    [_myCameraViewHandler.cameraDevice.inputCamera lockForConfiguration:nil];
    float maxZoomFactor = _myCameraViewHandler.cameraDevice.inputCamera.activeFormat.videoMaxZoomFactor;
    float pinchVelocityDividerFactor = 25.0;
    float desiredZoomFactor =
    _myCameraViewHandler.cameraDevice.inputCamera.videoZoomFactor + atan2(pinch.velocity, pinchVelocityDividerFactor);
    _myCameraViewHandler.cameraDevice.inputCamera.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, maxZoomFactor));
    [_myCameraViewHandler.cameraDevice.inputCamera unlockForConfiguration];
    
    
    
}


- (void)tap:(UITapGestureRecognizer *)tap {
    //对焦
    CGPoint touchPoint = [tap locationInView:_glkView];
    CGSize sz = [_glkView frame].size;
    CGPoint transPoint = CGPointMake(touchPoint.x / sz.width, touchPoint.y / sz.height);
    
    [_myCameraViewHandler focusPoint:transPoint];
    NSLog(@"touch position: %g, %g, transPoint: %g, %g", touchPoint.x, touchPoint.y, transPoint.x, transPoint.y);
    
}



//- (void)downloadImageAndSaveToCaches:(NSURL *)imageURL {
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:imageURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Error downloading image: %@", error);
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        if (httpResponse.statusCode == 200) {
//            NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
//            NSString *fileName = [response suggestedFilename];
//            NSString *destinationPath = [cachesDirectory stringByAppendingPathComponent:fileName];
//            
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            NSError *moveError = nil;
//            BOOL success = [fileManager moveItemAtURL:location toURL:[NSURL fileURLWithPath:destinationPath] error:&moveError];
//            
//            if (success) {
//                NSLog(@"Downloaded and saved image to Caches directory");
//                // Do something with the downloaded image
//            } else {
//                NSLog(@"Error moving image to Caches directory: %@", moveError);
//            }
//        } else {
//            NSLog(@"Error downloading image. HTTP status code: %ld", (long)httpResponse.statusCode);
//        }
//    }];
//    
//    [downloadTask resume];
//}

@end



