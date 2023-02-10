//
//  CameraFlutterPluginView.m
//  beauty_cam
//
//  Created by 比赞 on 2023/1/30.
//
#import "CameraFlutterPluginView.h"
#import "GPUImage.h"
#import <AVFoundation/AVCaptureDevice.h>

@interface CameraFlutterPluginView ()
/** channel*/
@property (nonatomic, strong)  FlutterMethodChannel  *channel;

@property (nonatomic, strong) UIView *nativeView;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageStillCamera *gpuVideoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
@property (nonatomic, strong) NSString *pathToMovie; // 视频储存路径
@property (nonatomic, strong) NSString *pathToPic; // 图片储存路径

@property (nonatomic, strong) GPUImageBilateralFilter *bilateralFilter;
@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) GPUImageExposureFilter *exposureFilter;
@property (nonatomic, strong) GPUImageClosingFilter *closingFilter; // 黑白滤镜
@property (nonatomic, strong) GPUImageSepiaFilter *sepiaFilter; // 怀旧滤镜
@property (nonatomic, strong) GPUImageRGBFilter *blueColdRGBFilter; // 颜色滤镜(蓝)寒冷
@property (nonatomic, strong) GPUImageRGBFilter *yellowWarmRGBFilter; // 颜色滤镜(黄)温暖
@property (nonatomic, strong) GPUImageRGBFilter *redRomanceRGBFilter; // 颜色滤镜(红)浪漫

// 是否开始美颜
@property (nonatomic, assign) BOOL isOpenBeauty;
// 选择的滤镜类型
@property (nonatomic, copy) NSString *selectFilterType;
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
    
    self.nativeView = [[UIView alloc] initWithFrame:_frame];
    self.nativeView.backgroundColor = [UIColor blackColor];
    

    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoStatus == AVAuthorizationStatusAuthorized){
        __weak __typeof__(self) weakSelf = self;
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf initCamera];
        });
    }else {
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
    
    return self.nativeView;
    
}
- (void)initCamera {
    
    self.selectFilterType = 0;
    self.isOpenBeauty = YES;
    self.selectFilterType = @"原图";
    self.isSetMoviePath = NO;
    self.isSetPicPath = NO;

    self.pathToMovie = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamMovie%ld.mp4", (long)[[NSDate date] timeIntervalSince1970]]];
    self.pathToPic = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamPic%ld.png", (long)[[NSDate date] timeIntervalSince1970]]];
    
    self.gpuImageView = [[GPUImageView alloc] init];
    self.gpuImageView.frame = self.nativeView.frame;
    [self.nativeView addSubview:self.gpuImageView];
    
    // videoCamera
    self.gpuVideoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    [self.gpuVideoCamera addAudioInputsAndOutputs];
    self.gpuVideoCamera.jpegCompressionQuality = 1;
    
    // GPUImageView填充模式
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    self.gpuVideoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.gpuVideoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    [self  initFilter];
    
    // 默认开启美颜
    [self enableBeauty:@"1"];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Start camera capturing, 里面封装的是AVFoundation的session的startRunning
        [weakSelf.gpuVideoCamera startCameraCapture];
    });
    
}

