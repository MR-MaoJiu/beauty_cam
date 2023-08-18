import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'beauty_cam.dart';

class CameraView extends StatefulWidget {
  final BeautyCamCallback? onCreated;
  const CameraView({Key? key, this.onCreated}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 2000),
      child: Container(
        color: Colors.black,
        child: _loadNativeView(),
      ),
    );
  }

  ///加载原生视图
  Widget _loadNativeView() {
    ///根据不同的平台显示相应的视图
    if (Platform.isAndroid) {
      ///加载安卓原生视图
      return AndroidView(
        viewType: 'beauty_cam',

        ///视图标识符 要和原生 保持一致 要不然加载不到视图
        onPlatformViewCreated: onPlatformViewCreated,

        ///原生视图创建成功的回调
        creationParams: const <String, dynamic>{
          ///给原生传递初始化参数 就是上面定义的初始化参数
        },

        /// 用来编码 creationParams 的形式，可选 [StandardMessageCodec], [JSONMessageCodec], [StringCodec], or [BinaryCodec]
        /// 如果存在 creationParams，则该值不能为null
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      ///加载iOS原生视图
      return UiKitView(
        viewType: 'beauty_cam',

        ///视图标识符 要和原生 保持一致 要不然加载不到视图
        onPlatformViewCreated: onPlatformViewCreated,

        // ///原生视图创建成功的回调
        // creationParams: <String, dynamic>{
        //   ///给原生传递初始化参数 就是上面定义的初始化参数
        //   'titleStr': widget.titleStr,
        // },

        /// 用来编码 creationParams 的形式，可选 [StandardMessageCodec], [JSONMessageCodec], [StringCodec], or [BinaryCodec]
        /// 如果存在 creationParams，则该值不能为null
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Text('暂不支持其他平台');
    }
  }

  ///这个基本上是固定写法
  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
    }
    widget.onCreated!(BeautyCam());
  }
}
