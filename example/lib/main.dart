import 'package:beauty_cam/beauty_cam.dart';
import 'package:beauty_cam/camera_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ///定义一个测试类的属性 用来调用原生方法 和原生交互
  BeautyCam? cameraFlutterPluginDemo; // 定一个插件的对象，
  bool isEnableBeauty = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///初始化 测试视图的类，我们写的TextView
    CameraView cameraView = CameraView(
      onCreated: onCameraViewCreated,
    );
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              cameraView,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ///添加按钮 用来触发原生调用
                  IconButton(
                    onPressed: () {
                      cameraFlutterPluginDemo?.enableBeauty(isEnableBeauty);

                      setState(() {
                        isEnableBeauty = !isEnableBeauty;
                      });
                    },
                    icon: Icon(
                      isEnableBeauty ? Icons.face : Icons.face_retouching_off,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // cameraFlutterPluginDemo?.updateFilter("isEnableBeauty");
                      //
                      // setState(() {
                      //   isEnableBeauty = !isEnableBeauty;
                      // });
                      cameraFlutterPluginDemo?.takeVideo();
                    },
                    icon: const Icon(Icons.not_started_outlined,
                        color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      // cameraFlutterPluginDemo?.updateFilter("isEnableBeauty");
                      //
                      // setState(() {
                      //   isEnableBeauty = !isEnableBeauty;
                      // });
                      cameraFlutterPluginDemo?.stopVideo().then((value) {
                        print(
                            "================================================");
                        print("$value");
                        print(
                            "================================================");
                        // final snackBar = SnackBar(content: Text('$value'));
                        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      });
                    },
                    icon: const Icon(Icons.stop, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      cameraFlutterPluginDemo?.switchCamera();
                    },
                    icon: const Icon(Icons.switch_camera, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      cameraFlutterPluginDemo?.getFilterList().then((value) {
                        value?.forEach((element) {
                          print("===========================>$element");
                        });
                      });
                    },
                    icon: const Icon(Icons.list_alt_sharp, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      cameraFlutterPluginDemo?.updateFilter("浪漫");
                    },
                    icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  )
                ],
              )
            ],
          )),
    );
  }

  void onCameraViewCreated(cameraFlutterPluginDemo) {
    this.cameraFlutterPluginDemo = cameraFlutterPluginDemo;
  }
}