// 初始化滤镜
- (void)initFilter {
    
    self.filterGroup = [[GPUImageFilterGroup alloc] init];
    // 双边模糊
    self.bilateralFilter = [[GPUImageBilateralFilter alloc] init];
    self.bilateralFilter.distanceNormalizationFactor = 12.0;
    // 曝光
    self.exposureFilter = [[GPUImageExposureFilter alloc] init];
    self.exposureFilter.exposure = 0; // -1/1 正常0
    // 美白
    self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    self.brightnessFilter.brightness = 0.04;  // -1/1 正常0
    // 饱和
//        GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
//        saturationFilter.saturation = 1.0;  // 0/2 正常1
    // 锐化
    self.sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    self.sharpenFilter.sharpness = -0.1; //-4/4 正常0
    // 黑白
    self.closingFilter = [[GPUImageClosingFilter alloc] init];
    // 颜色(寒冷)
    self.blueColdRGBFilter = [[GPUImageRGBFilter alloc] init];
    self.blueColdRGBFilter.green = 1.2;     
    self.blueColdRGBFilter.blue = 2.2;
    // 颜色(黄)温暖
    self.yellowWarmRGBFilter = [[GPUImageRGBFilter alloc] init];
    self.yellowWarmRGBFilter.red = 1.17;
    self.yellowWarmRGBFilter.green = 1.16;
    self.yellowWarmRGBFilter.blue = 1;
    // 颜色(红)浪漫
    self.redRomanceRGBFilter = [[GPUImageRGBFilter alloc] init];
    self.redRomanceRGBFilter.red = 1.37;
    self.redRomanceRGBFilter.green = 1.1;
    self.redRomanceRGBFilter.blue = 1.2;
    // 怀旧
    self.sepiaFilter = [[GPUImageSepiaFilter alloc] init];

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
        [self takeVideo];
    }else if ([[call method] isEqualToString:@"stopVideo"]) { // 结束录制
        [self endVideoWithResult:result];
    }else if ([[call method] isEqualToString:@"setOuputMP4File"]) { // 设置视频储存路径
        [self setOuputMP4File:[argumentsDic objectForKey:@"path"]];
    }else if ([[call method] isEqualToString:@"setOuputPicFile"]) { // 设置图片储存路径
        [self setOuputPicFile:[argumentsDic objectForKey:@"path"]];
    }else if ([[call method] isEqualToString:@"updateFilter"]) { // 切换滤镜
        [self setFilterType:[argumentsDic objectForKey:@"filter"]];
    }else if ([[call method] isEqualToString:@"getFilterList"]) { // 获取滤镜列表
        result([self getFilterList]);
    }else if ([[call method] isEqualToString:@"setBeautyLevel"]) { // 切换美颜等级
        [self setBeautyLevel:[NSString stringWithFormat:@"%@", [argumentsDic objectForKey:@"level"]]];
    }
    
}
// 调用Flutter
- (void)flutterMethod{
    [self.channel invokeMethod:@"clickAciton" arguments:@"我是参数"];
}

// 开启/关闭美颜
- (void)enableBeauty:(NSString *)isEnableBeauty {
    
    if (self.gpuImageView == nil) {
        return;
    }
    
    if(isEnableBeauty.integerValue == 1) { // 开启
        self.isOpenBeauty = YES;
    }else { // 关闭
        self.isOpenBeauty = NO;
    }
    
    [self.gpuVideoCamera removeAllTargets];
    GPUImageFilter *gpuImageFiler = [self getFilterWithType:self.selectFilterType];
    [self.gpuVideoCamera addTarget:[self addSelectFilter:gpuImageFiler]];
    [gpuImageFiler addTarget:self.gpuImageView];
    _imagefilter = gpuImageFiler;
}

// 切换摄像头
- (void)switchCamera {
    [self.gpuVideoCamera rotateCamera];
}

// 拍照
- (void)takePictureWithResult:(FlutterResult)result {
    __weak __typeof__(self) weakSelf = self;

    if (self.isSetPicPath) {
        self.pathToPic = self.pathToPic;
    }else {
        self.pathToPic = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"BeautyCamPic%ld.png", (long)[[NSDate date] timeIntervalSince1970]]];
    }
    [self.gpuVideoCamera capturePhotoAsImageProcessedUpToFilter:_imagefilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        if(error){
            NSLog(@"error --- %@", error);
            return;
        }
        // 写入指定路径
        NSData *data = UIImagePNGRepresentation(processedImage);
        [data writeToFile:weakSelf.pathToPic atomically:YES];
        // 存到相册
        UIImageWriteToSavedPhotosAlbum(processedImage, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:),(__bridge void *)weakSelf);
        result(weakSelf.pathToPic);
    }];
}

// 开始拍摄
- (void)takeVideo {
    NSLog(@"开始拍摄");
    unlink([self.pathToMovie UTF8String]);
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_imagefilter addTarget:weakSelf.movieWriter];
        weakSelf.gpuVideoCamera.audioEncodingTarget = weakSelf.movieWriter;
        [weakSelf.movieWriter startRecording];
    });
    
}

