import 'beauty_cam_platform_interface.dart';

typedef BeautyCamCallback = void Function(BeautyCam controller);

class BeautyCam {
  ///切换镜头
  Future<void> switchCamera() {
    return BeautyCamPlatform.instance.switchCamera();
  }

  // ///切换滤镜
  // Future<void> updateFilter(String filterJson) {
  //   return BeautyCamPlatform.instance.updateFilter(filterJson);
  // }

  // ///获取滤镜列表
  // Future<List<Object?>?> getFilterList() {
  //   return BeautyCamPlatform.instance.getFilterList();
  // }

  ///添加滤镜
  Future<void> addFilter(String filter) {
    return BeautyCamPlatform.instance.addFilter(filter);
  }

  ///开启或关闭美颜
  Future<void> enableBeauty(bool isEnableBeauty) {
    return BeautyCamPlatform.instance.enableBeauty(isEnableBeauty);
  }

  ///美颜程度（0~1）
  Future<void> setBeautyLevel(double level) {
    return BeautyCamPlatform.instance.setBeautyLevel(level);
  }

  ///拍照
  Future<String?> takePicture() {
    return BeautyCamPlatform.instance.takePicture();
  }

  ///开始拍视频
  Future<bool?> takeVideo() {
    return BeautyCamPlatform.instance.takeVideo();
  }

  ///结束拍摄视频
  Future<String?> stopVideo() {
    return BeautyCamPlatform.instance.stopVideo();
  }

  ///设置文件保存路径
  Future<String?> setOuPutFilePath(String path) {
    return BeautyCamPlatform.instance.setOuPutFilePath(path);
  }

  ///设置图片纹理加载路径（默认存放在Caches目录）
  Future<String?> setLoadImageResource(String path) {
    return BeautyCamPlatform.instance.setLoadImageResource(path);
  }
}
