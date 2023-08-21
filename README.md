# beauty_cam
### [中文](./CHINESE.md)
# flutter beauty camera
# # Current function:
* Switch Beauty
* take pictures
* Make a video
* Switch lenses
* Set the save path
* Add filter

## Usage
* need to apply in advance and open the required permissions camera and storage.
* Allow users to customize filters (non-programmers can also customize filters, and filters can be updated online)
* Filter editing can be found in the document [Filter Editing Rules](https://github.com/wysaid/android-gpuimage-plus/wiki/Parsing-String-Rule-(ZH))
### This project is based on the open source Git Hub project
*  [android-gpuimage-plus](https://github.com/wysaid/android-gpuimage-plus)
*  [ios-gpuimage-plus](https://github.com/wysaid/ios-gpuimage-plus)

### The edited filter
[filter](./FILTER.md)

```markdown
Open beauty:
cameraFlutterPluginDemo? .enableBeauty(true);
Set the beauty level (0 ~ 1):
cameraFlutterPluginDemo? .setBeautyLevel(1);
Take photos:
cameraFlutterPluginDemo? .takePicture();
Start shooting video:
cameraFlutterPluginDemo? .takeVideo();
End shooting video:
cameraFlutterPluginDemo? .stopVideo();
Switch shots:
cameraFlutterPluginDemo? .switchCamera();
Set LoadImageResource(Stored in the Caches directory by default):
cameraFlutterPluginDemo?.setLoadImageResource();
Set OuPutFilePath:
cameraFlutterPluginDemo?.setLoadImageResource();
Add filter: 
cameraFlutterPluginDemo?. addFilter("@adjust saturation 0 @adjust level 0 0.83921 0.8772");
```
![beauty1.jpeg](Doc%2Fbeauty1.jpeg)
![beauty2.jpg](Doc%2Fbeauty2.jpg)
[beauty.mp4](Doc%2Fbeauty.mp4)