// 结束拍摄
- (void)endVideoWithResult:(FlutterResult)result {
    
    [_imagefilter removeTarget:self.movieWriter];
    self.gpuVideoCamera.audioEncodingTarget = nil;
    __weak __typeof__(self) weakSelf = self;
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf saveVideo];
        weakSelf.movieWriter = nil;
        result(weakSelf.pathToMovie);
    }];
    
}
// 修改美颜等级
- (void)setBeautyLevel:(NSString *)level {
    float levelFloat = level.floatValue;
        
    // 磨皮最大值
    float maxBilateral = 5;
    // 磨皮最小值
    float minBilateral = 20;

    if(levelFloat >= 1) {
        self.bilateralFilter.distanceNormalizationFactor = maxBilateral;
    }else if(levelFloat <= 0) {
        self.bilateralFilter.distanceNormalizationFactor = minBilateral;
    }else {
        self.bilateralFilter.distanceNormalizationFactor = minBilateral - ((minBilateral - maxBilateral)*levelFloat);
    }
//    NSLog(@" ------- %f", self.bilateralFilter.distanceNormalizationFactor);
}

// 切换滤镜
- (void)setFilterType:(NSString *)typeStr {
    if (self.gpuImageView == nil) {
        return;
    }
    
    self.selectFilterType = typeStr;
    [self.gpuVideoCamera removeAllTargets];
    GPUImageFilter *gpuImageFiler = [self getFilterWithType:typeStr];
    [self.gpuVideoCamera addTarget:[self addSelectFilter:gpuImageFiler]];
    [gpuImageFiler addTarget:self.gpuImageView];
    _imagefilter = gpuImageFiler;
    
}

// 获取滤镜列表
- (NSArray *)getFilterList {
    return [NSArray arrayWithObjects:@"原图", @"黑白", @"怀旧", @"寒冷", @"温暖", @"浪漫",nil];
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
#pragma mark -

// 添加选择的滤镜
- (id<GPUImageInput>)addSelectFilter:(id<GPUImageInput>)newTarget {
    
    if(self.isOpenBeauty) {
        self.filterGroup = [[GPUImageFilterGroup alloc] init];
        
        [self.bilateralFilter removeAllTargets];
        [self.brightnessFilter removeAllTargets];
        [self.sharpenFilter removeAllTargets];
        
        [self.bilateralFilter addTarget: self.brightnessFilter];
        [self.brightnessFilter addTarget: self.sharpenFilter];
        [self.sharpenFilter addTarget: newTarget];

        [self.filterGroup setInitialFilters:[NSArray arrayWithObject:self.bilateralFilter]];
        [self.filterGroup setTerminalFilter:newTarget];
        
        return self.filterGroup;
    }else {
        
        return newTarget;
    }
    
}

// 根据类型返回滤镜
- (id<GPUImageInput>)getFilterWithType:(NSString *)type {
    if([type isEqualToString:@"黑白"]) { // 黑白
        return self.closingFilter;
    }else if([type isEqualToString:@"寒冷"]) {
        // 颜色(冷)
        return self.blueColdRGBFilter;
    }else if([type isEqualToString:@"温暖"]) {
        // 颜色(暖)日落
        return self.yellowWarmRGBFilter;;
    }else if([type isEqualToString:@"浪漫"]) {
        // 颜色(红)温暖
        return _redRomanceRGBFilter;
    }else if([type isEqualToString:@"怀旧"]) {
        // 怀旧
        return self.sepiaFilter;
    }else { // 原图
        return self.exposureFilter;
    }
}

// 保存视频
- (void)saveVideo {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self.pathToMovie];
    if (!exists) {
        NSLog(@"不存在");
        return;
    }
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.pathToMovie)) {
        UISaveVideoAtPathToSavedPhotosAlbum(self.pathToMovie, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }else {
        NSLog(@"保存视频成功");
    }
}

//保存图片完成之后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

#pragma mark - Getters & Setters
- (GPUImageMovieWriter *)movieWriter {

    if (_movieWriter) {
        return _movieWriter;
    }
    
    CGSize movieSize = CGSizeMake(720, 1280);
    NSURL *movieURL = [NSURL fileURLWithPath:self.pathToMovie];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setObject:AVVideoCodecTypeH264 forKey:AVVideoCodecKey];
    [settings setObject:[NSNumber numberWithInteger:movieSize.width] forKey:AVVideoWidthKey];
    [settings setObject:[NSNumber numberWithInteger:movieSize.height] forKey:AVVideoHeightKey];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:movieSize fileType:AVFileTypeMPEG4 outputSettings:settings];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
    return _movieWriter;
}



@end



