# beauty_cam
### [中文](./CHINESE.md)
# flutter beauty camera
# # Current function:
* Switch Beauty
* take pictures
* Make a video
* Switch lenses
* Set the save path
* Get a list of filters
* Switch filter
# # Ready to add
* filter
# # Usage
* need to apply in advance and open the required permissions camera and storage.
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
Get a list of filters: 
cameraFlutterPluginDemo?. getFilterList(); 
Switch filter: 
cameraFlutterPluginDemo?. updateFilter("浪漫");
```