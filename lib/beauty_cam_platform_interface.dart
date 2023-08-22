import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'beauty_cam_method_channel.dart';

abstract class BeautyCamPlatform extends PlatformInterface {
  /// Constructs a BeautyCamPlatform.
  BeautyCamPlatform() : super(token: _token);

  static final Object _token = Object();

  static BeautyCamPlatform _instance = MethodChannelBeautyCam();

  /// The default instance of [BeautyCamPlatform] to use.
  ///
  /// Defaults to [MethodChannelBeautyCam].
  static BeautyCamPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BeautyCamPlatform] when
  /// they register themselves.
  static set instance(BeautyCamPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  ///切换镜头
  Future<void> switchCamera() {
    throw UnimplementedError('switchCamera() has not been implemented.');
  }

  // ///切换滤镜
  // Future<void> updateFilter(String filterJson) {
  //   throw UnimplementedError('updateFilter() has not been implemented.');
  // }
  //
  // ///获取滤镜列表
  // Future<List<Object?>?> getFilterList() {
  //   throw UnimplementedError('updateFilter() has not been implemented.');
  // }

  ///添加滤镜
  Future<void> addFilter(String filter) {
    throw UnimplementedError('updateFilter() has not been implemented.');
  }

  ///开启或关闭美颜
  Future<void> enableBeauty(bool isEnableBeauty) {
    throw UnimplementedError('enableBeauty() has not been implemented.');
  }

  ///美颜程度（0~1）
  Future<void> setBeautyLevel(double level) async {
    assert(level <= 1.0);
    throw UnimplementedError('setBeautyLevel() has not been implemented.');
  }

  ///拍照
  Future<String?> takePicture() {
    throw UnimplementedError('takePicture() has not been implemented.');
  }

  ///开始拍视频
  Future<bool?> takeVideo() {
    throw UnimplementedError('takeVideo() has not been implemented.');
  }

  ///结束拍视频
  Future<String?> stopVideo() {
    throw UnimplementedError('stopVideo() has not been implemented.');
  }

  ///设置文件保存路径
  Future<String?> setOuPutFilePath(String path) {
    throw UnimplementedError('setOuPutFilePath() has not been implemented.');
  }

  ///设置图片纹理加载路径（默认存放在Caches目录）
  Future<String?> setLoadImageResource(String path) {
    throw UnimplementedError(
        'setLoadImageResource() has not been implemented.');
  }
}
