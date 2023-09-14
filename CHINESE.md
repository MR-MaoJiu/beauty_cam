# beauty_cam
### [English](./README.md)
# flutter美颜相机
## 目前功能：
* 开关美颜
* 拍照
* 拍视频
* 切换镜头
* 设置保存路径
* 添加滤镜
## 使用方法
*  需要提前申请并开启所需权限相机和存储
* 允许用户自定义滤镜（非程序员也可以自定义滤镜可以做到线上更新滤镜）
* 滤镜编辑可以参考文档[滤镜编辑规则](https://github.com/wysaid/android-gpuimage-plus/wiki/Parsing-String-Rule-(ZH))
### 本项目根据开源GitHub项目编写
*  [android-gpuimage-plus](https://github.com/wysaid/android-gpuimage-plus)
*  [ios-gpuimage-plus](https://github.com/wysaid/ios-gpuimage-plus)

### 已编辑好滤镜
[滤镜](./FILTER.md)
### 准备下一个版本要实现的功能
* 保存滤镜图片纹理到本地
* 实现动态滤镜
* 人脸识别 
* 增加人脸识别贴纸

```markdown
开启美颜：
cameraFlutterPluginDemo?.enableBeauty(true);
设置美颜等级（0～1）：
cameraFlutterPluginDemo?.setBeautyLevel(1);
拍摄照片：
cameraFlutterPluginDemo?.takePicture();
开始拍视频：
cameraFlutterPluginDemo?.takeVideo();
结束拍视频：
cameraFlutterPluginDemo?.stopVideo();
切换镜头：
cameraFlutterPluginDemo?.switchCamera();
设置图片纹理加载路径（默认存放在Caches目录）:
cameraFlutterPluginDemo?.setLoadImageResource();
设置文件保存路径:
cameraFlutterPluginDemo?.setOuPutFilePath();
添加滤镜：
cameraFlutterPluginDemo?. addFilter("@adjust saturation 0 @adjust level 0 0.83921 0.8772");
```
![beauty1.jpg](Doc%2Fbeauty1.jpg)
![beauty2.jpg](Doc%2Fbeauty2.jpg)
[beauty.mp4](Doc%2Fbeauty.mp4)