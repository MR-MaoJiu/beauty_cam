# beauty_cam
### [English](./README.md)
# flutter美颜相机
## 目前功能：
* 开关美颜
* 拍照
* 拍视频
* 切换镜头
* 设置保存路径
* 获取滤镜列表
* 切换滤镜
## 使用方法
*  需要提前申请并开启所需权限相机和存储
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
获取滤镜列表：
cameraFlutterPluginDemo?.getFilterList();
切换滤镜：
cameraFlutterPluginDemo?.updateFilter("浪漫");
```